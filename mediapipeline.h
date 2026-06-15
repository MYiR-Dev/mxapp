/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

#ifndef MEDIAPIPELINE_H
#define MEDIAPIPELINE_H

#include <QString>
#include <QMap>
#include <QVector>

/**
 * MediaPipeline — 通用 Linux Media Controller 链路配置器
 *
 * 功能：
 *   - 扫描 /dev/media* 自动发现 CSI camera pipeline
 *   - BFS 找 sensor→capture 最短路径
 *   - 自动使能链路（跳过 IMMUTABLE）
 *   - 自动检测并配置 V4L2 streams/routing API
 *   - 逐级 TRY→ACTIVE 格式传播（硬件无关）
 *   - 自动配置 proc entity COMPOSE 缩放
 *   - 输出可直接 STREAMON 的 capture 设备配置
 *
 * 已知限制：
 *   - 不支持多 stream sensor（HDR 等）
 *   - 不支持多 camera 共享 crossbar 编排
 *   - 不支持嵌入式数据流
 *   - 不支持 ISP 级联
 */
class MediaPipeline {
public:
    // ---- 拓扑数据（内核枚举的原始信息） ----
    struct TopoEntity {
        unsigned int id;
        QString name;
        unsigned int function;
        int devMajor;
        int devMinor;
        bool isVideoDevice;  // true = /dev/video* capture, false = v4l-subdev
    };

    struct TopoPad {
        unsigned int id;
        unsigned int entityId;
        unsigned int flags;   // MEDIA_PAD_FL_SINK | MEDIA_PAD_FL_SOURCE
        unsigned int index;   // pad 在 entity 内的序号
    };

    struct TopoLink {
        unsigned int id;
        unsigned int srcId;   // source pad id（非 interface link）
        unsigned int dstId;   // sink pad id
        unsigned int flags;   // MEDIA_LNK_FL_ENABLED | MEDIA_LNK_FL_IMMUTABLE
    };

    // ---- 路径信息 ----
    struct PathHop {
        int srcEntIdx;   // 在 entities 数组中的索引
        int dstEntIdx;
        unsigned int srcPadId;
        unsigned int dstPadId;
        const TopoLink *link;
    };

    // 单个 pipeline 的配置结果
    struct PipelineConfig {
        QString captureDevice;     // /dev/videoX
        int width = 0;
        int height = 0;
        uint32_t pixelFormat = 0;  // V4L2_PIX_FMT_*
        uint32_t mbusCode = 0;     // 最终 sink 侧的 mbus code
        bool valid = false;
    };

    // 扫描所有 /dev/media*，配置所有发现的 CSI camera pipeline
    static QVector<PipelineConfig> setupAll(int desiredWidth = 1280,
                                             int desiredHeight = 720);

    // 获取 setupAll() 记录的指定 capture 设备的实际分辨率
    static bool getActualResolution(const QString &videoDev,
                                    int &width, int &height);

private:
    static bool setupMediaDevice(const QString &mediaNode,
                                 int desiredW, int desiredH,
                                 QVector<PipelineConfig> &results);

    // ---- 静态状态 ----
    static bool s_configured;
    static QMap<QString, PipelineConfig> s_configs;  // captureDev → config
};

#endif // MEDIAPIPELINE_H
