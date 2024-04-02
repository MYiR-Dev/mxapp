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

    GridLayout {
        id: circularView
        anchors.top:tBar.bottom
        width: parent.width
        height: parent.height- tBar.height

        columns: 3
        rows: 3

//        signal launched(string page)

        readonly property int cX: width / 2
        readonly property int cY: height / 2
        readonly property int itemWidth: width/3
        readonly property int itemHeight:height/3
        readonly property  int raduis : Math.max(itemWidth, itemHeight)

        Rectangle{
//            anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"
            border.width: 2
            border.color: "black"

            Camera {
                id: camera
                //相机模式
        //        captureMode: Camera.CaptureStillImage       //静态照片捕捉模式
                captureMode: Camera.CaptureStillImage
                //白平衡
                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
                //分辨率
                viewfinder.resolution: "640x480"
                flash.mode: Camera.FlashRedEyeReduction
                //曝光
                exposure {
                    exposureCompensation: +1.0
                    exposureMode: Camera.ExposurePortrait
                }

                //拍照模式配置
                imageCapture {

                    onImageSaved: console.log("save path:" + path);
        //                    onImageCaptured: bar.img_src = preview
                    onCaptureFailed: console.log("capture failed:" + message)
                }

                //录像模式配置
                videoRecorder {
        //             resolution: "640x480"
                     frameRate: 30              //帧率
        //             audioEncodingMode: CameraRecorder.ConstantBitrateEncoding;
        //             audioBitRate: 128000       //视频比特率
        //             mediaContainer: "mp4"      //视频录制格式
        //             outputLocation: "D:\MYIR\Capture\video_test"        //保存地址
                     onRecorderStateChanged: console.log("state changed")
                     onRecorderStatusChanged: console.log("status changed")
                }
                //对焦模式
        //        focus {
        //            focusMode: Camera.FocusAuto
        //            focusPointMode: Camera.FocusPointCenter
        //        }

                onError: console.log("camera err: " + errorCode + errorString);
                Component.onCompleted: console.log('StackView.onStatusChanged camera.viewfinder.resolution:', camera.viewfinder.resolution)
            }

            MVideoOutput {
        //        anchors.fill: parent
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                source: camera
            }

        //            ListModel {id: imagePaths}

            MouseArea{
                anchors.fill: parent

                onDoubleClicked: {
        //                    loader10.sourceComponent = comp1;
                    parent.scale= 1.5
                    parent.z = 20

                }
            }
        }
//        Rectangle {
//                width: circularView.itemWidth
//                height: circularView.itemHeight
////                anchors.leftMargin: 10
////                anchors.rightMargin: 10
//                border.width: 3
//                Loader{
//                    id:cloader1
//                    width: circularView.itemWidth
//                    height: circularView.itemHeight
//                    anchors.centerIn: parent
////                    transform:Translate{ y: yoffset }

//                    source: "camera.qml";
//                    onLoaded: {
//                    }

//                }

//                Text {
//                    id: appTitle1
//                    text: qsTr("Camera")
//                    anchors.centerIn: parent

//                    font.bold: true
//                    font.pixelSize: circularView.itemWidth / 10
//                    font.letterSpacing: 1
//                    color: "white"
//                    opacity: 0.3
//                }
//        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader2
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "video.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle2
                    text: qsTr("Video")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader3
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "ethernet.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle3
                    text: qsTr("ethernet")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader4
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "serial.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle4
                    text: qsTr("Serial")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                border.color: "yellow"
                scale: 1.5
                opacity: 0.5
                z: 20
                Loader{
                    id:cloader5
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "memory.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle5
                    text: qsTr("System")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader6
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "can.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle6
                    text: qsTr("CAN")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader7
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "wifi.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle7
                    text: qsTr("WiFi")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader8
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "developing.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle8
                    text: qsTr("Developing")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
                }
        }
        Rectangle {
                width: circularView.itemWidth
                height: circularView.itemHeight
//                anchors.leftMargin: 10
//                anchors.rightMargin: 10
                border.width: 3
                Loader{
                    id:cloader9
                    width: circularView.itemWidth
                    height: circularView.itemHeight
                    anchors.centerIn: parent
//                    transform:Translate{ y: yoffset }

                    source: "developing.qml";
                    onLoaded: {
                    }

                }

                Text {
                    id: appTitle9
                    text: qsTr("Developing")
                    anchors.centerIn: parent

                    font.bold: true
                    font.pixelSize: circularView.itemWidth / 10
                    font.letterSpacing: 1
                    color: "white"
                    opacity: 0.3
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
