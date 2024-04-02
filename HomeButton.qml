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

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Image {
    id: hBtn
    source:"images/wvga/home/home.png"
    signal clicked()
    signal longpressed()

    property bool clickable : true
    property int duration: 250
    property int glowRadius: 50
    property alias label: label
    property alias text: label.text

    MouseArea{
        anchors.fill: parent
        pressAndHoldInterval: 5000
        onPressAndHold: {
            if(hBtn.clickable){
                hBtn.longpressed();
            }
        }

        onClicked: {
            if(hBtn.clickable){
                hBtn.clicked()
            }
        }
        onPressed: {
            if(hBtn.clickable){
                glow.visible = true
                animation1.start()
                animation2.start()
            }
        }
    }

    Rectangle{
        id:glow
        anchors.centerIn: parent
        visible: false
        width: hBtn.glowRadius*2
        height: hBtn.glowRadius*2
        color:"#00000000"
        radius: hBtn.glowRadius
        scale:1.05
        border.color: "white"
    }

    Label{
        id:label
//        x:292
//        y:252
        text:qsTr("Label")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        color:"#443224"
        font.pixelSize: 28
    }

    PropertyAnimation{
        target:glow
        id:animation1
        duration: hBtn.duration
        loops:1
        from:1.05
        to:1.2
        property:"scale"
    }

    ParallelAnimation{
        id:animation2
        SequentialAnimation{
            PropertyAnimation{
                target: glow
                duration: hBtn.duration
                loops:1
                from:0.2
                to:1.0
                property:"opacity"
            }
            PropertyAnimation{
                target: glow
                duration:hBtn.duration
                loops:1
                from:1.0
                to:0
                property:"opacity"
            }

            PropertyAction {
                target: glow; property: "visible"; value:false }
        }
        SequentialAnimation {
            PropertyAction {
                target: glow
                property: "border.width"
                value: 6
            }

            PauseAnimation {
                duration: 200
            }

            PropertyAnimation {
                target: glow
                duration: hBtn.duration
                loops: 1
                from: 6
                to: 3
                property: "border.width"
            }
        }
    }
}
