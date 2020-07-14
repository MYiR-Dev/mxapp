import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: root
    width: 50
    height: width
    radius: width/2
    color: "white"

    signal captureImage

    signal captureVideoStart
    signal captureVideoStop

    Rectangle {
        id: shotButton
        width: root.width-6
        height: width
        radius: width/2
        color: "black"
        anchors.centerIn: parent
        Rectangle {
            id: captureRec
            width: root.width-12
            height: width
            radius: width/2
            color: "white"
            anchors.centerIn: parent
            MouseArea {
                enabled: true
                anchors.fill: parent
                onClicked: root.captureImage()
                onPressed: captureRec.color = "black"
                onExited: captureRec.color = "white"
            }
        }
    }
}
