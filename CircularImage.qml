import QtQuick 2.6
import QtGraphicalEffects 1.0

//圆角图片
Rectangle {
    property alias source: _image.source

    radius: 5
    color: "transparent"
    Image {
        id: _image
        smooth: true
        visible: true
        anchors.fill: parent
        source: img_src
        sourceSize: Qt.size(parent.size, parent.size)
        antialiasing: true
//        fillMode: Image.Stretch //默认
        fillMode: Image.PreserveAspectCrop
//        fillMode: Image.PreserveAspectFit
    }
//    Rectangle {
//        id: _mask
//        color: "black"
//        anchors.fill: parent
//        radius: parent.radius
//        visible: false
//        antialiasing: true
//        smooth: true
//    }
//    OpacityMask {
//        id: mask_image
//        anchors.fill: _image
//        source: _image
//        maskSource: _mask
//        visible: true
//        antialiasing: true
//    }
}
