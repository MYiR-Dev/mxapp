import QtQuick 2.0

Rectangle {
    id: root
    width: def.win_width
    height: 80
    color: "black"

    property alias img_src: photoPreview.source

    signal captureImage
    signal captureVideoStart
    signal captureVideoStop

    Define {id: def}

    CircularImage {
        id: photoPreview
        width: 70
        height: width
        //        source: getImageFolder() + fileName
        anchors.verticalCenter: root.verticalCenter
        anchors.left: root.left
        anchors.leftMargin: 5
        radius: 5
    }
    //拍照按钮
/*
    CaptureButton {
        id: shotButton
        anchors.centerIn: root
        onCaptureImage: root.captureImage()
    }
*/

    //拍照和录像集成在一起的按钮
    ShotButton {
        id: shotButton
        anchors.centerIn: root
        delay: 10*1000  //10s

        property bool startFlag: false

        onClicked: root.captureImage()
        onActivated: root.captureVideoStop()
        onProgressChanged: {
            if(progress > 0.1 && startFlag == false && down == true)
            {
                root.captureVideoStart()
                startFlag = true;
            }
        }
        onDownChanged: {
            if(progress > 0.3 && down==false && progress != 1)   //中途松开
            {
                root.captureVideoStop()
                startFlag = false;
            }
        }
    }
}
