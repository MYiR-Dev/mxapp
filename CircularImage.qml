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

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

import QtQuick 2.6
import QtGraphicalEffects 1.0

//圆角图片
Rectangle {
    property alias source: _image.source

    radius: 5
    color: "transparent"
    Image {
        id: _image
        smooth: true
        visible: true
        anchors.fill: parent
        source: img_src
        sourceSize: Qt.size(parent.size, parent.size)
        antialiasing: true
//        fillMode: Image.Stretch //默认
        fillMode: Image.PreserveAspectCrop
//        fillMode: Image.PreserveAspectFit
    }
//    Rectangle {
//        id: _mask
//        color: "black"
//        anchors.fill: parent
//        radius: parent.radius
//        visible: false
//        antialiasing: true
//        smooth: true
//    }
//    OpacityMask {
//        id: mask_image
//        anchors.fill: _image
//        source: _image
//        maskSource: _mask
//        visible: true
//        antialiasing: true
//    }
}
