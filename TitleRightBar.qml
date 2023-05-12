import QtQuick 2.0

Rectangle {
    id:root
    anchors{
        right: parent.right
        rightMargin: 5
        top: parent.top
        topMargin: 5
    }

    property real icongap: 16

    HomeButton{
        id: btIcon
        label.visible: false
        clickable: false
        visible: false
        source: "images/wvga/home/bt.png"
        anchors{
            right: ethIcon.left
            rightMargin: icongap
            top: parent.top
            topMargin: 10
        }
    }
    HomeButton{
        id: ethIcon
        label.visible: false
        clickable: false
        visible: false
        source: "images/wvga/home/eth.png"
        anchors{
            right: wifiIcon.left
            rightMargin: icongap
            top: parent.top
            topMargin: 10
        }
    }
    HomeButton{
        id: wifiIcon
        label.visible: false
        visible: false
        clickable: false
        source: "images/wvga/home/wifi.png"
        anchors{
            right:mobiIcon.left
            rightMargin: icongap
            top: parent.top
            topMargin: 10
        }
    }
    HomeButton{
        id: mobiIcon
        label.visible: false
        visible: false
        clickable: false
        source: "images/wvga/home/mobile.png"
        anchors{
            right:tt.left
            rightMargin: icongap
            top: parent.top
            topMargin: 10
        }
    }

    Rectangle{
        id:tt
        color:"green"
        width: 80
        anchors.right: parent.right

        Text {
            id: time
            anchors.leftMargin: icongap
            anchors.horizontalCenter: parent.horizontalCenter
            font{
                family:"DS-Digital"
                pixelSize:14
            }
            text: "00:00:00";color: "white";// style: Text.Outline;
        }

        Text {
            id: date
            anchors.top:time.bottom
            anchors.leftMargin: icongap
            anchors.horizontalCenter: parent.horizontalCenter
            font{
                family: "DS-Digital"
                pixelSize:10
            }
            color: "white"

        }
    }

    Timer{
        id:timer
        interval:100;running:true;repeat: true
        onTriggered: {
            var currentTime = new Date();
            time.text = Qt.formatTime(currentTime,"hh:mm:ss");
            date.text = Qt.formatDate(currentTime,"yyyy-MM-dd");
        }
    }

    Component.onCompleted: {
        timer.start();
    }
}
