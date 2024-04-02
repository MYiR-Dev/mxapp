/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024 XuMR <2801739946@qq.com>

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
***********************************************************************/

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import GetSystemInfoAPI 1.0
import mvideooutput 1.0
import QtMultimedia 5.12
import Qt.labs.settings 1.1

import mprocess 1.0
import "../"

SystemWindow {
    id: root
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height

    Settings {
        id: settings
        property bool agingMode: false
    }
    TitleBar {
        id:tBar
        width:Screen.desktopAvailableWidth
        height:Screen.desktopAvailableHeight/14
    }

    Item {
        id: agingIndicator
        width: row.implicitWidth + margins * 2
        height: tBar.height
        y: settings.agingMode ? 0 : -height * 2
        anchors.horizontalCenter: parent.horizontalCenter
        z: tBar.z + 1

        readonly property int topMargin: 24
        readonly property int margins: 12

        Behavior on y {
            NumberAnimation {}
        }

        Rectangle {
            id: demoModeIndicatorBg
            anchors.fill: parent
            anchors.topMargin: -topMargin
            radius: 5
            color: "red"
        }

        Row {
            id: row
            spacing: 8
            anchors.fill: parent
            anchors.leftMargin: margins
            anchors.rightMargin: margins

            Image {
                source: "images/demo-mode-white.png"
                width: height
                height: instructionLabel.height * 2
                anchors.verticalCenter: parent.verticalCenter
            }
            Label {
                id: instructionLabel
                text: "Double Click to Exit."
                color: "#f3f3f4"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea{
            anchors.fill: parent
            onDoubleClicked: {
                settings.agingMode = false;
                root.close();
            }
        }
    }

    PathView {
        id: circularView
        anchors.top:tBar.bottom
        width: parent.width
        height: parent.height- tBar.height

//        signal launched(string page)

        readonly property int cX: width / 2
        readonly property int cY: height / 2
        readonly property int itemWidth: width/3
        readonly property int itemHeight:height/3
        readonly property  int raduis : Math.max(itemWidth, itemHeight)

        snapMode: PathView.SnapToItem

        model: ListModel {
            ListElement {
                title: qsTr("System")
                icon: "memory"
                page: "memory.qml"
            }
            ListElement {
                title: qsTr("Video")
                icon: "video"
                page: "video.qml"
            }
            ListElement {
                title: qsTr("Developing")
                icon: "developing"
                page: "developing.qml"
            }
            ListElement {
                title: qsTr("Ethernet")
                icon: "ethernet"
                page: "ethernet.qml"
            }
            ListElement {
                title: qsTr("Camera")
                icon: "camera"
                page: "camera.qml"
            }
            ListElement {
                title: qsTr("Serial")
                icon: "serial"
                page: "serial.qml"
            }
            ListElement {
                title: qsTr("Developing")
                icon: "developing"
                page: "developing.qml"
            }
            ListElement {
                title: qsTr("Developing")
                icon: "developing"
                page: "developing.qml"
            }
            ListElement {
                title: qsTr("WiFi")
                icon: "WiFi"
                page: "wifi.qml"
            }
        }

        delegate: Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                border.width: 3
                border.color: PathView.isCurrentItem ? "yellow" : "grey"

                property string title: model.title
                property real yoffset: PathView.itemYoffset;

    //            icon.width: 36
    //            icon.height: 36
    //            icon.name: model.icon
                opacity: PathView.itemOpacity
                scale: PathView.itemScale
                z: PathView.itemZorder
                transform:Translate{ y: yoffset }


    //            padding: 12

    //            background: Rectangle {
    //                radius: width / 2
    //                border.width: 3
    //                border.color: parent.PathView.isCurrentItem ? UIStyle.colorQtPrimGreen : UIStyle.themeColorQtGray4
    //            }

                Loader{
                    id:cloader
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: model.page;
                    onLoaded: {
    //                    cloader
    //                    cloader.implicitHeight = 60;
    //                    cloader.implicitWidth = 40;
    //                    cloader.item.scale = 0.2
                    }

//                    MouseArea{
//                        anchors.fill: parent
//                        propagateComposedEvents: true

//                        onClicked: {
//                            console.log("cloader be clicked!");
//                            mouse.accepted = false;
//                        }

//                    }
                }

                Text {
                    id: appTitle

//                    property Item currentItem: circularView.currentItem

//                    visible: currentItem ? currentItem.PathView.itemOpacity === 1.0 : 0

                    text: model.title
                    anchors.centerIn: parent
//                    anchors.verticalCenterOffset: (circularView.itemHeight + height) / 2

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
                MouseArea{
                    anchors.fill: parent
//

                    onClicked: {
                        if (parent.PathView.isCurrentItem){
    //                        circularView.launched(Qt.resolvedUrl(page))
//                            propagateComposedEvents = true;
                            mouse.accepted = false;
                            console.log("delegate rectangle be clicked t!");

                        }
                        else{
                            console.log("delegate rectangle be clicked f!");
                            circularView.currentIndex = index
                            mouse.accepted = false;
                        }
                    }
                    onPressed:{
//                        if (PathView.isCurrentItem){
    //                        circularView.launched(Qt.resolvedUrl(page))
//                            mouse.accepted = false;

//                        }
//                        else{
//                            circularView.currentIndex = index
//                        }
                    }

                    onReleased: {
//                        if (PathView.isCurrentItem){
    //                        circularView.launched(Qt.resolvedUrl(page))
//                            mouse.accepted = false;

//                        }
//                        else{
//                            circularView.currentIndex = index
//                        }
                    }
            }
        }
        path: Path {
            // 1
            startX: circularView.cX
            startY: circularView.cY
            PathAttribute {
                name: "itemOpacity"
                value: 0.6
            }
            PathAttribute {
                name: "itemScale"
                value: 1.5
            }
            PathAttribute {
                name: "itemZorder"
                value: 10
            }
            PathAttribute{
                name:"itemYoffset"
                value: 0
            }
            // 2
            PathLine {
                x: circularView.cX + circularView.raduis
                y: circularView.cY
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: 0
            }
            // 3
            PathLine {
                x: circularView.cX + circularView.raduis
                y: circularView.cY - circularView.raduis
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }//        PathArc {
    //            x: circularView.cX + circularView.radius
    //            y: circularView.cY
    //            radiusX: circularView.radius
    //            radiusY: circularView.radius
    //            useLargeArc: true
    //            direction: PathArc.Clockwise
    //        }
            PathAttribute{
                name:"itemYoffset"
                value: circularView.itemWidth - circularView.itemHeight
            }
            // 4
            PathLine {
                x: circularView.cX
                y: circularView.cY - circularView.raduis
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: circularView.itemWidth - circularView.itemHeight
            }

            // 5
            PathLine {
                x: circularView.cX - circularView.raduis
                y: circularView.cY - circularView.raduis
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: circularView.itemWidth - circularView.itemHeight
            }
            // 6
            PathLine {
                x: circularView.cX - circularView.raduis
                y: circularView.cY
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: 0
            }
            // 7
            PathLine {
                x: circularView.cX - circularView.raduis
                y: circularView.cY + circularView.raduis
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: circularView.itemHeight - circularView.itemWidth
            }
            // 8
            PathLine {
                x: circularView.cX
                y: circularView.cY + circularView.raduis
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: circularView.itemHeight - circularView.itemWidth
            }
            // 9
            PathLine {
                x: circularView.cX + circularView.raduis
                y: circularView.cY + circularView.raduis
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: circularView.itemHeight - circularView.itemWidth
            }
            // 10
            PathLine {
                x: circularView.cX + circularView.raduis
                y: circularView.cY
            }
            PathAttribute {
                name: "itemScale"
                value: 1.0
            }
            PathAttribute {
                name: "itemOpacity"
                value: 1.0
            }
            PathAttribute {
                name: "itemZorder"
                value: 1
            }
            PathAttribute{
                name:"itemYoffset"
                value: 0
            }
        }

    }

    Component.onCompleted: {
        settings.agingMode = true;
        console.log("hmiBootCount in aging:", settings.value("hmiBootCount"));
    }
    onVisibleChanged: {
        if(visible === true){
            settings.agingMode = true;
        }
    }

}
