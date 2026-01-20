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
import QtMultimedia
import mvideooutput 1.0
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
SystemWindow {
    id: root
    property int adaptive_width: parent.width
    property int adaptive_height: parent.height
    width: adaptive_width
    height: adaptive_height

    onVisibleChanged: {
        if(visible == true)
        {
            //摄像头窗口打开后开启摄像头
            show_image.startCamera();
            console.log("The camera window is activated")
        }
    }
    onAboutToHide: {
        showFlag = false
        //解决再次进入黑屏问题
        counter = !counter
        image.source = ""+ counter
    }

    Define {id: def}
    Album {id: w_album}
    property bool counter: false
    function reload() {
        counter = !counter
        image.source = "image://cameraImageProvider?id=" + counter
    }
    Image {
        id: image
        anchors.fill: parent
        cache: false
    }

    Connections {
        target: show_image
        onCallQmlRefreshImage:{
            reload()
        }
        onCallQmlSavePath:{
            bar.img_src = "file://" + path
        }
    }

    MediaDevices {id: mediaDevices}
    // CaptureSession{
    //     id:captureSession
    //     videoOutput: VideoOutput{
    //         id:videoOutput
    //         visible: true
    //         width: 640
    //         height: 480
    //         x:0
    //         y:0
    //     }

    //     camera:Camera {
    //         id:camera
    //         cameraDevice: mediaDevices.videoInputs[0]
    //         //白平衡
    //         whiteBalanceMode: Camera.WhiteBalanceManual
    //         //曝光
    //         exposureCompensation: +1.0
    //         exposureMode: Camera.ExposurePortrait
    //         //相机模式
    //         flashMode: Camera.FlashAuto
    //         focusMode: Camera.FocusModeAutoNear
    //         onErrorOccurred: console.log("camera err: " + error + errorString);
    //     }
    //     //拍照模式配置
    //     imageCapture : ImageCapture {
    //         id:cameraCapture
    //         onErrorOccurred: console.log("capture failed:" + cameraCapture.errorString)
    //     }

    //     //录像模式配置
    //     recorder: MediaRecorder {
    //         id:cameraRecorder
    //         onRecorderStateChanged: console.log("state changed")
    //     }
    // }

    ListModel {id: imagePaths}

    //相机界面，左上角返回按钮
    MyIconButton {
        id: backButton
        icon_code: def.iconCode_back
	// 如果获取不到摄像头信息将导致画面卡死
        button_text: mediaDevices.defaultVideoInput.description
        button_color: "white"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        onClicked: {
            //点击推出后停止摄像头
            show_image.stopCamera();
            root.close()
        }
    }

    //右上角跳转到图库按钮
    MyIconButton {
        id: albumButton
        icon_code: def.iconCode_album
        button_text: qsTr("所有图片")
        button_color: "white"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        onClicked: {
            w_album.setImageFolder(def.imageDefaultLocation)
            w_album.showNormal()
        }
    }

    //底部拍照功能区域：预览图片+矩形+按钮
    CaptureBar {
        id: bar
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width
    	img_src: captureSession.imageCapture.preview
        onCaptureImage: {

            //保存照片到指定位置
            var savePath = def.captureSavePath + def.captureSaveHead + def.getCurrentTime();
            show_image.captureImg(savePath)
        }

        //以下为小视频录制功能
        onCaptureVideoStart: {
            console.log("capture video start")
        }
        onCaptureVideoStop: {
            console.log("capture video stop")
        }
    }
}
