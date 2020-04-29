import QtQuick 2.0
import QtQuick.Window 2.2
Rectangle {
    id: leftbar
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width/2.6
    height:adaptive_height/15
    color: Qt.rgba(0,0,0,0)
    anchors{
        left: parent.left
        leftMargin: 10
        top:parent.top
        topMargin: 10
    }

    signal leftBarClicked
    property string titleIcon: "images/wvga/home/header_logo.png"
    property string titleName: "hello world"
    property real titleIconWidth: 100
    property real titleIconHeight: 16
    property real titleNameSize: 20

    HomeButton{
        id: logo
        width: titleIconWidth
        height: titleIconHeight
        anchors{
            left: parent.left
            top: parent.top
        }

        label.visible: false
        clickable: true
        source: titleIcon
        onClicked: {
            leftBarClicked();
        }
    }

    Text {
        id: name
        text: titleName
        anchors{
            left: logo.right
            leftMargin: 16
        }
        horizontalAlignment: Text.AlignHCenter
        color: "#dcdde4";
        font.family: "Microsoft YaHei";
        font.pixelSize: titleNameSize;
        wrapMode: Text.Wrap;
    }

}
