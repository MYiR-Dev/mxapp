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

import QtQuick

Rectangle {
    id: root
    width: parent.width
    height: 80
    color: "black"
    property alias img_src: photoPreview.source
    property string lastCapturedPath: ""  // 记录最后拍摄的照片路径
    signal captureImage
    signal captureVideoStart
    signal captureVideoStop

    // 清除缩略图的方法
    function clearThumbnail() {
        photoPreview.source = ""
        lastCapturedPath = ""
    }

    // 检查并更新缩略图（如果文件不存在则清除）
    function checkThumbnail() {
        if(lastCapturedPath !== "" && img_src !== "") {
            // 由外部调用者检查文件是否存在并决定是否清除
        }
    }

    Define {id: def}

    // 缩略图区域 - 固定宽度 80，为右侧 combox 预留空间
    Item {
        id: thumbnailArea
        width: 80
        height: root.height
        anchors.left: root.left
        anchors.leftMargin: 5

        CircularImage {
            id: photoPreview
            width: 70
            height: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 5
        }
    }

    //拍照按钮
    //拍照和录像集成在一起的按钮
    ShotButton {
        id: shotButton
        anchors.centerIn: root
        delay: 10*1000  //10s

        property bool startFlag: false
        onClicked: root.captureImage()
        onActivated: root.captureVideoStop()
        onProgressChanged: {
            if(progress > 0.1 && startFlag == false && down == true)
            {
                root.captureVideoStart()
                startFlag = true;
            }
        }
        onDownChanged: {
            if(progress > 0.3 && down==false && progress != 1)   //中途松开
            {
                root.captureVideoStop()
                startFlag = false;
            }
        }
    }
}
