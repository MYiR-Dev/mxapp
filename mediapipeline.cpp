/***********************************************************************
 *  MXAPP2 — CSI Camera Media Pipeline Initialization
 ***********************************************************************/

#include "mediapipeline.h"

#include <QDebug>
#include <QDir>
#include <QSet>
#include <QQueue>
#include <QRegularExpression>

// 调试开关: 定义 MEDIAPIPELINE_DEBUG 可恢复详细拓扑输出
#ifdef MEDIAPIPELINE_DEBUG
#define MP_DBG(...) fprintf(stderr, __VA_ARGS__)
#else
#define MP_DBG(...) ((void)0)
#endif

#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <string.h>
#include <errno.h>
#include <linux/videodev2.h>
#include <linux/media.h>
#include <linux/v4l2-subdev.h>

// ============================================================================
// 静态成员
// ============================================================================
bool MediaPipeline::s_configured = false;
QMap<QString, MediaPipeline::Resolution> MediaPipeline::s_resolutions;

// ============================================================================
// fallback 宏
// ============================================================================
#ifndef MEDIA_LNK_FL_ENABLED
#define MEDIA_LNK_FL_ENABLED         (1 << 0)
#endif
#ifndef MEDIA_LNK_FL_INTERFACE_LINK
#define MEDIA_LNK_FL_INTERFACE_LINK  (1 << 2)
#endif
#ifndef MEDIA_PAD_FL_SINK
#define MEDIA_PAD_FL_SINK            (1 << 0)
#endif
#ifndef MEDIA_PAD_FL_SOURCE
#define MEDIA_PAD_FL_SOURCE          (1 << 1)
#endif
#ifndef MEDIA_INTF_T_V4L_BASE
#define MEDIA_INTF_T_V4L_BASE       0x00000200
#endif
#ifndef MEDIA_INTF_T_V4L_SUBDEV
#define MEDIA_INTF_T_V4L_SUBDEV     (MEDIA_INTF_T_V4L_BASE + 3)
#endif

// "旧编号"下 entity function 的基址，用于判定是否是 IO 节点
#ifndef MEDIA_ENT_F_OLD_BASE
#define MEDIA_ENT_F_OLD_BASE         0x00020000
#endif
#ifndef MEDIA_ENT_F_IO_V4L
#define MEDIA_ENT_F_IO_V4L           (MEDIA_ENT_F_OLD_BASE + 1)
#endif

// ============================================================================
// 内部结构
// ============================================================================
struct Entity {
    unsigned int id;
    QString name;
    unsigned int function;
    int devMajor;
    int devMinor;
    bool isCapture;   // /dev/video* 输出节点
};

struct Pad {
    unsigned int id;
    unsigned int entityId;
    unsigned int flags;
    unsigned int index;   // ★ 独立字段，不是从 flags 取
};

struct Link {
    unsigned int id;
    unsigned int srcId;   // pad id 或 interface id
    unsigned int dstId;   // pad id 或 entity id
    unsigned int flags;
};

// ============================================================================
// 辅助函数
// ============================================================================

// 通过 major:minor 打开 /dev/v4l-subdev*
static int openSubdev(int maj, int min)
{
    if (!maj && !min) return -1;
    QDir d("/dev");
    for (const auto &n : d.entryList({"v4l-subdev*"}, QDir::System)) {
        QString p = "/dev/" + n;
        int fd = open(p.toUtf8().constData(), O_RDWR);
        if (fd < 0) continue;
        struct stat st;
        if (!fstat(fd, &st) && (int)major(st.st_rdev) == maj && (int)minor(st.st_rdev) == min)
            return fd;
        close(fd);
    }
    return -1;
}

// 通过 major:minor 找 /dev/video* 设备名
static QString findVideoDevName(int maj, int min)
{
    if (!maj && !min) return {};
    QDir d("/dev");
    for (const auto &n : d.entryList({"video*"}, QDir::System)) {
        QString p = "/dev/" + n;
        struct stat st;
        if (!stat(p.toUtf8().constData(), &st) &&
            (int)major(st.st_rdev) == maj && (int)minor(st.st_rdev) == min)
            return p;
    }
    return {};
}

// 枚举 subdev pad 上的 mbus code
static QVector<unsigned int> enumMbusCodes(int sfd, int padIdx)
{
    QVector<unsigned int> c;
    struct v4l2_subdev_mbus_code_enum m;
    memset(&m, 0, sizeof(m));
    m.pad = padIdx;
    while (ioctl(sfd, VIDIOC_SUBDEV_ENUM_MBUS_CODE, &m) == 0) {
        c.append(m.code);
        m.index++;
    }
    return c;
}

// 从多个 mbus code 中选最佳
static unsigned int bestMbusCode(const QVector<unsigned int> &codes)
{
    static const unsigned int pref[] = {
        0x200f, // UYVY8_1X16
        0x2011, // YUYV8_1X16
        0x2008, // YUYV8_2X8
        0x1017, // RGB565_1X16
        0x100a, // RGB888_1X24
    };
    for (auto p : pref) if (codes.contains(p)) return p;
    return codes.first();
}

// ============================================================================
// enumTopology — G_TOPOLOGY 一次性枚举所有实体/pad/link/interface
// ============================================================================
static bool enumTopology(int mfd,
                          QVector<Entity> &ents,
                          QVector<Pad>    &pads,
                          QVector<Link>   &links)
{
    ents.clear(); pads.clear(); links.clear();

    // 第一轮：获取计数
    struct media_v2_topology topo;
    memset(&topo, 0, sizeof(topo));
    if (ioctl(mfd, MEDIA_IOC_G_TOPOLOGY, &topo) < 0) {
        fprintf(stderr, "MP: G_TOPOLOGY(count) err %s\n", strerror(errno));
        return false;
    }

    unsigned int nEnt = topo.num_entities, nIfc = topo.num_interfaces,
                 nPad = topo.num_pads, nLnk = topo.num_links;

    MP_DBG("MP: topology counts: entities=%u interfaces=%u pads=%u links=%u\n",
            nEnt, nIfc, nPad, nLnk);
    if (!nEnt) return false;

    // 第二轮：分配并获取数据
    QVector<struct media_v2_entity>    vEnt(nEnt);
    QVector<struct media_v2_interface> vIfc(nIfc);
    QVector<struct media_v2_pad>       vPad(nPad);
    QVector<struct media_v2_link>      vLnk(nLnk);

    memset(&topo, 0, sizeof(topo));
    topo.ptr_entities   = (__u64)(uintptr_t)vEnt.data();
    topo.ptr_interfaces = (__u64)(uintptr_t)vIfc.data();
    topo.ptr_pads       = (__u64)(uintptr_t)vPad.data();
    topo.ptr_links      = (__u64)(uintptr_t)vLnk.data();
    topo.num_entities   = nEnt;
    topo.num_interfaces = nIfc;
    topo.num_pads       = nPad;
    topo.num_links      = nLnk;

    if (ioctl(mfd, MEDIA_IOC_G_TOPOLOGY, &topo) < 0) {
        fprintf(stderr, "MP: G_TOPOLOGY(data) err %s\n", strerror(errno));
        return false;
    }

    // ──── 打印 interface 详情 ────
    for (unsigned int i = 0; i < topo.num_interfaces; i++) {
        MP_DBG("MP:   iface[%u] id=%u type=0x%x maj=%u min=%u\n",
                i, vIfc[i].id, vIfc[i].intf_type,
                vIfc[i].devnode.major, vIfc[i].devnode.minor);
    }

    // ──── 打印所有 link 详情（关键调试）────
    for (unsigned int i = 0; i < topo.num_links; i++) {
        const char *ifl = (vLnk[i].flags & MEDIA_LNK_FL_INTERFACE_LINK) ? " IFACE" : "";
        const char *ena = (vLnk[i].flags & MEDIA_LNK_FL_ENABLED) ? " EN" : "";
        MP_DBG("MP:   link[%u] id=%u src=%u dst=%u flg=0x%x%s%s\n",
                i, vLnk[i].id, vLnk[i].source_id, vLnk[i].sink_id,
                vLnk[i].flags, ifl, ena);
    }

    // ──── INTERFACE_LINK: src=interface_id, dst=entity_id ────
    //   接口类型: 0x200=V4L video (/dev/video*), 0x203=V4L subdev (/dev/v4l-subdev*)
    //   一个 entity 可能有多个 interface，取第一个（最小 minor）
    QMap<unsigned int, int> entMajor, entMinor;
    QMap<unsigned int, bool> entIsV4LVideo;

    for (unsigned int i = 0; i < topo.num_links; i++) {
        if (!(vLnk[i].flags & MEDIA_LNK_FL_INTERFACE_LINK)) continue;

        unsigned int ifaceId = vLnk[i].source_id;
        unsigned int entityId = vLnk[i].sink_id;

        for (unsigned int j = 0; j < topo.num_interfaces; j++) {
            if (vIfc[j].id != ifaceId) continue;

            bool isVideo = ((vIfc[j].intf_type & 0xFF00) == MEDIA_INTF_T_V4L_BASE) &&
                           (vIfc[j].intf_type != MEDIA_INTF_T_V4L_SUBDEV);

            // 首次映射：直接记录
            if (!entMajor.contains(entityId)) {
                entMajor[entityId] = vIfc[j].devnode.major;
                entMinor[entityId] = vIfc[j].devnode.minor;
                entIsV4LVideo[entityId] = isVideo;
                MP_DBG("MP:   entity=%u → iface %u type=0x%x (%s) dev=%u:%u (first)\n",
                        entityId, ifaceId, vIfc[j].intf_type,
                        isVideo ? "VIDEO" : "SUBDEV",
                        vIfc[j].devnode.major, vIfc[j].devnode.minor);
            } else {
                MP_DBG("MP:   entity=%u → iface %u type=0x%x (%s) dev=%u:%u (skipped, already mapped to %u:%u)\n",
                        entityId, ifaceId, vIfc[j].intf_type,
                        isVideo ? "VIDEO" : "SUBDEV",
                        vIfc[j].devnode.major, vIfc[j].devnode.minor,
                        entMajor[entityId], entMinor[entityId]);
            }
        }
    }

    // ──── 转换实体 ────
    for (unsigned int i = 0; i < topo.num_entities; i++) {
        Entity e;
        e.id       = vEnt[i].id;
        e.name     = QString::fromUtf8(vEnt[i].name);
        e.function = vEnt[i].function;
        e.devMajor = entMajor.value(e.id, 0);
        e.devMinor = entMinor.value(e.id, 0);
        // isCapture = 有 V4L VIDEO 接口 (非 subdev)
        e.isCapture = entIsV4LVideo.value(e.id, false);
        ents.append(e);

        MP_DBG("MP:   ent[%u] id=%u '%s' dev=%d:%d %s\n",
                i, e.id, qPrintable(e.name), e.devMajor, e.devMinor,
                e.isCapture ? "CAPTURE" : "subdev");
    }

    // ──── 转换 pads ────
    for (unsigned int i = 0; i < topo.num_pads; i++) {
        pads.append({vPad[i].id, vPad[i].entity_id, vPad[i].flags, vPad[i].index});
        const char *dir = "?";
        if (vPad[i].flags & MEDIA_PAD_FL_SINK)   dir = "SINK";
        if (vPad[i].flags & MEDIA_PAD_FL_SOURCE) dir = "SRC";
        MP_DBG("MP:   pad[%u] id=%u ent=%u idx=%u flags=0x%x %s\n",
                i, vPad[i].id, vPad[i].entity_id, vPad[i].index, vPad[i].flags, dir);
    }

    // ──── 转换 links (只保留 pad 间的 link，跳过 INTERFACE_LINK) ────
    for (unsigned int i = 0; i < topo.num_links; i++) {
        if (vLnk[i].flags & MEDIA_LNK_FL_INTERFACE_LINK) continue;
        links.append({vLnk[i].id, vLnk[i].source_id, vLnk[i].sink_id, vLnk[i].flags});
        MP_DBG("MP:   plink[%d] id=%u %u→%u flg=0x%x\n",
                (int)links.size()-1, vLnk[i].id,
                vLnk[i].source_id, vLnk[i].sink_id, vLnk[i].flags);
    }

    return true;
}

// ============================================================================
// findSensor — 通过拓扑找 sensor (只有 SOURCE 输出，无 SINK 输入)
// ============================================================================
static int findSensor(const QVector<Entity> &ents,
                       const QVector<Pad> &pads,
                       const QVector<Link> &links)
{
    // 方法1: 找 subdev 实体中"只有 SOURCE 输出、没有 SINK 输入"的
    //       关键: 必须有 subdev 接口 (不是 V4L video 节点!)
    for (int ei = 0; ei < ents.size(); ei++) {
        if (ents[ei].isCapture) continue;          // 跳过 V4L video capture
        if (!ents[ei].devMajor && !ents[ei].devMinor) continue; // 必须有 device node (subdev)

        bool hasSourceOut = false;
        bool hasSinkIn    = false;

        for (const auto &p : pads) {
            if (p.entityId != ents[ei].id) continue;
            if (p.flags & MEDIA_PAD_FL_SOURCE) {
                for (const auto &l : links) {
                    if (l.srcId == p.id) { hasSourceOut = true; break; }
                }
            }
            if (p.flags & MEDIA_PAD_FL_SINK) {
                for (const auto &l : links) {
                    if (l.dstId == p.id) { hasSinkIn = true; break; }
                }
            }
        }

        if (hasSourceOut && !hasSinkIn) {
            MP_DBG("MP: sensor by topology: '%s' (id=%u)\n",
                    qPrintable(ents[ei].name), ents[ei].id);
            return ei;
        }
    }

    // 方法2: 匹配 I2C 设备名模式 "ov5640 0-003c"
    static const QRegularExpression i2cRe("\\b[a-z]+[0-9]+\\s+\\d+-[0-9a-f]{4}\\b");
    for (int ei = 0; ei < ents.size(); ei++) {
        if (ents[ei].isCapture) continue;
        if (ents[ei].name.contains(i2cRe)) {
            MP_DBG("MP: sensor by name: '%s' (id=%u)\n",
                    qPrintable(ents[ei].name), ents[ei].id);
            return ei;
        }
    }

    fprintf(stderr, "MP: no sensor found\n");
    return -1;
}

// ============================================================================
// setupAll
// ============================================================================
int MediaPipeline::setupAll(int desiredWidth, int desiredHeight)
{
    if (s_configured) { qDebug() << "MediaPipeline: already configured"; return 0; }
    s_configured = true;

    int n = 0;
    QDir d("/dev");
    QStringList nodes = d.entryList({"media*"}, QDir::System);
    std::sort(nodes.begin(), nodes.end(), [](auto &a, auto &b){ return a.mid(5).toInt() < b.mid(5).toInt(); });
    for (auto &nm : nodes) { if (setupMediaDevice("/dev/" + nm, desiredWidth, desiredHeight)) n++; }
    qDebug() << "MediaPipeline: configured" << n << "pipeline(s)";
    return n;
}

// ============================================================================
// setupMediaDevice
// ============================================================================
bool MediaPipeline::setupMediaDevice(const QString &node, int desiredW, int desiredH)
{
    int mfd = open(node.toUtf8().constData(), O_RDWR);
    if (mfd < 0) { qDebug() << "MP: open" << node << "err" << strerror(errno); return false; }

    struct media_device_info info; memset(&info, 0, sizeof(info));
    ioctl(mfd, MEDIA_IOC_DEVICE_INFO, &info);
    qDebug() << "MediaPipeline: scan" << node << info.driver << info.model;

    QVector<Entity> ents; QVector<Pad> pads; QVector<Link> links;
    if (!enumTopology(mfd, ents, pads, links)) { close(mfd); return false; }

    // 找 sensor
    int si = findSensor(ents, pads, links);
    if (si < 0) { qDebug() << "MP: no sensor → skip"; close(mfd); return false; }
    const Entity &sensor = ents[si];

    // 查找表
    QMap<unsigned int,int> eIdx;
    for (int i = 0; i < ents.size(); i++) eIdx[ents[i].id] = i;
    auto padOf=[&](unsigned int pid)->const Pad*{ for(auto&p:pads)if(p.id==pid)return&p; return nullptr; };

    // BFS: sensor → capture
    QQueue<unsigned int> q; QSet<unsigned int> vis;
    QMap<unsigned int, unsigned int> prevE;     // sink entity → src entity
    QMap<unsigned int, unsigned int> usedSrcPad; // sink entity → source pad id (from link)
    QMap<unsigned int, unsigned int> usedDstPad; // sink entity → sink pad id (from link)
    q.enqueue(sensor.id); vis.insert(sensor.id);
    int capIdx = -1;

    while (!q.isEmpty()) {
        unsigned int cid = q.dequeue();
        int ix = eIdx.value(cid, -1);
        if (ix >= 0 && ents[ix].isCapture) { capIdx = ix; break; }

        for (auto &lk : links) {
            const Pad *sp = padOf(lk.srcId);
            if (!sp || sp->entityId != cid) continue;
            const Pad *dp = padOf(lk.dstId);
            if (!dp || vis.contains(dp->entityId)) continue;

            // 如果链路未启用，启用它
            if (!(lk.flags & MEDIA_LNK_FL_ENABLED)) {
                struct media_link_desc ld; memset(&ld, 0, sizeof(ld));
                ld.source.entity = sp->entityId; ld.source.index = sp->index;
                ld.source.flags = MEDIA_PAD_FL_SOURCE;
                ld.sink.entity = dp->entityId; ld.sink.index = dp->index;
                ld.sink.flags = MEDIA_PAD_FL_SINK;
                ld.flags = MEDIA_LNK_FL_ENABLED;
                if (ioctl(mfd, MEDIA_IOC_SETUP_LINK, &ld) < 0)
                    fprintf(stderr, "MP: enable link err: %s\n", strerror(errno));
                else
                    MP_DBG("MP: enabled link %u:pad%u → %u:pad%u\n",
                            sp->entityId, sp->index, dp->entityId, dp->index);
            }

            vis.insert(dp->entityId);
            prevE[dp->entityId] = cid;
            usedSrcPad[dp->entityId] = lk.srcId;
            usedDstPad[dp->entityId] = lk.dstId;
            q.enqueue(dp->entityId);
            MP_DBG("MP: BFS %u→%u (pads: src=%u dst=%u)\n", cid, dp->entityId, lk.srcId, lk.dstId);
        }
    }

    if (capIdx < 0) { fprintf(stderr, "MP: NO V4L CAPTURE\n"); close(mfd); return false; }
    MP_DBG("MP: capture: '%s' id=%u\n", qPrintable(ents[capIdx].name), ents[capIdx].id);

    // 回溯路径，同时收集每段连接的 pad
    QVector<unsigned int> path;
    QVector<unsigned int> pathSrcPads; // 路径上每个跳转的 source pad id（不包括 capture）
    QVector<unsigned int> pathDstPads; // 路径上每个跳转的 sink pad id
    {
        unsigned int cur = ents[capIdx].id;
        while (true) {
            path.prepend(cur);
            if (cur == sensor.id) break;
            if (!prevE.contains(cur)) { fprintf(stderr, "MP: broken path\n"); close(mfd); return false; }
            unsigned int prev = prevE[cur];
            pathSrcPads.prepend(usedSrcPad[cur]);
            pathDstPads.prepend(usedDstPad[cur]);
            cur = prev;
        }
    }

    MP_DBG("MP: path (%d entities):", (int)path.size());
    for (int i = 0; i < path.size(); i++) {
        int ei = eIdx.value(path[i], -1);
        fprintf(stderr, " '%s'", ei >= 0 ? qPrintable(ents[ei].name) : "?");
    }
    fprintf(stderr, "\n");

    // ──── 构建路径上需要设格式的 pad 列表 ────
    // 规则（参考 myir_camera_preview 脚本）:
    //   - sensor SOURCE pad (数据起点)
    //   - 下游每个实体的 SINK pad
    //   - 不设: 中间实体的 SOURCE pad (驱动自动协商)
    //   - 不设: ISI SOURCE pad (不同格式域, ISI 内部转换)
    struct PathPad { int entIdx; int padIdx; };
    QVector<PathPad> fmtPath;
    // 按 entity 去重: 一个 subdev 在路径上可能有多个 pad, 但只取需要的
    QSet<int> addedEnts;

    for (int i = 0; i < path.size() - 1; i++) {
        int srcEi = eIdx.value(path[i], -1);
        int dstEi = eIdx.value(path[i+1], -1);
        if (srcEi < 0 || dstEi < 0) continue;

        // sensor (第一个实体): 加 SOURCE pad
        if (i == 0 && !ents[srcEi].isCapture && !addedEnts.contains(srcEi)) {
            const Pad *sp = padOf(pathSrcPads[i]);
            if (sp) { fmtPath.append({srcEi, (int)sp->index}); addedEnts.insert(srcEi); }
        }
        // 下游实体: 加 SINK pad
        if (!ents[dstEi].isCapture && !addedEnts.contains(dstEi)) {
            const Pad *dp = padOf(pathDstPads[i]);
            if (dp) { fmtPath.append({dstEi, (int)dp->index}); addedEnts.insert(dstEi); }
        }
    }

    MP_DBG("MP: pads on path:");
    for (auto &pp : fmtPath) fprintf(stderr, " '%s':%d", qPrintable(ents[pp.entIdx].name), pp.padIdx);
    fprintf(stderr, "\n");

    // ──── 计算格式交集 ────
    QVector<unsigned int> inter;
    for (auto &pp : fmtPath) {
        const Entity &e = ents[pp.entIdx];
        int sfd = openSubdev(e.devMajor, e.devMinor);
        if (sfd < 0) { fprintf(stderr, "MP: can't open '%s'\n", qPrintable(e.name)); continue; }
        QVector<unsigned int> pc = enumMbusCodes(sfd, pp.padIdx);
        MP_DBG("MP: '%s' pad%d → %d codes\n", qPrintable(e.name), pp.padIdx, (int)pc.size());
        close(sfd);
        if (pc.isEmpty()) continue;
        if (inter.isEmpty()) inter = pc;
        else { QVector<unsigned int> ni; for (auto c : inter) if (pc.contains(c)) ni.append(c); inter = ni; }
    }
    if (inter.isEmpty()) { fprintf(stderr, "MP: no common mbus code\n"); close(mfd); return false; }

    unsigned int chosen = bestMbusCode(inter);
    MP_DBG("MP: chosen mbus 0x%x (%d opt)\n", chosen, (int)inter.size());

    // ──── 设 subdev 格式 ────
    int aW = desiredW, aH = desiredH;
    QString vdevName;
    for (auto &pp : fmtPath) {
        const Entity &e = ents[pp.entIdx];
        int sfd = openSubdev(e.devMajor, e.devMinor);
        if (sfd < 0) continue;
        struct v4l2_subdev_format f; memset(&f, 0, sizeof(f));
        f.pad = pp.padIdx; f.which = V4L2_SUBDEV_FORMAT_ACTIVE;
        f.format.width = aW; f.format.height = aH; f.format.code = chosen; f.format.field = V4L2_FIELD_NONE;
        if (ioctl(sfd, VIDIOC_SUBDEV_S_FMT, &f) < 0) {
            fprintf(stderr, "MP: S_FMT err '%s' pad%d: %s\n", qPrintable(e.name), pp.padIdx, strerror(errno));
            close(sfd); continue;
        }
        memset(&f, 0, sizeof(f)); f.pad = pp.padIdx; f.which = V4L2_SUBDEV_FORMAT_ACTIVE;
        if (ioctl(sfd, VIDIOC_SUBDEV_G_FMT, &f) == 0) {
            int w = (int)f.format.width, h = (int)f.format.height;
            MP_DBG("MP: '%s' pad%d → %dx%d\n", qPrintable(e.name), pp.padIdx, w, h);
            if (w != aW || h != aH) { MP_DBG("MP: res adj %dx%d→%dx%d\n", aW, aH, w, h); aW = w; aH = h; }
        }
        close(sfd);
    }

    // 记录 capture 节点
    {
        const Entity &ce = ents[capIdx];
        vdevName = findVideoDevName(ce.devMajor, ce.devMinor);
        if (vdevName.isEmpty()) vdevName = "/dev/" + ce.name;
        MP_DBG("MP: capture node = %s\n", qPrintable(vdevName));
    }
    close(mfd);

    if (!vdevName.isEmpty() && aW > 0) {
        s_resolutions[vdevName] = {aW, aH};
        MP_DBG("MP: recorded %s = %dx%d\n", qPrintable(vdevName), aW, aH);
    }
    return true;
}

// ============================================================================
// getActualResolution
// ============================================================================
bool MediaPipeline::getActualResolution(const QString &vdev, int &w, int &h)
{
    if (s_resolutions.contains(vdev)) { w = s_resolutions[vdev].width; h = s_resolutions[vdev].height; return true; }
    return false;
}
