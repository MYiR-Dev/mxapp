/***********************************************************************
 *  MXAPP2 — 通用 CSI Camera Media Pipeline 初始化
 *
 *  自动发现 sensor→capture 路径，配置链路、routing、格式传播、
 *  ISI 缩放、capture 设备格式。不依赖任何平台特定硬编码。
 ***********************************************************************/

#include "mediapipeline.h"

#include <QLoggingCategory>
#include <QDir>
#include <QSet>
#include <QQueue>
#include <QRegularExpression>
#include <QStringList>

// 日志分类：mediapipeline 模块所有日志统一通过此 Category 输出
// 默认关闭调试日志（qCDebug），info/warning/critical 始终输出
// 运行时启用调试：QT_LOGGING_RULES="mediapipeline.debug=true" ./mxapp2
Q_LOGGING_CATEGORY(mpLog, "mediapipeline", QtInfoMsg)

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
#include <linux/media-bus-format.h>

// media-bus-format.h fallback (兼容老内核头文件)
#ifndef MEDIA_BUS_FMT_UYVY8_1X16
#define MEDIA_BUS_FMT_UYVY8_1X16        0x200f
#endif
#ifndef MEDIA_BUS_FMT_YUYV8_1X16
#define MEDIA_BUS_FMT_YUYV8_1X16        0x2011
#endif
#ifndef MEDIA_BUS_FMT_YUYV8_2X8
#define MEDIA_BUS_FMT_YUYV8_2X8         0x2008
#endif
#ifndef MEDIA_BUS_FMT_RGB565_1X16
#define MEDIA_BUS_FMT_RGB565_1X16       0x1017
#endif
#ifndef MEDIA_BUS_FMT_RGB888_1X24
#define MEDIA_BUS_FMT_RGB888_1X24       0x100a
#endif
#ifndef MEDIA_BUS_FMT_YUV8_1X24
#define MEDIA_BUS_FMT_YUV8_1X24         0x2025
#endif

// ============================================================================
// 静态成员
// ============================================================================
bool MediaPipeline::s_configured = false;
QMap<QString, MediaPipeline::PipelineConfig> MediaPipeline::s_configs;

// ============================================================================
// fallback 宏
// ============================================================================
#ifndef MEDIA_LNK_FL_ENABLED
#define MEDIA_LNK_FL_ENABLED         (1 << 0)
#endif
#ifndef MEDIA_LNK_FL_IMMUTABLE
#define MEDIA_LNK_FL_IMMUTABLE       (1 << 1)
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

// "旧编号"下 entity function 的基址
#ifndef MEDIA_ENT_F_OLD_BASE
#define MEDIA_ENT_F_OLD_BASE         0x00020000
#endif
#ifndef MEDIA_ENT_F_IO_V4L
#define MEDIA_ENT_F_IO_V4L           (MEDIA_ENT_F_OLD_BASE + 1)
#endif

// V4L2 Subdev Routing / Streams API fallback (兼容老内核头文件)
#ifndef V4L2_SUBDEV_CAP_STREAMS
#define V4L2_SUBDEV_CAP_STREAMS      (1 << 0)
#endif
#ifndef V4L2_SUBDEV_ROUTE_FL_ACTIVE
#define V4L2_SUBDEV_ROUTE_FL_ACTIVE  (1 << 0)
#endif
#ifndef VIDIOC_SUBDEV_G_ROUTING
struct v4l2_subdev_route {
    __u32 sink_pad;
    __u32 sink_stream;
    __u32 source_pad;
    __u32 source_stream;
    __u32 flags;
    __u32 reserved[5];
};
struct v4l2_subdev_routing {
    __u32 which;
    __u32 num_routes;
    __u64 routes;
    __u32 reserved[6];
};
#define VIDIOC_SUBDEV_G_ROUTING      _IOWR('V', 38, struct v4l2_subdev_routing)
#define VIDIOC_SUBDEV_S_ROUTING      _IOWR('V', 39, struct v4l2_subdev_routing)
#endif
#ifndef V4L2_SUBDEV_FORMAT_TRY
#define V4L2_SUBDEV_FORMAT_TRY       2
#endif

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

// 从多个 mbus code 中选最佳 (用于 subdev 链路格式)
static unsigned int bestMbusCode(const QVector<unsigned int> &codes)
{
    static const unsigned int pref[] = {
        MEDIA_BUS_FMT_UYVY8_1X16,
        MEDIA_BUS_FMT_YUYV8_1X16,
        MEDIA_BUS_FMT_YUYV8_2X8,
        MEDIA_BUS_FMT_RGB565_1X16,
        MEDIA_BUS_FMT_RGB888_1X24,
    };
    for (auto p : pref) if (codes.contains(p)) return p;
    return codes.first();
}

// 为 ISI/处理器的 SOURCE pad 选择输出 mbus code
// 优先 RGB → capture 端可直接输出 RGB24，零 CPU 转换
static unsigned int bestOutputMbusCode(const QVector<unsigned int> &codes)
{
    if (codes.contains(MEDIA_BUS_FMT_RGB888_1X24)) return MEDIA_BUS_FMT_RGB888_1X24;
    if (codes.contains(MEDIA_BUS_FMT_YUV8_1X24))  return MEDIA_BUS_FMT_YUV8_1X24;
    return codes.first();
}

// ============================================================================
// initSensorControls — 初始化 sensor V4L2 controls
//
// 对齐 libcamera CameraSensorLegacy::init():
//   1. 清除 HFLIP/VFLIP 确保正确的 Bayer 顺序
//   2. 设置 HBLANK 为最小值（确保明确的 line length）
//   3. 关闭 test pattern mode（确保正常图像输出）
// ============================================================================
static void initSensorControls(const MediaPipeline::TopoEntity &sensor)
{
    int sfd = openSubdev(sensor.devMajor, sensor.devMinor);
    if (sfd < 0) {
        qCDebug(mpLog, "MP: initSensorControls: can't open '%s'", qPrintable(sensor.name));
        return;
    }

    struct v4l2_control ctrl;
    memset(&ctrl, 0, sizeof(ctrl));

    // ① 清除 HFLIP / VFLIP
    ctrl.id = V4L2_CID_HFLIP;
    ctrl.value = 0;
    if (ioctl(sfd, VIDIOC_S_CTRL, &ctrl) == 0)
        qCDebug(mpLog, "MP: sensor '%s' HFLIP=0 OK", qPrintable(sensor.name));

    ctrl.id = V4L2_CID_VFLIP;
    ctrl.value = 0;
    if (ioctl(sfd, VIDIOC_S_CTRL, &ctrl) == 0)
        qCDebug(mpLog, "MP: sensor '%s' VFLIP=0 OK", qPrintable(sensor.name));

    // ② 尝试设置 HBLANK 为最小值
    struct v4l2_query_ext_ctrl qec;
    memset(&qec, 0, sizeof(qec));
    qec.id = V4L2_CID_HBLANK;
    if (ioctl(sfd, VIDIOC_QUERY_EXT_CTRL, &qec) == 0 &&
        !(qec.flags & V4L2_CTRL_FLAG_READ_ONLY)) {
        ctrl.id = V4L2_CID_HBLANK;
        ctrl.value = qec.minimum;
        if (ioctl(sfd, VIDIOC_S_CTRL, &ctrl) == 0)
            qCDebug(mpLog, "MP: sensor '%s' HBLANK=%lld (min) OK",
                   qPrintable(sensor.name), (long long)qec.minimum);
    }

    // ③ 关闭 test pattern mode
    memset(&qec, 0, sizeof(qec));
    qec.id = V4L2_CID_TEST_PATTERN;
    if (ioctl(sfd, VIDIOC_QUERY_EXT_CTRL, &qec) == 0) {
        ctrl.id = V4L2_CID_TEST_PATTERN;
        ctrl.value = 0;
        if (ioctl(sfd, VIDIOC_S_CTRL, &ctrl) == 0)
            qCDebug(mpLog, "MP: sensor '%s' TEST_PATTERN=0 OK", qPrintable(sensor.name));
    }

    close(sfd);
}

// ============================================================================
// enumTopology — G_TOPOLOGY 一次性枚举所有实体/pad/link/interface
//
// 完全通用：不依赖任何平台特定信息，
// 只使用 Linux Media Controller 标准 API MEDIA_IOC_G_TOPOLOGY。
// ============================================================================
static bool enumTopology(int mfd,
                          QVector<MediaPipeline::TopoEntity> &ents,
                          QVector<MediaPipeline::TopoPad>    &pads,
                          QVector<MediaPipeline::TopoLink>   &links)
{
    ents.clear(); pads.clear(); links.clear();

    // 第一轮：获取计数
    struct media_v2_topology topo;
    memset(&topo, 0, sizeof(topo));
    if (ioctl(mfd, MEDIA_IOC_G_TOPOLOGY, &topo) < 0) {
        qCCritical(mpLog, "MP: G_TOPOLOGY(count) err: %s", strerror(errno));
        return false;
    }

    unsigned int nEnt = topo.num_entities, nIfc = topo.num_interfaces,
                 nPad = topo.num_pads, nLnk = topo.num_links;

    qCDebug(mpLog, "MP: topology: entities=%u interfaces=%u pads=%u links=%u",
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
        qCCritical(mpLog, "MP: G_TOPOLOGY(data) err: %s", strerror(errno));
        return false;
    }

    // 调试：打印 interface 详情
    for (unsigned int i = 0; i < topo.num_interfaces; i++) {
        qCDebug(mpLog, "MP:   iface[%u] id=%u type=0x%x maj=%u min=%u",
                i, vIfc[i].id, vIfc[i].intf_type,
                vIfc[i].devnode.major, vIfc[i].devnode.minor);
    }

    // 调试：打印所有 link 详情
    for (unsigned int i = 0; i < topo.num_links; i++) {
        const char *ifl = (vLnk[i].flags & MEDIA_LNK_FL_INTERFACE_LINK) ? " IFACE" : "";
        const char *ena = (vLnk[i].flags & MEDIA_LNK_FL_ENABLED) ? " EN" : "";
        const char *imm = (vLnk[i].flags & MEDIA_LNK_FL_IMMUTABLE) ? " IMM" : "";
        qCDebug(mpLog, "MP:   link[%u] id=%u src=%u dst=%u flg=0x%x%s%s%s",
                i, vLnk[i].id, vLnk[i].source_id, vLnk[i].sink_id,
                vLnk[i].flags, ifl, ena, imm);
    }

    // INTERFACE_LINK: src=interface_id, dst=entity_id
    // 建立 entity → (major, minor, isVideoDevice) 的映射
    QMap<unsigned int, int> entMajor, entMinor;
    QMap<unsigned int, bool> entIsVideo;

    for (unsigned int i = 0; i < topo.num_links; i++) {
        if (!(vLnk[i].flags & MEDIA_LNK_FL_INTERFACE_LINK)) continue;

        unsigned int ifaceId = vLnk[i].source_id;
        unsigned int entityId = vLnk[i].sink_id;

        for (unsigned int j = 0; j < topo.num_interfaces; j++) {
            if (vIfc[j].id != ifaceId) continue;

            bool isVideo = ((vIfc[j].intf_type & 0xFF00) == MEDIA_INTF_T_V4L_BASE) &&
                           (vIfc[j].intf_type != MEDIA_INTF_T_V4L_SUBDEV);

            if (!entMajor.contains(entityId)) {
                entMajor[entityId] = vIfc[j].devnode.major;
                entMinor[entityId] = vIfc[j].devnode.minor;
                entIsVideo[entityId] = isVideo;
            }
        }
    }

    // 转换实体
    for (unsigned int i = 0; i < topo.num_entities; i++) {
        MediaPipeline::TopoEntity e;
        e.id       = vEnt[i].id;
        e.name     = QString::fromUtf8(vEnt[i].name);
        e.function = vEnt[i].function;
        e.devMajor = entMajor.value(e.id, 0);
        e.devMinor = entMinor.value(e.id, 0);
        e.isVideoDevice = entIsVideo.value(e.id, false);
        ents.append(e);

        qCDebug(mpLog, "MP:   ent[%u] id=%u '%s' dev=%d:%d %s func=0x%x",
                i, e.id, qPrintable(e.name), e.devMajor, e.devMinor,
                e.isVideoDevice ? "VIDEO" : "subdev", e.function);
    }

    // 转换 pads
    for (unsigned int i = 0; i < topo.num_pads; i++) {
        MediaPipeline::TopoPad p;
        p.id       = vPad[i].id;
        p.entityId = vPad[i].entity_id;
        p.flags    = vPad[i].flags;
        p.index    = vPad[i].index;
        pads.append(p);

        const char *dir = "?";
        if (p.flags & MEDIA_PAD_FL_SINK)   dir = "SINK";
        if (p.flags & MEDIA_PAD_FL_SOURCE) dir = "SRC";
        qCDebug(mpLog, "MP:   pad[%u] id=%u ent=%u idx=%u flg=0x%x %s",
                i, p.id, p.entityId, p.index, p.flags, dir);
    }

    // 转换 links (只保留 pad 间的 link，跳过 INTERFACE_LINK)
    for (unsigned int i = 0; i < topo.num_links; i++) {
        if (vLnk[i].flags & MEDIA_LNK_FL_INTERFACE_LINK) continue;
        MediaPipeline::TopoLink l;
        l.id    = vLnk[i].id;
        l.srcId = vLnk[i].source_id;
        l.dstId = vLnk[i].sink_id;
        l.flags = vLnk[i].flags;
        links.append(l);
    }

    qCDebug(mpLog, "MP: parsed: %d entities, %d pads, %d links",
            (int)ents.size(), (int)pads.size(), (int)links.size());
    return true;
}

// ============================================================================
// findSensor — 通用 sensor 发现
//
// 策略优先级（从最可靠到最不可靠）：
//   1. entity function == MEDIA_ENT_F_CAM_SENSOR (标准 V4L2 定义)
//   2. 只有 SOURCE 输出、无 SINK 输入的 subdev（拓扑叶子节点）
//   3. I2C 设备名匹配 "/sensor_name bus-addr"
// ============================================================================
static int findSensor(const QVector<MediaPipeline::TopoEntity> &ents,
                       const QVector<MediaPipeline::TopoPad> &pads,
                       const QVector<MediaPipeline::TopoLink> &links)
{
    // 策略 1: 按标准 V4L2 entity function 匹配
    // MEDIA_ENT_F_CAM_SENSOR 由 linux/media.h 定义为 (MEDIA_ENT_F_OLD_SUBDEV_BASE + 1)
    for (int ei = 0; ei < ents.size(); ei++) {
        if (ents[ei].function == MEDIA_ENT_F_CAM_SENSOR) {
            qCDebug(mpLog, "MP: sensor by function: '%s' (id=%u)",
                    qPrintable(ents[ei].name), ents[ei].id);
            return ei;
        }
    }

    // 策略 2: 拓扑叶子节点 — 只有 SOURCE 输出、没有 SINK 输入的 subdev
    for (int ei = 0; ei < ents.size(); ei++) {
        if (ents[ei].isVideoDevice) continue;
        if (!ents[ei].devMajor && !ents[ei].devMinor) continue;

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
            qCDebug(mpLog, "MP: sensor by topology (leaf): '%s' (id=%u)",
                    qPrintable(ents[ei].name), ents[ei].id);
            return ei;
        }
    }

    // 策略 3: I2C 设备名模式匹配
    static const QRegularExpression i2cRe("\\b[a-z]+[0-9]+\\s+\\d+-[0-9a-f]{4}\\b");
    for (int ei = 0; ei < ents.size(); ei++) {
        if (ents[ei].isVideoDevice) continue;
        if (ents[ei].name.contains(i2cRe)) {
            qCDebug(mpLog, "MP: sensor by I2C name: '%s' (id=%u)",
                    qPrintable(ents[ei].name), ents[ei].id);
            return ei;
        }
    }

    qCInfo(mpLog, "MP: no sensor found");
    return -1;
}

// ============================================================================
// buildPath — 通用 BFS 路径发现
//
// 从 sensor 出发，通过 pad→pad link 遍历 media graph，
// 找到到达 capture video device 的最短路径。
// ============================================================================
static bool buildPath(const QVector<MediaPipeline::TopoEntity> &entities,
                       const QVector<MediaPipeline::TopoPad> &pads,
                       const QVector<MediaPipeline::TopoLink> &links,
                       int sensorIdx,
                       QVector<MediaPipeline::PathHop> &path,
                       int &captureIdx)
{
    path.clear();
    captureIdx = -1;

    QMap<unsigned int,int> eIdx;
    for (int i = 0; i < entities.size(); i++)
        eIdx[entities[i].id] = i;

    auto padById = [&](unsigned int pid) -> const MediaPipeline::TopoPad* {
        for (auto &p : pads) if (p.id == pid) return &p;
        return nullptr;
    };

    // BFS
    QQueue<unsigned int> q;
    QSet<unsigned int> vis;
    QMap<unsigned int, unsigned int> prevEnt;
    QMap<unsigned int, unsigned int> srcPadOf;
    QMap<unsigned int, unsigned int> dstPadOf;

    q.enqueue(entities[sensorIdx].id);
    vis.insert(entities[sensorIdx].id);

    while (!q.isEmpty()) {
        unsigned int curId = q.dequeue();
        int curIdx = eIdx.value(curId, -1);
        if (curIdx >= 0 && entities[curIdx].isVideoDevice) {
            captureIdx = curIdx;
            break;
        }

        for (auto &lk : links) {
            const MediaPipeline::TopoPad *sp = padById(lk.srcId);
            if (!sp || sp->entityId != curId) continue;
            const MediaPipeline::TopoPad *dp = padById(lk.dstId);
            if (!dp || vis.contains(dp->entityId)) continue;

            vis.insert(dp->entityId);
            prevEnt[dp->entityId] = curId;
            srcPadOf[dp->entityId] = lk.srcId;
            dstPadOf[dp->entityId] = lk.dstId;
            q.enqueue(dp->entityId);
        }
    }

    if (captureIdx < 0) {
        qCWarning(mpLog, "MP: no video capture device found in graph");
        return false;
    }

    // 回溯构建路径
    unsigned int cur = entities[captureIdx].id;
    unsigned int sensorId = entities[sensorIdx].id;

    while (cur != sensorId) {
        if (!prevEnt.contains(cur)) {
            qCWarning(mpLog, "MP: broken path during backtrack");
            return false;
        }
        unsigned int prev = prevEnt[cur];

        MediaPipeline::PathHop hop;
        hop.srcEntIdx = eIdx.value(prev, -1);
        hop.dstEntIdx = eIdx.value(cur, -1);
        hop.srcPadId  = srcPadOf[cur];
        hop.dstPadId  = dstPadOf[cur];

        for (auto &lk : links) {
            if (lk.srcId == hop.srcPadId && lk.dstId == hop.dstPadId) {
                hop.link = &lk;
                break;
            }
        }

        path.prepend(hop);
        cur = prev;
    }

    // 调试输出
    QStringList pathParts;
    for (int i = 0; i < path.size(); i++) {
        const auto &h = path[i];
        const MediaPipeline::TopoPad *sp = padById(h.srcPadId);
        const MediaPipeline::TopoPad *dp = padById(h.dstPadId);
        pathParts << QString("'%1':%2→'%3':%4")
                         .arg(entities[h.srcEntIdx].name)
                         .arg(sp ? (int)sp->index : -1)
                         .arg(entities[h.dstEntIdx].name)
                         .arg(dp ? (int)dp->index : -1);
    }
    qCInfo(mpLog, "MP: path (%d hops): %s", (int)path.size(),
           qPrintable(pathParts.join(' ')));

    return true;
}

// ============================================================================
// enableLinks — 通用链路使能
//
// 使能 sensor→capture 路径上所有未启用的 link。
// 跳过 MEDIA_LNK_FL_IMMUTABLE 的 link（硬件固定不可修改）。
// ============================================================================
static int enableLinks(int mediaFd,
                        const QVector<MediaPipeline::TopoEntity> &entities,
                        const QVector<MediaPipeline::TopoPad> &pads,
                        const QVector<MediaPipeline::PathHop> &path)
{
    auto padById = [&](unsigned int pid) -> const MediaPipeline::TopoPad* {
        for (auto &p : pads) if (p.id == pid) return &p;
        return nullptr;
    };

    for (int i = 0; i < path.size(); i++) {
        const auto &hop = path[i];
        if (!hop.link) continue;

        // 跳过 IMMUTABLE 链路
        if (hop.link->flags & MEDIA_LNK_FL_IMMUTABLE) {
            qCDebug(mpLog, "MP: link %d (id=%u) is IMMUTABLE, skipping", i, hop.link->id);
            continue;
        }

        // 跳过已启用的链路
        if (hop.link->flags & MEDIA_LNK_FL_ENABLED) {
            qCDebug(mpLog, "MP: link %d (id=%u) already enabled", i, hop.link->id);
            continue;
        }

        const MediaPipeline::TopoPad *sp = padById(hop.srcPadId);
        const MediaPipeline::TopoPad *dp = padById(hop.dstPadId);
        if (!sp || !dp) {
            qCWarning(mpLog, "MP: pad not found for hop %d", i);
            return -1;
        }

        struct media_link_desc ld;
        memset(&ld, 0, sizeof(ld));
        ld.source.entity = entities[hop.srcEntIdx].id;
        ld.source.index  = sp->index;
        ld.source.flags  = MEDIA_PAD_FL_SOURCE;
        ld.sink.entity   = entities[hop.dstEntIdx].id;
        ld.sink.index    = dp->index;
        ld.sink.flags    = MEDIA_PAD_FL_SINK;
        ld.flags         = MEDIA_LNK_FL_ENABLED;

        if (ioctl(mediaFd, MEDIA_IOC_SETUP_LINK, &ld) < 0) {
            qCWarning(mpLog, "MP: enable link failed: %s→%s: %s",
                     qPrintable(entities[hop.srcEntIdx].name),
                     qPrintable(entities[hop.dstEntIdx].name),
                     strerror(errno));
            return -errno;
        }

        qCDebug(mpLog, "MP: enabled link %d: '%s':%d→'%s':%d", i,
                qPrintable(entities[hop.srcEntIdx].name), sp->index,
                qPrintable(entities[hop.dstEntIdx].name), dp->index);
    }

    return 0;
}

// ============================================================================
// configureRoutingIfNeeded — 通用 routing 配置
//
// 检测路径上每个 subdev 是否支持 V4L2 streams API。
// 如果支持，自动配置内部路由（如 crossbar 的 sink_pad→source_pad）。
// 这是修复 i.MX95 STREAMON EPIPE 的关键步骤。
// ============================================================================
static int configureRoutingIfNeeded(int mediaFd,
                                     const QVector<MediaPipeline::TopoEntity> &entities,
                                     const QVector<MediaPipeline::TopoPad> &pads,
                                     const QVector<MediaPipeline::PathHop> &path,
                                     int captureIdx)
{
    (void)mediaFd;
    (void)captureIdx;

    auto padById = [&](unsigned int pid) -> const MediaPipeline::TopoPad* {
        for (auto &p : pads) if (p.id == pid) return &p;
        return nullptr;
    };

    QSet<unsigned int> processed;

    for (int i = 0; i < path.size(); i++) {
        const auto &hop = path[i];
        int entIdx = hop.dstEntIdx;

        // 跳过 capture video device
        if (entities[entIdx].isVideoDevice) continue;
        // 避免重复处理
        if (processed.contains(entities[entIdx].id)) continue;
        // 跳过没有 device node 的 entity
        if (!entities[entIdx].devMajor && !entities[entIdx].devMinor) continue;

        processed.insert(entities[entIdx].id);

        int sfd = openSubdev(entities[entIdx].devMajor, entities[entIdx].devMinor);
        if (sfd < 0) {
            qCDebug(mpLog, "MP: configureRouting: can't open '%s'",
                   qPrintable(entities[entIdx].name));
            continue;
        }

        // 检测是否支持 streams API
        bool hasStreams = false;
        {
            struct v4l2_subdev_capability caps;
            memset(&caps, 0, sizeof(caps));
            if (ioctl(sfd, VIDIOC_SUBDEV_QUERYCAP, &caps) == 0) {
                if (caps.capabilities & V4L2_SUBDEV_CAP_STREAMS) {
                    hasStreams = true;
                    qCDebug(mpLog, "MP: '%s' has STREAMS cap, needs routing",
                           qPrintable(entities[entIdx].name));
                }
            }
        }

        if (!hasStreams) {
            qCDebug(mpLog, "MP: '%s' no routing needed", qPrintable(entities[entIdx].name));
            close(sfd);
            continue;
        }

        // 找到该 entity 在路径上的 sink pad 和 source pad
        int pathSinkPad = -1, pathSrcPad = -1;
        for (int j = 0; j < path.size(); j++) {
            if (path[j].dstEntIdx == entIdx) {
                const MediaPipeline::TopoPad *dp = padById(path[j].dstPadId);
                if (dp) pathSinkPad = (int)dp->index;
            }
            if (path[j].srcEntIdx == entIdx) {
                const MediaPipeline::TopoPad *sp = padById(path[j].srcPadId);
                if (sp) pathSrcPad = (int)sp->index;
            }
        }

        if (pathSinkPad < 0 || pathSrcPad < 0) {
            qCDebug(mpLog, "MP: '%s' can't determine path pads (sink=%d src=%d), skip",
                   qPrintable(entities[entIdx].name), pathSinkPad, pathSrcPad);
            close(sfd);
            continue;
        }

        // 构造路由：sink_pad:stream0 → source_pad:stream0
        struct v4l2_subdev_route route;
        memset(&route, 0, sizeof(route));
        route.sink_pad    = (__u32)pathSinkPad;
        route.sink_stream = 0;
        route.source_pad  = (__u32)pathSrcPad;
        route.source_stream = 0;
        route.flags       = V4L2_SUBDEV_ROUTE_FL_ACTIVE;

        struct v4l2_subdev_routing rt;
        memset(&rt, 0, sizeof(rt));
        rt.which      = V4L2_SUBDEV_FORMAT_ACTIVE;
        rt.routes     = (__u64)(uintptr_t)&route;
        rt.num_routes = 1;
#ifdef VIDIOC_SUBDEV_S_ROUTING
        rt.len_routes = 1;
#endif

        if (ioctl(sfd, VIDIOC_SUBDEV_S_ROUTING, &rt) < 0) {
            qCWarning(mpLog, "MP: S_ROUTING failed on %s sink_pad%d→src_pad%d: %s",
                     qPrintable(entities[entIdx].name), pathSinkPad, pathSrcPad,
                     strerror(errno));
            close(sfd);
            return -errno;
        }

        qCInfo(mpLog, "MP: routing set on '%s': pad%d/0→pad%d/0 (ACTIVE)",
               qPrintable(entities[entIdx].name), pathSinkPad, pathSrcPad);
        close(sfd);
    }

    return 0;
}

// ============================================================================
// propagateFormats — 通用逐级格式传播
//
// 从 sensor SOURCE pad 开始，沿路径逐级传播格式：
//   1. 读取 sensor SOURCE pad 当前格式
//   2. 枚举 sink pad mbus codes，做 code 预处理
//   3. TRY format on sink_pad → 读回 driver 调整结果
//   4. ACTIVE format on sink_pad
//   5. 继续下一跳
//
// 路径最后一段是 proc entity → capture：
//   对 proc entity 额外处理 COMPOSE 缩放和 SOURCE pad 格式。
// ============================================================================
static int propagateFormats(int mediaFd,
                             const QVector<MediaPipeline::TopoEntity> &entities,
                             const QVector<MediaPipeline::TopoPad> &pads,
                             const QVector<MediaPipeline::PathHop> &path,
                             int desiredW, int desiredH,
                             MediaPipeline::PipelineConfig &result)
{
    (void)mediaFd;

    int currentW = desiredW;
    int currentH = desiredH;

    auto padById = [&](unsigned int pid) -> const MediaPipeline::TopoPad* {
        for (auto &p : pads) if (p.id == pid) return &p;
        return nullptr;
    };

    // ---- 第 1 步：从 sensor SOURCE pad 读取当前格式 ----
    int sensorIdx = path[0].srcEntIdx;
    const MediaPipeline::TopoPad *firstSrcPad = padById(path[0].srcPadId);
    uint32_t currentCode = 0;

    {
        int sfd = openSubdev(entities[sensorIdx].devMajor, entities[sensorIdx].devMinor);
        if (sfd >= 0) {
            if (firstSrcPad) {
                struct v4l2_subdev_format f;
                memset(&f, 0, sizeof(f));
                f.pad   = firstSrcPad->index;
                f.which = V4L2_SUBDEV_FORMAT_ACTIVE;
                if (ioctl(sfd, VIDIOC_SUBDEV_G_FMT, &f) == 0) {
                    currentCode = f.format.code;
                    // ★ 只取 sensor 的 mbus code，分辨率用调用方指定的 desiredW×desiredH
                    // sensor 默认分辨率（如 640x480）不应覆盖用户期望值（如 1280x720）
                    qCInfo(mpLog, "MP: sensor '%s':%d mbus=0x%x (request %dx%d)",
                            qPrintable(entities[sensorIdx].name),
                            firstSrcPad->index, currentCode, currentW, currentH);
                }
            }
            close(sfd);
        }
    }

    if (currentCode == 0) {
        currentCode = MEDIA_BUS_FMT_UYVY8_1X16;  // fallback
        qCInfo(mpLog, "MP: using default mbus code 0x%x", currentCode);
    }

    // 找到连接到 capture 的 SOURCE pad（ISI SOURCE，单独在 step 3 处理）
    unsigned int isiSrcPadId = 0;
    if (!path.isEmpty()) {
        int last = path.size() - 1;
        if (entities[path[last].dstEntIdx].isVideoDevice)
            isiSrcPadId = path[last].srcPadId;
    }

    // ---- 第 1.5 步：预计算全路径 mbus code 交集 ----
    // 枚举路径上所有 SINK + SOURCE pad（不含 ISI SOURCE），取交集
    // ★ 对齐旧实现的交集算法 — V4L2 G_FMT 返回已存值不是支持列表，
    //    逐级 TRY→ACTIVE 只验证 SINK 接受格式，不验证 SOURCE 能否输出
    {

        QVector<unsigned int> intersection;
        bool first = true;

        for (int i = 0; i < path.size(); i++) {
            const auto &hop = path[i];
            int srcEi = hop.srcEntIdx;
            int dstEi = hop.dstEntIdx;

            if (entities[dstEi].isVideoDevice) break;

            int sfd = openSubdev(entities[dstEi].devMajor, entities[dstEi].devMinor);
            if (sfd < 0) continue;

            // ① 下游 SINK pad
            const MediaPipeline::TopoPad *dp = padById(hop.dstPadId);
            if (dp) {
                QVector<unsigned int> codes = enumMbusCodes(sfd, dp->index);
                if (!codes.isEmpty()) {
                    if (first) { intersection = codes; first = false; }
                    else { QVector<unsigned int> ni; for (auto c : intersection) if (codes.contains(c)) ni.append(c); intersection = ni; }
                }
            }

            // ② 上游 SOURCE pad（排除 ISI SOURCE）
            const MediaPipeline::TopoPad *sp = padById(hop.srcPadId);
            if (sp && hop.srcPadId != isiSrcPadId) {
                // 用 src entity 的 subdev 枚举（source pad 属于上游 entity）
                int srcSfd = openSubdev(entities[srcEi].devMajor, entities[srcEi].devMinor);
                if (srcSfd >= 0) {
                    QVector<unsigned int> codes = enumMbusCodes(srcSfd, sp->index);
                    if (!codes.isEmpty()) {
                        if (first) { intersection = codes; first = false; }
                        else { QVector<unsigned int> ni; for (auto c : intersection) if (codes.contains(c)) ni.append(c); intersection = ni; }
                    }
                    close(srcSfd);
                }
            }

            close(sfd);
        }

        if (!first && !intersection.isEmpty()) {
            unsigned int best = bestMbusCode(intersection);
            qCInfo(mpLog, "MP: intersection pre-filter: 0x%x → 0x%x (%d codes in common)",
                    currentCode, best, (int)intersection.size());
            currentCode = best;
        }
    }

    // ---- 第 2 步：逐级传播 ----
    for (int i = 0; i < path.size(); i++) {
        const auto &hop = path[i];
        const MediaPipeline::TopoPad *sp = padById(hop.srcPadId);
        const MediaPipeline::TopoPad *dp = padById(hop.dstPadId);

        if (!sp || !dp) continue;

        int dstEntIdx = hop.dstEntIdx;

        // 跳过 capture device — 最后单独处理
        if (entities[dstEntIdx].isVideoDevice) break;

        int sfd = openSubdev(entities[dstEntIdx].devMajor, entities[dstEntIdx].devMinor);
        if (sfd < 0) {
            qCDebug(mpLog, "MP: can't open subdev '%s', skip hop",
                   qPrintable(entities[dstEntIdx].name));
            continue;
        }

        // --- 2a. 枚举 sink pad mbus codes，做 code 预处理 ---
        {
            QVector<unsigned int> sinkCodes = enumMbusCodes(sfd, dp->index);
            if (!sinkCodes.isEmpty() && !sinkCodes.contains(currentCode)) {
                uint32_t best = bestMbusCode(sinkCodes);
                qCDebug(mpLog, "MP: sink '%s':%d doesn't support 0x%x, switching to 0x%x",
                        qPrintable(entities[dstEntIdx].name), dp->index,
                        currentCode, best);
                currentCode = best;
            }
        }

        // --- 2b. TRY format on sink pad ---
        {
            struct v4l2_subdev_format f;
            memset(&f, 0, sizeof(f));
            f.pad         = dp->index;
            f.which       = V4L2_SUBDEV_FORMAT_TRY;
            f.format.width  = currentW;
            f.format.height = currentH;
            f.format.code   = currentCode;
            f.format.field  = V4L2_FIELD_NONE;

            if (ioctl(sfd, VIDIOC_SUBDEV_S_FMT, &f) >= 0) {
                memset(&f, 0, sizeof(f));
                f.pad   = dp->index;
                f.which = V4L2_SUBDEV_FORMAT_TRY;
                if (ioctl(sfd, VIDIOC_SUBDEV_G_FMT, &f) == 0) {
                    currentW    = (int)f.format.width;
                    currentH    = (int)f.format.height;
                    currentCode = f.format.code;
                    qCDebug(mpLog, "MP: TRY '%s':%d → 0x%x %dx%d",
                            qPrintable(entities[dstEntIdx].name), dp->index,
                            currentCode, currentW, currentH);
                }
            }
        }

        // --- 2c. ACTIVE format on sink pad ---
        {
            struct v4l2_subdev_format f;
            memset(&f, 0, sizeof(f));
            f.pad         = dp->index;
            f.which       = V4L2_SUBDEV_FORMAT_ACTIVE;
            f.format.width  = currentW;
            f.format.height = currentH;
            f.format.code   = currentCode;
            f.format.field  = V4L2_FIELD_NONE;

            if (ioctl(sfd, VIDIOC_SUBDEV_S_FMT, &f) < 0) {
                qCCritical(mpLog, "MP: ACTIVE S_FMT failed on %s pad%d: %s",
                         qPrintable(entities[dstEntIdx].name), dp->index,
                         strerror(errno));
                close(sfd);
                return -errno;
            }

            memset(&f, 0, sizeof(f));
            f.pad   = dp->index;
            f.which = V4L2_SUBDEV_FORMAT_ACTIVE;
            if (ioctl(sfd, VIDIOC_SUBDEV_G_FMT, &f) == 0) {
                currentW    = (int)f.format.width;
                currentH    = (int)f.format.height;
                currentCode = f.format.code;
                qCInfo(mpLog, "MP: '%s':%d ← 0x%x %dx%d",
                        qPrintable(entities[dstEntIdx].name), dp->index,
                        currentCode, currentW, currentH);
            }

            // ★ v3: S_FMT ACTIVE on SOURCE pad（src entity 的 hop.srcPadId）
            // 驱动不会自动从 SINK 传播格式到 SOURCE——必须显式写入
            // 旧实现的 fmtPath 包含所有 SOURCE pad，每个都调了 S_FMT
            {
                bool isProcSrc = (hop.srcPadId == isiSrcPadId);
                int srcEntIdx = hop.srcEntIdx;
                if (!isProcSrc && entities[srcEntIdx].devMajor != 0) {
                    int srcSfd = openSubdev(entities[srcEntIdx].devMajor, entities[srcEntIdx].devMinor);
                    if (srcSfd >= 0) {
                        struct v4l2_subdev_format sfmt;
                        memset(&sfmt, 0, sizeof(sfmt));
                        sfmt.pad         = sp->index;
                        sfmt.which       = V4L2_SUBDEV_FORMAT_ACTIVE;
                        sfmt.format.width  = currentW;
                        sfmt.format.height = currentH;
                        sfmt.format.code   = currentCode;
                        sfmt.format.field  = V4L2_FIELD_NONE;
                        if (ioctl(srcSfd, VIDIOC_SUBDEV_S_FMT, &sfmt) == 0) {
                            memset(&sfmt, 0, sizeof(sfmt));
                            sfmt.pad   = sp->index;
                            sfmt.which = V4L2_SUBDEV_FORMAT_ACTIVE;
                            ioctl(srcSfd, VIDIOC_SUBDEV_G_FMT, &sfmt);
                            qCInfo(mpLog, "MP: '%s':%d SOURCE ← 0x%x %dx%d",
                                    qPrintable(entities[srcEntIdx].name), sp->index,
                                    sfmt.format.code, sfmt.format.width, sfmt.format.height);
                        }
                        close(srcSfd);
                    }
                }
            }

            // ★ 读取同一 entity 的 SOURCE pad 格式
            // SINK pad 接受的格式，SOURCE pad 未必能输出（如 csidev SOURCE 只支持 UYVY8_1X16）
            // 以 SOURCE pad 实际格式为准传播到下一跳
            const MediaPipeline::TopoPad *srcPad = nullptr;
            for (auto &p : pads) {
                if (p.entityId == entities[dstEntIdx].id &&
                    (p.flags & MEDIA_PAD_FL_SOURCE)) {
                    srcPad = &p;
                    break;
                }
            }
            if (srcPad) {
                struct v4l2_subdev_format srcFmt;
                memset(&srcFmt, 0, sizeof(srcFmt));
                srcFmt.pad   = srcPad->index;
                srcFmt.which = V4L2_SUBDEV_FORMAT_ACTIVE;
                if (ioctl(sfd, VIDIOC_SUBDEV_G_FMT, &srcFmt) == 0) {
                    if (srcFmt.format.code != currentCode ||
                        srcFmt.format.width != currentW ||
                        srcFmt.format.height != currentH) {
                        qCInfo(mpLog, "MP: '%s':%d SOURCE → 0x%x %dx%d (was: 0x%x)",
                                qPrintable(entities[dstEntIdx].name), srcPad->index,
                                srcFmt.format.code, srcFmt.format.width, srcFmt.format.height,
                                currentCode);
                        currentCode = srcFmt.format.code;
                        currentW    = (int)srcFmt.format.width;
                        currentH    = (int)srcFmt.format.height;
                    }
                }
            }
        }

        close(sfd);
    }

    // ---- 第 3 步：处理最后一级 subdev (proc/ISI) ----
    {
        int procIdx = -1;
        int procSrcPadIdx = -1;
        int procSinkPadIdx = -1;

        for (int i = path.size() - 1; i >= 0; i--) {
            if (!entities[path[i].srcEntIdx].isVideoDevice) {
                procIdx = path[i].srcEntIdx;
                const MediaPipeline::TopoPad *sp = padById(path[i].srcPadId);
                if (sp) procSrcPadIdx = sp->index;
                for (int j = 0; j < path.size(); j++) {
                    if (path[j].dstEntIdx == procIdx) {
                        const MediaPipeline::TopoPad *dp = padById(path[j].dstPadId);
                        if (dp) procSinkPadIdx = dp->index;
                        break;
                    }
                }
                break;
            }
        }

        if (procIdx >= 0 && procSinkPadIdx >= 0 && procSrcPadIdx >= 0) {
            int sfd = openSubdev(entities[procIdx].devMajor, entities[procIdx].devMinor);
            if (sfd >= 0) {
                // 3a. COMPOSE on SINK pad（缩放）
                {
                    struct v4l2_subdev_selection sel;
                    memset(&sel, 0, sizeof(sel));
                    sel.pad    = procSinkPadIdx;
                    sel.which  = V4L2_SUBDEV_FORMAT_ACTIVE;
                    sel.target = V4L2_SEL_TGT_COMPOSE;
                    sel.r.left   = 0;
                    sel.r.top    = 0;
                    sel.r.width  = currentW;
                    sel.r.height = currentH;
                    sel.flags = 0;

                    if (ioctl(sfd, VIDIOC_SUBDEV_S_SELECTION, &sel) < 0) {
                        qCDebug(mpLog, "MP: COMPOSE on '%s':%d not supported: %s",
                                qPrintable(entities[procIdx].name),
                                procSinkPadIdx, strerror(errno));
                    } else {
                        qCInfo(mpLog, "MP: '%s' COMPOSE pad%d → %dx%d",
                                qPrintable(entities[procIdx].name),
                                procSinkPadIdx, currentW, currentH);
                    }
                }

                // 3b. 设置 SOURCE pad 格式（可能在不同格式域）
                {
                    QVector<unsigned int> srcCodes = enumMbusCodes(sfd, procSrcPadIdx);
                    uint32_t srcCode = currentCode;
                    if (!srcCodes.isEmpty()) {
                        srcCode = bestOutputMbusCode(srcCodes);
                    }

                    struct v4l2_subdev_format f;
                    memset(&f, 0, sizeof(f));
                    f.pad         = procSrcPadIdx;
                    f.which       = V4L2_SUBDEV_FORMAT_ACTIVE;
                    f.format.width  = currentW;
                    f.format.height = currentH;
                    f.format.code   = srcCode;
                    f.format.field  = V4L2_FIELD_NONE;

                    if (ioctl(sfd, VIDIOC_SUBDEV_S_FMT, &f) < 0) {
                        qCWarning(mpLog, "MP: proc SRC S_FMT failed on %s pad%d: %s",
                                 qPrintable(entities[procIdx].name),
                                 procSrcPadIdx, strerror(errno));
                    } else {
                        memset(&f, 0, sizeof(f));
                        f.pad   = procSrcPadIdx;
                        f.which = V4L2_SUBDEV_FORMAT_ACTIVE;
                        ioctl(sfd, VIDIOC_SUBDEV_G_FMT, &f);
                        qCInfo(mpLog, "MP: '%s' SRC pad%d → code=0x%x %dx%d",
                                qPrintable(entities[procIdx].name),
                                procSrcPadIdx, f.format.code,
                                f.format.width, f.format.height);
                        currentCode = f.format.code;
                        currentW    = (int)f.format.width;
                        currentH    = (int)f.format.height;
                    }
                }

                close(sfd);
            }
        }
    }

    // ---- 第 4 步：填充结果 ----
    result.width  = currentW;
    result.height = currentH;
    result.mbusCode = currentCode;
    result.valid  = (currentW > 0 && currentH > 0);

    return 0;
}

// ============================================================================
// setupMediaDevice — 配置单个 /dev/mediaX 设备
//
// 阶段步骤：
//   1. 打开 media 设备，读取 driver info
//   2. 枚举拓扑 (G_TOPOLOGY)
//   3. 找 sensor (findSensor)
//   4. BFS 找路径 (buildPath)
//   5. 使能链路 (enableLinks)
//   6. 初始化 sensor controls
//   7. 配置 routing (configureRoutingIfNeeded)
//   8. 逐级格式传播 (propagateFormats)
//   9. 设置 capture 设备 V4L2 格式
//  10. 记录结果
// ============================================================================
bool MediaPipeline::setupMediaDevice(const QString &node,
                                      int desiredW, int desiredH,
                                      QVector<PipelineConfig> &results)
{
    int mfd = open(node.toUtf8().constData(), O_RDWR);
    if (mfd < 0) {
        qCWarning(mpLog, "MP: open %s err: %s", qPrintable(node), strerror(errno));
        return false;
    }

    struct media_device_info info;
    memset(&info, 0, sizeof(info));
    ioctl(mfd, MEDIA_IOC_DEVICE_INFO, &info);
    qCInfo(mpLog, "MP: scan %s driver=%s model=%s", qPrintable(node), info.driver, info.model);

    // 阶段 1: 枚举拓扑
    QVector<TopoEntity> entities;
    QVector<TopoPad> pads;
    QVector<TopoLink> links;
    if (!enumTopology(mfd, entities, pads, links)) {
        close(mfd);
        return false;
    }

    // 调试：entity/pad 详情已由 enumTopology 输出

    // 阶段 2: 找 sensor
    int sensorIdx = findSensor(entities, pads, links);
    if (sensorIdx < 0) {
        qCDebug(mpLog, "MP: no sensor on %s, skip", qPrintable(node));
        close(mfd);
        return false;
    }

    // 阶段 3: BFS 找路径
    QVector<PathHop> path;
    int captureIdx = -1;
    if (!buildPath(entities, pads, links, sensorIdx, path, captureIdx)) {
        close(mfd);
        return false;
    }

    // 阶段 4: 使能链路
    if (enableLinks(mfd, entities, pads, path) < 0) {
        qCWarning(mpLog, "MP: failed to enable links");
        close(mfd);
        return false;
    }

    // 阶段 5: 初始化 sensor controls
    initSensorControls(entities[sensorIdx]);

    // 阶段 6: 配置 routing
    if (configureRoutingIfNeeded(mfd, entities, pads, path, captureIdx) < 0) {
        qCWarning(mpLog, "MP: failed to configure routing");
        close(mfd);
        return false;
    }

    // 阶段 7: 逐级格式传播
    PipelineConfig cfg;
    if (propagateFormats(mfd, entities, pads, path, desiredW, desiredH, cfg) < 0) {
        qCCritical(mpLog, "MP: failed to propagate formats");
        close(mfd);
        return false;
    }

    // 阶段 8: 记录 capture 设备
    const TopoEntity &capEnt = entities[captureIdx];
    cfg.captureDevice = findVideoDevName(capEnt.devMajor, capEnt.devMinor);
    if (cfg.captureDevice.isEmpty()) {
        cfg.captureDevice = "/dev/" + capEnt.name;
    }
    qCDebug(mpLog, "MP: capture device = %s", qPrintable(cfg.captureDevice));

    // 阶段 9: 设置 capture 设备 V4L2 pixel format
    {
        int vfd = open(cfg.captureDevice.toUtf8().constData(), O_RDWR);
        if (vfd >= 0) {
            struct v4l2_format vfmt;
            memset(&vfmt, 0, sizeof(vfmt));
            vfmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            if (ioctl(vfd, VIDIOC_G_FMT, &vfmt) == 0) {
                vfmt.fmt.pix.width  = cfg.width;
                vfmt.fmt.pix.height = cfg.height;
                if (ioctl(vfd, VIDIOC_S_FMT, &vfmt) == 0) {
                    cfg.pixelFormat = vfmt.fmt.pix.pixelformat;
                    cfg.width  = vfmt.fmt.pix.width;
                    cfg.height = vfmt.fmt.pix.height;
                }
            }
            close(vfd);
        }
    }

    results.append(cfg);
    close(mfd);
    return true;
}

// ============================================================================
// setupAll — 扫描所有 /dev/media* 并配置 pipeline
// ============================================================================
QVector<MediaPipeline::PipelineConfig>
MediaPipeline::setupAll(int desiredWidth, int desiredHeight)
{
    QVector<PipelineConfig> allResults;

    if (s_configured) {
        qCInfo(mpLog, "MP: already configured, returning cached results");
        for (auto it = s_configs.begin(); it != s_configs.end(); ++it)
            allResults.append(it.value());
        return allResults;
    }
    s_configured = true;

    QDir d("/dev");
    QStringList nodes = d.entryList({"media*"}, QDir::System);
    std::sort(nodes.begin(), nodes.end(), [](auto &a, auto &b) {
        return a.mid(5).toInt() < b.mid(5).toInt();
    });

    for (auto &nm : nodes) {
        QString path = "/dev/" + nm;
        QVector<PipelineConfig> deviceResults;
        if (setupMediaDevice(path, desiredWidth, desiredHeight, deviceResults)) {
            for (auto &cfg : deviceResults) {
                if (cfg.valid && !cfg.captureDevice.isEmpty()) {
                    s_configs[cfg.captureDevice] = cfg;
                    allResults.append(cfg);
                }
            }
        }
    }

    qCInfo(mpLog, "MP: configured %d pipeline(s)", (int)allResults.size());
    return allResults;
}

// ============================================================================
// getActualResolution
// ============================================================================
bool MediaPipeline::getActualResolution(const QString &vdev, int &w, int &h)
{
    if (s_configs.contains(vdev)) {
        w = s_configs[vdev].width;
        h = s_configs[vdev].height;
        return true;
    }
    return false;
}
