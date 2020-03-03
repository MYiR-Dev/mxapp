import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {

    visible: true

    width: 800
    height: 480
    title: qsTr("Hello QCustomPlot in QML")

//    Item {
//        id: mainView
//        anchors.fill: parent
//        PlotView {
//        }
//    }
    Image {
        id: rocket
        fillMode: Image.TileHorizontally
        smooth: true
        source: 'images/wvga/ecg/ecg_pic_bg.jpg'
    }
    Rectangle{
        x:0
        y:0
        width: 800
        height:33
        color: "transparent"
        Layout.fillWidth: true
        RowLayout{
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            HomeButton{
                id: logo
                label.visible: false
                clickable: true
                source: "images/wvga/home/header_logo.png"
                onClicked: {
                    popupFrame1.open()
                }
//                anchors{

//                    topMargin: 10
//                    leftMargin: 25
//                    verticalCenter: parent.verticalCenter
//                    }
            }
            Text {
                color: "#F5F5F5"
                text: qsTr("BED")

            }
            Text {
                color: "#F5F5F5"
                text: qsTr("NO:5")

            }
            Text {
                color: "#F5F5F5"
                text: qsTr("ADULT")

            }

            Button{

                //width: 15
                //height: 15
                //text:"1"
                 display: AbstractButton.TextBesideIcon
                icon.source:"images/wvga/ecg/health_off.png"
                text:"退出"
                icon.color:"transparent"
                background:Rectangle {
                            border.color: "transparent"
                            color: "#AFEEEE"
                            // I want to change text color next
                }
            }
//            Rectangle{
//                id:tt
//                color:"green"
//                width: 100
////                anchors.right: parent.right
////                anchors.rightMargin: 20

//                Text {
//                    id: time
//                    anchors.leftMargin: 20
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    font{
//                        family: localFont.name
//                        pointSize:14
//                    }
//                    text: "00:00:00";color: "white";// style: Text.Outline;
//                }

//                Text {
//                id: date
//                anchors.top:time.bottom
//                anchors.leftMargin: 20
//                anchors.horizontalCenter: parent.horizontalCenter
//        //        font.pointSize:8; text: qsTr("2020年2月25日");style: Text.Outline;styleColor: "white"
//                font{
//                    family: localFont.name
//                    pointSize:8
//                }
//        //        style: Text.Outline;
//                text: qsTr("2020年2月25日")
//                color: "white"

//            }
//            }

        }
        Timer{
            id:timer
            interval:100;running:true;repeat: true
            onTriggered: {
                var currentTime = new Date();
//                time.text = Qt.formatTime(currentTime,"hh:mm:ss");
                time1.text = Qt.formatTime(currentTime,"hh:mm");
//                date.text = Qt.formatDate(currentTime,"yyyy-MM-dd");
            }
        }

        Component.onCompleted: {
            timer.start();
        }
    }

    Rectangle{
        x:0
        y:33
        PlotView {
            opacity: 0.2
            width: 573
            height: 451
        }
     }
    Column {
        x:574
        y:33

        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 5
                //anchors.left: 20
                columns:3
                rows:3
                Text {
                    text:"ECG"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    text:"PACE"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:1
                }
                Image {
                    id: name
                    source: "images/wvga/ecg/heart.png"
                    Layout.row:0
                    Layout.column:2
                }
                Text {
                    text:"80"
                    color: "#00FF00"
                    Layout.row:1
                    Layout.column:0
                }
            }


        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 5
                //anchors.left: 20
                columns:3
                rows:3
                Text {
                    text:"NIBP"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    id: time1
                    text: "00:00:00"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:1
                }
                Text {
                    text: "mmhg";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:2
                }
                Text {
                    id:nibp
                    text: "120/80";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:0
                }
                Text {
                    id:mmhg
                    text: "90";
                    color: "#F8F8FF"
                    Layout.row:1
                    Layout.column:2

                }

            }
        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 5
                //anchors.left: 20
                columns:2
                rows:3
                Text {
                    text: "SPO2";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    text: "PR";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:1
                }
                Text {
                    text: "98";
                    color: "#FF6347"
                    Layout.row:1
                    Layout.column:0
                }
                Text {
                    text: "60";
                    color: "#FF6347"
                    Layout.row:1
                    Layout.column:1
                }
            }
        }

        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 5
                //anchors.left: 20
                columns:2
                rows:3
                Text {
                    text: "RESP";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    text: "20";
                    color: "yellow"
                    Layout.row:1
                    Layout.column:0
                }
            }

        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 5
                //anchors.left: 20
                columns:8
                rows:3
                Text {
                    text: "TEMP(℃)";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    text: "T1";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:0
                }
                Text {
                    text: "T2";
                    color: "#F5F5F5"
                    Layout.row:2
                    Layout.column:0
                }
                Text {
                    text: "37.7";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:1
                }
                Text {
                    text: "37.2";
                    color: "#F5F5F5"
                    Layout.row:2
                    Layout.column:1
                }
                Text {
                    text: "TD";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:3
                }
                Text {
                    text: "0.5";
                    color: "#F5F5F5"
                    Layout.row:2
                    Layout.column:3
                }
            }
        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
//            RowLayout {
                //anchors.fill: parent

                Button{

                    width: 15
                    height: 15
                    //text:"1"
                    icon.source:"images/wvga/ecg/heart.png"
                    icon.color:"transparent"


                }
//                Button{
//                    //text:"2"
//                    width: 15
//                    height: 15

//                }
//                Button{
//                    //text:"3"
//                    width: 15
//                    height: 15

//                }
//                Button{
//                    //text:"4"
//                    width: 15
//                    height: 15

//                }
//                Button{
//                    //text:"5"
//                    width: 65
//                    height: 85

//                }
//            }

        }



    }





}
