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

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
// import Qt.labs.settings 1.0
import QtCore
import ChargeManage 1.0
import Charge104 1.0
import GetSystemInfoAPI 1.0
ApplicationWindow {
    id: mainWnd
    visible: true
    title: qsTr("MXAPP2")

    background: Image{
        source: "images/wvga/home/background-dark.png"
    }

    function  chooseWnd(str){
        console.log(str)
        if(str === "HOME"){
            stateGrp.state = "HOME"
        }
        if(str === "MENU"){
            stateGrp.state = "MENU"
        }
    }

    Settings {
        id: settings
        property int hmiBootCount: 0
    }

    TitleBar {
        id:tBar
        width: parent.width
        height: parent.height/14
    }

//    HomeButton{
//        id: test
//        width: 30
//        height: 30
//        label.visible: false
////        glowColor: "red"
//        glowRadius: 20
//        anchors.top:tBar.bottom

//    }

    HomeWindow{
        id:homeWnd
        anchors.top: tBar.bottom
        visible: true
        width: parent.width
        height: parent.height - tBar.height
        app_height: parent.height
    }

    MenuWindow{
        id:menuWnd
        anchors.top: tBar.bottom
        visible: false
        width: parent.width
        height: parent.height - tBar.height
    }

    StateGroup{
        id:stateGrp
        states:[
            State {
                name: "HOME"
                PropertyChanges {
                    target: homeWnd
                    opacity:1
                    visible:true

                }
                PropertyChanges {
                    target: menuWnd
                    opacity:0
                    visible:false
                }
            },
            State {
                name: "MENU"
                PropertyChanges {
                    target: homeWnd
                    opacity:0
                    visible:false
                }
                PropertyChanges {
                    target: menuWnd
                    opacity:1
                    visible:true
                }
            }
        ]
    }
    Loader{
        id:mainloader;
        anchors.fill: parent

    }
//    Loader{
//        id:settingsWnd;
//        anchors.centerIn: parent;
//        source: "SettingsWindow.qml";

//    }
//    Connections {
//         target: settingsWnd.item
//         onMessage:{
//             settingsWnd.setSource("")
//             settingsWnd.setSource("SettingsWindow.qml")

//         }
//     }

    Component.onCompleted: {
        var b = settings.value("hmiBootCount",0);
        settings.hmiBootCount = Number(b)+1;
        settings.setValue("hmiBootCount", settings.hmiBootCount);
        console.log("settings.hmiBootCount is ", settings.hmiBootCount);
        settings.sync();
        // 通用 ALSA 音量初始化（自动适配不同板子，设置所有匹配的控制名）
        sysInfo.initAlsaVolume();
        if(Qt.platform.pluginName === "wayland") {
            mainWnd.width = 1024
            mainWnd.height = 600
        }else{
            mainWnd.visibility =  Window.FullScreen
        }

        console.log("qml platform "+Qt.platform.pluginName)
    }

    GetSystemInfo {
        id: sysInfo
    }

    ChargeManage{
        id:charge_manage_c
    }

    Charge104{
        id:charge104_c
    }
}
