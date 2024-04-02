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

Rectangle {
    id:root
    anchors{
        right: parent.right
        rightMargin: 5
        top: parent.top
        topMargin: 5
    }

    property real icongap: 16

//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

//    HomeButton{
//        id: logo
//        label.visible: false
//        clickable: true
//        source: "images/wvga/home/header_logo.png"
//        onClicked: {
//            popupFrame1.open()
//        }
//    }

    HomeButton{
        id: btIcon
        label.visible: false
        clickable: false
        visible: false
        source: "images/wvga/home/bt.png"
//        width: 12
//        height: 12
        anchors{
            right: ethIcon.left
            rightMargin: icongap
            top: parent.top
            topMargin: 10
            //            verticalCenter: parent.verticalCenter
            }
    }
    HomeButton{
        id: ethIcon
        label.visible: false
        clickable: false
        visible: false
        source: "images/wvga/home/eth.png"
        anchors{
            right: wifiIcon.left
            rightMargin: icongap
            top: parent.top
            topMargin: 10
            //            verticalCenter: parent.verticalCenter
            }
    }
    HomeButton{
            id: wifiIcon
//            anchors.margins: 5
            label.visible: false
//            height: 24
            visible: false
            clickable: false
            source: "images/wvga/home/wifi.png"
            anchors{
                right:mobiIcon.left
                rightMargin: icongap
                top: parent.top
                topMargin: 10
                //            verticalCenter: parent.verticalCenter
            }
    }
    HomeButton{
            id: mobiIcon
//            anchors.margins: 5
            label.visible: false
//           height: 24
            visible: false
            clickable: false
            source: "images/wvga/home/mobile.png"
            anchors{
                right:tt.left
                rightMargin: icongap
                top: parent.top
                topMargin: 10
                //            verticalCenter: parent.verticalCenter
            }
    }

    Rectangle{
        id:tt
        color:"green"
        width: 80
        anchors.right: parent.right
//        anchors.rightMargin: 20
//        anchors.topMargin: 5


    Text {
        id: time
        anchors.leftMargin: icongap
        anchors.horizontalCenter: parent.horizontalCenter
        font{
            family:"DS-Digital"
            pixelSize:14
        }
//        FontLoader { id: localFont; source: "qrc:/fonts/DIGITAL/DS-DIGIB.TTF" }
        text: "00:00:00";color: "white";// style: Text.Outline;
    }

    Text {
        id: date
        anchors.top:time.bottom
        anchors.leftMargin: icongap
        anchors.horizontalCenter: parent.horizontalCenter
//        font.pointSize:8; text: qsTr("2020年2月25日");style: Text.Outline;styleColor: "white"
//        FontLoader { id: localFont1; source: "qrc:/fonts/DIGITAL/DS-DIGIB.TTF" }
        font{
            family: "DS-Digital"
            pixelSize:10
        }
//        style: Text.Outline;
//        text: qsTr("2020年2月25日")
        color: "white"

    }
}

    Timer{
        id:timer
        interval:100;running:true;repeat: true
        onTriggered: {
            var currentTime = new Date();
            time.text = Qt.formatTime(currentTime,"hh:mm:ss");
            date.text = Qt.formatDate(currentTime,"yyyy-MM-dd");
        }
    }

    Component.onCompleted: {
        timer.start();
    }
}
