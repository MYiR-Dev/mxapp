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
***********************************************************************/

import QtQuick 2.0
import QtQuick.Window 2.2
Rectangle {
    id: leftbar
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width/2.6
    height:adaptive_height/15
    color: Qt.rgba(0,0,0,0)
    anchors{
        left: parent.left
        leftMargin: 10
        top:parent.top
        topMargin: 10
    }

    signal leftBarClicked
    property string titleIcon: "images/wvga/home/header_logo.png"
    property string titleName: "hello world"
    property real titleIconWidth: 100
    property real titleIconHeight: 16
    property real titleNameSize: 20

    HomeButton{
        id: logo
        width: titleIconWidth
        height: titleIconHeight
        anchors{
            left: parent.left
            top: parent.top
        }

        label.visible: false
        clickable: true
        source: titleIcon
        onClicked: {
            leftBarClicked();
        }
    }

    Text {
        id: name
        text: titleName
        anchors{
            left: logo.right
            leftMargin: 16
        }
        horizontalAlignment: Text.AlignHCenter
        color: "#dcdde4";
        font.family: "Microsoft YaHei";
        font.pixelSize: titleNameSize;
        wrapMode: Text.Wrap;
    }

}
