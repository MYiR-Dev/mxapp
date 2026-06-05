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
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
Item {
    id:root
    anchors{
        top: parent.top
        left: parent.left
    }
    // Wayland 下窗口缩放是异步的,强制延迟到下一帧
    onHeightChanged: {
        Qt.callLater(function(){
            languageBt.width = fitWidth(languageBt.icontext)+fitWidth(languageBt.engtext)+app_font_size
            copyrightNotice.width = fitWidth(copyrightNotice.crtext)+app_font_size
        } )
    }

    function fitWidth(text){
        return  Math.ceil(fontMetrics.advanceWidth(text));
    }

    property int app_font_size: {
        Math.ceil(root.height*0.4)
    }

    FontMetrics {
        id: fontMetrics
        font.family: "Microsoft YaHei"
        font.pixelSize: app_font_size
    }
    TitleLeftBar{
        id: leftBar
        titleIcon: "images/LOGO.png"
        titleIconWidth: parent.width*0.2
        titleIconHeight: parent.height*0.8
        titleNameSize: app_font_size*1.2
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
        property int engwidth: fitWidth(icontext)+fitWidth(engtext)+app_font_size
        property alias engtext: textEnglish.text
        property alias icontext: icon.text
        width:engwidth
        height: app_font_size*1.4
        radius: height*0.2
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 100
        color:"#02b9db"
        Item{
            anchors.centerIn: parent
            width:icon.width+textEnglish.width
            Text {
                id: icon
                font.family: "FontAwesome"
                font.pixelSize: app_font_size
                text: language_icon //图标
                color: "white"
                opacity: 1.0        //不透明
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id : textEnglish
                text: checked? qsTr("中文"): qsTr("English")
                color: "white"
                font.pixelSize: app_font_size
                font.family:"Microsoft YaHei"
                anchors.left: icon.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: app_font_size*0.2
            }
        }

        MouseArea{
            anchors.fill: parent

            onClicked: {
                checked = !checked
                // console.log(checked)
                if(checked)
                   translator.loadLanguage("English");
                else
                    translator.loadLanguage("Chinese");
                languageBt.width = fitWidth(languageBt.icontext)+fitWidth(languageBt.engtext)+app_font_size
                copyrightNotice.width = fitWidth(copyrightNotice.crtext)+app_font_size
            }
        }
//        style: buttonStyle
    }
    Rectangle{
        id:copyrightNotice
        width:fitWidth(crtext)+app_font_size
        height: app_font_size*1.4
        radius: height*0.2
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.right: languageBt.left
        anchors.rightMargin: 30
        color:"#02b9db"
        property alias crtext: cR.text
        Text {
            id:cR
            text: qsTr("版权说明")
            color: "white"
            font.pixelSize: app_font_size
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
