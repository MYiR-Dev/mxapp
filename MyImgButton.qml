import QtQuick 2.0

/* 桌面图片按钮的实现，上面图片，下面文本*/
Rectangle {
    id: root
    visible: true
    width: 130
    height: width
    radius: width/20

    color: clr_backgroud
//    border.color: "green"
//    border.width: 1

    property alias img_source: image.source
    property alias img_size: image.width
    property alias button_text: button.text

    property color clr_backgroud: "transparent" //背景透明色
    property color clr_entered: "lightgray"
    property color clr_exited: clr_backgroud
    property color clr_pressed: "lightslategray"        //点击效果

    property int margin: 10

    signal clicked

    Image {
        id: image
        source: "qrc:/res/icon/icon_camera.png"
        width: 80
        height: width
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: root.top
        anchors.margins: root.margin
    }
    Text {
        id: button
        text: qsTr("相机")
        font.bold: true
        font.pixelSize: 25
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: image.bottom
        anchors.margins: root.margin
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton; //只接受左键
        hoverEnabled: true
        onClicked: parent.clicked()
        onEntered: root.color = clr_entered
        onExited: root.color = clr_exited
        onReleased: root.color = clr_entered
        onPressed: root.color = clr_pressed;
    }


}
