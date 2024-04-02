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

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0
import ChargeManage 1.0
import Charge104 1.0
import GetSystemInfoAPI 1.0
ApplicationWindow {
    id: mainWnd
    visible: true
    visibility: Window.FullScreen
    //width: Screen.desktopAvailableWidth
    //height: Screen.desktopAvailableHeight
    title: qsTr("Hello World")
    property int pressX: -1
    property int pressY: -1
   // property bool positionflag: false
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
        width:Screen.desktopAvailableWidth
        height:Screen.desktopAvailableHeight/14
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
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight-tBar.height
    }

    MenuWindow{
        id:menuWnd
        anchors.top: tBar.bottom
        visible: false
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight-tBar.height
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
        anchors.centerIn: parent;
        anchors.fill: parent
    }
/*
Rectangle{
        id:btn_return
        width: 100
        height: 100
        radius: 50
        color: Qt.rgba(128/255,128/255,128/255,1);
        x:width/2
        y:height/2

        MouseArea{
            id:btn_return_mousearea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onReleased: {
                if(!positionflag)
                    mainWnd.close()
                else
                    positionflag = false
            }
            onPressed: {
                pressX = mouse.x
                pressY = mouse.y

                console.log(pressX)
                console.log(pressY)
            }

            onPositionChanged: {
                if(!positionflag)
                    positionflag = true
                if(btn_return_mousearea.pressed){
                    console.log("x:"+mouse.x)
                    console.log("y:"+mouse.y)
                    if(mouse.x > 0 || mouse.y > 0){
                        //btn_return.mapToGlobal(btn_return.x + (mouse.x - pressX),btn_return.y + (mouse.y - pressY))
                        btn_return.x = btn_return.x + (mouse.x - pressX)
                        btn_return.y = btn_return.y + (mouse.y - pressY)
                    }
                }
            }
        }
    }
*/

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
    }

    ChargeManage{
        id:charge_manage_c
    }

    Charge104{
        id:charge104_c
    }
}
