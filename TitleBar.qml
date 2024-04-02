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
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.0
Item {
    id:root
    anchors{
        top: parent.top
        left: parent.left
    }

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/LOGO.png"
        titleIconWidth: 172
        titleIconHeight: 35
        titleNameSize: 20
        titleName: "Make Your Idea Real!"

        onLeftBarClicked: {
            mainloader.source = "SupportWindow.qml"
            //            mainloader.item.show()
            //            mainloader.item.requestActivate()
            mainloader.item.open()
        }

    }

    property bool checked: false
    property string language_icon:"\uf1ab"
    Rectangle{
        id:languageBt
        width: 100
        height: 25
        radius: 10
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 100
        color:"#02b9db"
        Text {
            id: icon
            font.family: "FontAwesome"
            font.pixelSize: 12
            text: language_icon //图标
            color: "white"
            opacity: 1.0        //不透明
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            //            anchors.centerIn: root
        }
        Text {
            id : textEnglish
            text: checked? qsTr("中文"): qsTr("English")
            color: "white"
            font.pointSize: 12
            font.family:"Microsoft YaHei"
            anchors.left: icon.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Screen.desktopAvailableWidth/96
        }

        MouseArea{
            anchors.fill: parent

            onClicked: {
                checked = !checked
                console.log(checked)
                if(checked)
                    translator.loadLanguage("English");
                else
                    translator.loadLanguage("Chinese");
            }
        }
        //        style: buttonStyle
    }

    Rectangle{
        id:copyrightNotice
        width: 100
        height: 25
        radius: 10
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.right: languageBt.left
        anchors.rightMargin: 30
        color:"#02b9db"
        Text {
            text: qsTr("版权说明")
            color: "white"
            font.pointSize: 12
            font.family:"Microsoft YaHei"
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onClicked: {
                mainloader.source = "CopyrightNoticeDialog.qml"
                mainloader.item.open()
            }
        }
    }

    TitleRightBar{
        id:rightBar
        anchors{
            top: parent.top
            right: parent.right
            //            topMargin: 10
            //            rightMargin: 10
        }
    }

    //    SupportPop {
    //        id:popupFrame1
    //    }
}
