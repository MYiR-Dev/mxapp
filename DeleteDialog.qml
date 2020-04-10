import QtQuick 2.0

//预览界面删除对话框
Rectangle {
    id: root
    width: 240
    height: width/2
    color: "#363d43"
    visible: false
    border.color: "#e5e8ea"
    border.width: 1
    radius: 3

    property color clr_entered: "darkgray"
    property color clr_pressed: "dimgray"
    property color clr_released: "black"
    property color clr_exited: "black"

    signal clicked_delete
    signal clicked_cancel

    Text {
        id: infoText
        text: qsTr("是否删除本张图片？")
        color: "white"
        font.pixelSize: 20
        font.bold: true
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: root.top
        anchors.topMargin: 30
    }

    Rectangle {
        id: deleteButton
        width: root.width/2
        height: root.height/4
        color: clr_exited
        border.color: "white"
        border.width: 0.5
        radius: root.radius
        Text {
            text: qsTr("确定")
            color: "white"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            anchors.centerIn: parent
        }

        anchors.bottom: root.bottom
        anchors.left: root.left
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: enabled
            onClicked: root.clicked_delete()
            onPressed: deleteButton.color = clr_pressed
            onEntered: deleteButton.color = clr_entered
            onExited: deleteButton.color = clr_exited
            onReleased: deleteButton.color = clr_released
        }
    }
    Rectangle {
        id: cancelButton
        width: root.width/2
        height: root.height/4
        color: clr_exited
        border.color: "white"
        border.width: 1
        radius: root.radius
        Text {
            text: qsTr("取消")
            font.pixelSize: 20
            font.bold: true
            color: "white"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            anchors.centerIn: parent
        }
        anchors.bottom: root.bottom
        anchors.right: root.right
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: enabled
            onClicked: root.clicked_cancel()
            onPressed: cancelButton.color = clr_pressed
            onEntered: cancelButton.color = clr_entered
            onExited: cancelButton.color = clr_exited
            onReleased: cancelButton.color = clr_released
        }
    }
}
