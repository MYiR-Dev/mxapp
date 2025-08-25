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

import QtQuick 2.1
import QtQuick.Window 2.2

import Qt.labs.folderlistmodel 2.1
SystemWindow {
    id: fileWindow
    title: "file"
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("文件浏览器")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            fileWindow.close()
//            info_timer.stop()
        }

    }

    TitleRightBar{
        anchors{
            top: parent.top
            right: parent.right
            rightMargin: 10
        }
    }
    FileBrowser {
        id: imageFileBrowser
        folder:"file:///"
        anchors.fill: parent
        width: adaptive_width
        height: adaptive_height/*/1.16*/
        anchors{
            top: parent.top
            topMargin: 50
        }
//        Component.onCompleted: fileSelected.connect(content.openImage)
    }
//    MouseArea {
//        anchors.fill: parent
//        onClicked: imageFileBrowser.show()
//    }
    Component.onCompleted:imageFileBrowser.show()
}
