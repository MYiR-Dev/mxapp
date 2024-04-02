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
import QtQuick.Window 2.0
//版权说明对话框
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
Popup {
    id:root
    padding: 0
    margins: 0
    modal: false
    focus: true
    closePolicy: Popup.NoAutoClose
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight

    background:Rectangle{
        anchors.fill:parent
        color: "black"
        opacity: 0.3
    }

    property color clr_entered: "darkgray"
    property color clr_pressed: "dimgray"
    property color clr_released: "black"
    property color clr_exited: "black"

    Rectangle{
        id:copyright_text
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 15
        anchors.topMargin: 15
        anchors.rightMargin: 15
        anchors.bottomMargin: 100
        color: "transparent"
        Text {
            id: infoText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 16
            font.bold: true
            text: qsTr("Copyright (C) 2020-2024\n
This program is free software: you can redistribute it and/or modify\n
it under the terms of the GNU General Public License as published by\n
the Free Software Foundation, either version 3 of the License, or\n
(at your option) any later version.\n\n

This program is distributed in the hope that it will be useful,\n
but WITHOUT ANY WARRANTY; without even the implied warranty of\n
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n
GNU General Public License for more details.\n\n

You should have received a copy of the GNU General Public License\n
along with this program.  If not, see <https://www.gnu.org/licenses/>.\n\n

Additional permission under GNU Lesser General Public License version 3.0\n
See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.")
        }
    }

    Rectangle {
        id: returnButton
        width: 120
        height: 40
        color: clr_exited
        border.color: "white"
        border.width: 0.5
        radius: 0.5
        Text {
            text: qsTr("确定")
            color: "white"
            font.pixelSize: 20
            //            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
        }

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 30
        anchors.rightMargin: 30
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            onClicked: {
                root.visible = false
            }

            onPressed: returnButton.color = clr_pressed
            onEntered: returnButton.color = clr_entered
            onExited: returnButton.color = clr_exited
            onReleased: returnButton.color = clr_released
        }
    }
}
