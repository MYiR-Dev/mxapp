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

class MediaPipeline {
public:
    // 扫描所有 /dev/media*，配置 CSI camera pipeline
    // desiredWidth/Height: 期望分辨率，subdev 不支持的会由驱动自动调整
    // 返回成功配置的 pipeline 数量 (0 = 无 CSI 或 USB)
    static int setupAll(int desiredWidth = 1280, int desiredHeight = 720);

    // 获取 setupAll() 记录的 subdev 实际分辨率
    // 返回 true=CSI 分辨率 / false=USB (使用原始传入值)
    static bool getActualResolution(const QString &videoDev,
                                     int &width, int &height);

private:
    struct Resolution { int width; int height; };

    static bool setupMediaDevice(const QString &mediaNode,
                                  int desiredW, int desiredH);

    static bool s_configured;
    static QMap<QString, Resolution> s_resolutions;
};

#endif // MEDIAPIPELINE_H
