import QtQuick 2.0

Rectangle {
    id:root
    width:tt.width+5
    anchors{
        right: parent.right
        rightMargin: 5
        top: parent.top
        topMargin: 5
    }

    property real icongap: 16

//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

//    HomeButton{
//        id: logo
//        label.visible: false
//        clickable: true
//        source: "images/wvga/home/header_logo.png"
//        onClicked: {
//            popupFrame1.open()
//        }
//    }

    Rectangle{
        id:tt
        color:"green"
        width: 80
        anchors.right: parent.right
//        anchors.rightMargin: 20
//        anchors.topMargin: 5


    Text {
        id: time
        anchors.leftMargin: icongap
        anchors.horizontalCenter: parent.horizontalCenter
        font{
            family:"DS-Digital"
            pixelSize:14
        }
//        FontLoader { id: localFont; source: "qrc:/fonts/DIGITAL/DS-DIGIB.TTF" }
        text: "00:00:00";color: "white";// style: Text.Outline;
    }

    Text {
        id: date
        anchors.top:time.bottom
        anchors.leftMargin: icongap
        anchors.horizontalCenter: parent.horizontalCenter
//        font.pointSize:8; text: qsTr("2020年2月25日");style: Text.Outline;styleColor: "white"
//        FontLoader { id: localFont1; source: "qrc:/fonts/DIGITAL/DS-DIGIB.TTF" }
        font{
            family: "DS-Digital"
            pixelSize:10
        }
//        style: Text.Outline;
//        text: qsTr("2020年2月25日")
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
