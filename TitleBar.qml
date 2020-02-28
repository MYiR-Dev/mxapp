import QtQuick 2.0

Item {
    id:root
    anchors{
        top: parent.top
        left: parent.left
        topMargin: 5
        leftMargin: 20
    }
    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

    HomeButton{
        id: logo
        label.visible: false
        clickable: true
        source: "images/wvga/home/header_logo.png"
        onClicked: {
            popupFrame1.open()
        }
    }

    HomeButton{
        id: btIcon
        label.visible: false
        clickable: false
        source: "images/wvga/home/bt.png"
        anchors{
            left: logo.left
            verticalCenter: parent.verticalCenter
            topMargin: 10
            leftMargin: 600
            }
    }
    HomeButton{
        id: ethIcon
        label.visible: false
        clickable: false
        source: "images/wvga/home/eth.png"
        anchors{
            left: btIcon.left
            topMargin: 10
            leftMargin: 25
            verticalCenter: parent.verticalCenter
            }
    }
    HomeButton{
            id: wifiIcon
//            anchors.margins: 5
            label.visible: false
//            height: 24
            clickable: false
            source: "images/wvga/home/wifi.png"
            anchors{
                left:ethIcon.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: 25
            }
    }
    HomeButton{
            id: mobiIcon
//            anchors.margins: 5
            label.visible: false
//           height: 24
            clickable: false
            source: "images/wvga/home/mobile.png"
            anchors{
                left:wifiIcon.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: 25
            }
    }

    Rectangle{
        id:tt
        color:"green"
        width: 100
        anchors.right: parent.right
        anchors.rightMargin: 20

    Text {
        id: time
        anchors.leftMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        font{
            family: localFont.name
            pointSize:14
        }
        text: "00:00:00";color: "white";// style: Text.Outline;
    }

    Text {
        id: date
        anchors.top:time.bottom
        anchors.leftMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
//        font.pointSize:8; text: qsTr("2020年2月25日");style: Text.Outline;styleColor: "white"
        font{
            family: localFont.name
            pointSize:8
        }
//        style: Text.Outline;
        text: qsTr("2020年2月25日")
        color: "white"

    }
}

    SupportPop {
        id: popupFrame1
        x: 20
        y: 32
        nowPoint: Qt.point(20,20)
        width: 720
        height: 400
        title: "PopupFrame1"
        Rectangle {
            // 标题栏高度
            property int titleBarHeight: 35

            width: parent.width - 10
            height: parent.height - titleBarHeight - 6
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: titleBarHeight + 1
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5
            Text {
                anchors.centerIn: parent
                text: qsTr("PopupFrame1 content")
            }
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
