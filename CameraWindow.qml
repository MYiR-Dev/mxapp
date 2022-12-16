import QtQuick 2.5
import QtMultimedia 5.6
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import mvideooutput 1.0

SystemWindow {
    id: root
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
//    width: def.win_width
//    height: def.win_height
////    color: "black"
////    title: qsTr("相机")
////    flags: Qt.Dialog        //Dialog,没有最大最小化按钮

//    property bool showFlag: false

//    function show(){
//        open()
//    }
//    function showNormal(){
//        open()
//    }
    onVisibleChanged: {
        if(showFlag == false)
        {
            showFlag = true;
            camera.start()
            console.log("相机窗口被激活")
        }
    }
    onAboutToHide: {
        showFlag = false
        camera.stop()
    }

    Component.onCompleted: camera.stop()

    Define {id: def}
    Album {id: w_album}

    Camera {
        id: camera
        //相机模式
//        captureMode: Camera.CaptureStillImage       //静态照片捕捉模式
        captureMode: Camera.CaptureStillImage
        //白平衡
        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
        //分辨率
        viewfinder.resolution: "320x240"
        flash.mode: Camera.FlashRedEyeReduction
        //曝光
        exposure {
            exposureCompensation: +1.0
            exposureMode: Camera.ExposurePortrait
        }

        //拍照模式配置
        imageCapture {

            onImageSaved: console.log("save path:" + path);
            onImageCaptured: bar.img_src = preview
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
    // VideoOutput {
        anchors.fill: parent
        source: camera
    }

    ListModel {id: imagePaths}

    //相机界面，左上角返回按钮
    MyIconButton {
        id: backButton
        icon_code: def.iconCode_back
        button_text: camera.displayName
        button_color: "white"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        onClicked: {
            camera.stop()
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
        onCaptureImage: {
            //保存照片到指定位置
            var savePath = def.captureSavePath + def.captureSaveHead + def.getCurrentTime();
            camera.imageCapture.captureToLocation(savePath);
        }

        //以下为小视频录制功能
        onCaptureVideoStart: {
            console.log("capture video start")
            /*
            camera.captureMode = Camera.CaptureVideo
            var savePath = def.captureSavePath + "video_" + def.getCurrentTime();
            camera.videoRecorder.setOutputLocation(savePath)
            camera.videoRecorder.record()
            */
        }
        onCaptureVideoStop: {
            console.log("capture video stop")
            /*
            camera.videoRecorder.stop()
            camera.captureMode = Camera.CaptureStillImage
            camera.start()
            */
        }
    }
}
