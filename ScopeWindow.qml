import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
SystemWindow {
    id:scopeWindow
//    title: qsTr("")
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

//    Item {
//        id: mainView
//        anchors.fill: parent
//        PlotView {
//        }
//    }
    Image {
        id: rocket
//        fillMode: Image.TileHorizontally
        smooth: true
        width: adaptive_width
        height: adaptive_height
        source: 'images/wvga/ecg/ecg_bg5.png'
    }
    Rectangle{
        x:0
        y:0
        width: adaptive_width
        height:adaptive_height/14.54
        color: "transparent"
        Layout.fillWidth: true


        HomeButton{
            id: logo
            label.visible: false
            width: adaptive_width/9.09
            height: adaptive_height/34.28
            clickable: true
            source: "images/fhd/ecg/header_logo.png"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: t1
            color: "#F5F5F5"
            font.family: "Microsoft YaHei"
            font.pixelSize: 20
            text: qsTr("BED")
            anchors{
                left: logo.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: adaptive_width/8
                }
        }
        Text {
            id :t2
            color: "#F5F5F5"
            font.family: "Microsoft YaHei"
            font.pixelSize: 20
            text: qsTr("NO:5")
            anchors{
                left: t1.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: adaptive_width/13.3
                }
        }
        Text {
            id: t3
            color: "#F5F5F5"
            font.family: "Microsoft YaHei"
            font.pixelSize: 20
            text: qsTr("ADULT")
            anchors{
                left: t2.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: adaptive_width/13.3
                }
        }
        Image{
                id: close
                source: "qrc:/images/wvga/smart/smart_btn_quit_nor.png"
//                width: adaptive_width/12
//                height: adaptive_height/19.2
                width: 66
                height:25
                anchors{
                    right:tt.left
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                Image {
                    id: pwroff
//                    width: adaptive_width/66.66
//                    height: adaptive_height/40
                    width: 12
                    height: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_quit_nor.png"
                }

                Text {
                    id: txtexit
                    anchors.left: pwroff.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Microsoft YaHei"
                    text: qsTr("退出")
                    font.pointSize: 11
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        scopeWindow.close();
                    }

                    onPressed: {
                        close.source="qrc:/images/wvga/smart/smart_btn_quit_hover.png"
                    }
                    onReleased: {
                        close.source="qrc:/images/wvga/smart/smart_btn_quit_nor.png"
                    }
                }
        }

        Rectangle{
            id:tt
            color:"transparent"
            width: 80
            height:30 /*adaptive_height/15*/
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
    //        anchors.rightMargin: 20
    //        anchors.topMargin: 5


        Text {
            id: time
            anchors.leftMargin: 15
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
            anchors.leftMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
    //        font.pointSize:8; text: qsTr("2020年2月25日");style: Text.Outline;styleColor: "white"
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
            interval:1000;running:true;repeat: true
            onTriggered: {
                var currentTime = new Date();
                cnt++
                time.text = Qt.formatTime(currentTime,"hh:mm:ss");
                time1.text = Qt.formatTime(currentTime,"hh:mm");
                date.text = Qt.formatDate(currentTime,"yyyy-MM-dd");
                ecg_value.text = ecgArray[cnt%4]
                nibp_value.text = nibpArray[cnt%4]
                mmhg_value.text = mmhgArray[cnt%4]
                spo2_value.text = spo2Array[cnt%4]
                pr_value.text = prArray[cnt%4]
                resp_value.text = respArray[cnt%4]
                temp1_value.text = temp1Array[cnt%4]
                temp2_value.text = temp2Array[cnt%4]
                td_value.text = tdArray[cnt%4]
            }
        }

        Component.onCompleted: {
            timer.start();
        }
    }
    property int cnt:0
    property var ecgArray:["60","59","61","62"]
    property var nibpArray:["120/80","119/79","121/81","118/78"]
    property var mmhgArray:["90","91","89","92"]
    property var spo2Array:["98","99","97","96"]
    property var prArray:["60","59","61","62"]
    property var respArray:["20","21","22","19"]
    property var temp1Array:["36.8","36.5","36.4","36.9"]
    property var temp2Array:["36.7","36.4","36.8","36.9"]
    property var tdArray:["0.5","0.6","0.4","0.5"]


    Rectangle{
        x:0
        y:adaptive_height/15
        PlotView {
            opacity: 0.2
            width: adaptive_width/1.395
            height: adaptive_height/1.06
        }
     }
    Column {
        x:adaptive_width/1.39
        y:adaptive_height/14.54

        Rectangle {
            id:rec1
            color: "transparent"
            width: adaptive_width/3.52
            height: adaptive_height/7.5
//            width: 227
//            height: 64


            Text {
                font.family: "Microsoft YaHei"
                text:"ECG"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/96
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                font.family: "Microsoft YaHei"
                id:pace_text
                text:"PACE"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/96
                    left: parent.left
                    leftMargin: adaptive_width/10
                }
            }
            Image {
                id: name
                source: "images/wvga/ecg/heart.png"
                anchors{
//                    top: parent.top
//                    topMargin: 5
                    left: parent.left
                    leftMargin: adaptive_width/5
                    verticalCenter:pace_text.verticalCenter
                }
            }
            Text {
                id:ecg_value
                font.family: "Microsoft YaHei"
                text:"80"
                color: "#00FF00"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/19.2
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
                font{
//                    capitalization: Font.Capitalize
                    pixelSize:30
                }

            }



        }
        Rectangle {
            color: "transparent"
            width: adaptive_width/3.52
            height: adaptive_height/6.48
//            width: 227
//            height: 74

            Text {
                font.family: "Microsoft YaHei"
                text:"NIBP"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                id: time1
                font.family: "Microsoft YaHei"
                text: "00:00:00"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/10
                }
            }
            Text {
                font.family: "Microsoft YaHei"
                text: "mmhg";
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/5
                }
            }
            Text {
                id:nibp_value
                font.family: "Microsoft YaHei"
                text: "120/80";
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/13.7
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:30
                }
            }
            Text {
                id:mmhg_value
                font.family: "Microsoft YaHei"
                text: "90";
                color: "#F8F8FF"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/13.7
                    left: parent.left
                    leftMargin: adaptive_width/5
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:30
                }
            }


        }
        Rectangle {
            color: "transparent"
            width: adaptive_width/3.52
            height: adaptive_height/6.48
//            width: 227
//            height: 74

            Text {
                font.family: "Microsoft YaHei"
                text: "SPO2";
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                font.family: "Microsoft YaHei"
                text: "PR";
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/6.15
                }
            }
            Text {
                id:spo2_value
                font.family: "Microsoft YaHei"
                text: "98";
                color: "#FF6347"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/13.7
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:30
                }
            }
            Text {
                id:pr_value
                text: "60";
                font.family: "Microsoft YaHei"
                color: "#FF6347"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/13.7
                    left: parent.left
                    leftMargin: adaptive_width/6.15
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:30
                }
            }

        }

        Rectangle {
            color: "transparent"
            width: adaptive_width/3.52
            height: adaptive_height/6.48
//            width: 227
//            height: 74

            Text {
                text: "RESP";
                font.family: "Microsoft YaHei"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                id:resp_value
                font.family: "Microsoft YaHei"
                text: "20";
                color: "yellow"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/13.7
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:30
                }
            }


        }
        Rectangle {
            color: "transparent"
            width: adaptive_width/3.52
            height: adaptive_height/6.48
//            width: 227
//            height: 74

            Text {
                font.family: "Microsoft YaHei"
                text: qsTr("TEMP(℃)");
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/48
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                id: temp1
                text: "T1";
                font.family: "Microsoft YaHei"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/16
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                id: temp2
                text: "T2";
                font.family: "Microsoft YaHei"
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/8.72
                    left: parent.left
                    leftMargin: adaptive_width/80
                }
            }
            Text {
                id:temp1_value
                font.family: "Microsoft YaHei"
                text: "37.7";
                color: "#F5F5F5"

                anchors{
                    left: temp1.left
                    top: parent.top
                    topMargin: adaptive_height/16
                    leftMargin: adaptive_width/16
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:15
                }
            }
            Text {
                id:temp2_value
                font.family: "Microsoft YaHei"
                text: "37.2";
                color: "#F5F5F5"

                anchors{
                    left: temp2.left
                    top: parent.top
                    topMargin: adaptive_height/8.72
                    leftMargin: adaptive_width/16
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:15
                }
            }
            Text {
                font.family: "Microsoft YaHei"
                text: "TD";
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin:  adaptive_height/16
                    left: parent.left
                    leftMargin: adaptive_width/4.4
                }
            }
            Text {
                id:td_value
                font.family: "Microsoft YaHei"
                text: "0.5";
                color: "#F5F5F5"
                anchors{
                    top: parent.top
                    topMargin: adaptive_height/8.72
                    left: parent.left
                    leftMargin: adaptive_width/4.4
                }
                font{
                    capitalization: Font.Capitalize
                    pixelSize:15
                }
            }

        }
        Rectangle {
            id: btrec
            color: "transparent"
            width: adaptive_width/3.52
            height: adaptive_height/8.64
//            width: 227
//            height: 85

                Button{
                    id: bt1
                    icon.source:"images/wvga/ecg/health_stop.png"
                    icon.color:"transparent"

                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 29
                        height: 29
                        border.color: "transparent"
                        color:"transparent"
                        Image {

                            anchors.fill: parent
                            source: "images/wvga/ecg/btn_bg.png"
                        }

                    }
                    anchors{
                        top:parent.top
                        topMargin: adaptive_height/12.97
                        left: btrec.left
//                        verticalCenter: parent.verticalCenter
                        leftMargin: adaptive_width/80
                    }

                    MouseArea{
                        anchors.fill: parent
                        onExited:{
                          bt1.opacity = 1.0
                        }
                        onPressed: {

                          bt1.opacity = 0.5
                        }

                        onReleased: {

                          bt1.opacity = 1.0
                        }
                    }

                }
                Button{
                    id: bt2
                    icon.source:"images/wvga/ecg/save.png"
                    icon.color:"transparent"
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 29
                        height: 29
                        border.color: "transparent"
                        color:"transparent"
                        Image {

                            anchors.fill: parent
                            source: "images/wvga/ecg/btn_bg.png"
                        }

                    }
                    anchors{
                        top:parent.top
                        topMargin: adaptive_height/12.97
                       left: bt1.left
//                       verticalCenter: parent.verticalCenter
                       leftMargin: adaptive_width/20
                    }

                    MouseArea{
                        anchors.fill: parent
                        onExited:{
                           bt2.opacity = 1.0
                        }
                        onPressed: {

                          bt2.opacity = 0.5
                        }

                        onReleased: {

                          bt2.opacity = 1.0
                        }
                    }

                }
                Button{
                    id: bt3
                    icon.source:"images/wvga/ecg/health_prin.png"
                    icon.color:"transparent"
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 29
                        height: 29
                        border.color: "transparent"
                        color:"transparent"
                        Image {

                            anchors.fill: parent
                            source: "images/wvga/ecg/btn_bg.png"
                        }

                    }
                    anchors{
                        top:parent.top
                        topMargin: adaptive_height/12.97
                        left: bt2.left
//                        verticalCenter: parent.verticalCenter
                        leftMargin: adaptive_width/20
                    }

                    MouseArea{
                        anchors.fill: parent
                        onExited:{
                           bt3.opacity = 1.0
                        }
                        onPressed: {

                          bt3.opacity = 0.5
                        }

                        onReleased: {

                          bt3.opacity = 1.0
                        }
                    }

                }
                Button{
                    id: bt4
                    icon.source:"images/wvga/ecg/health_set.png"
                    icon.color:"transparent"
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 29
                        height: 29
                        border.color: "transparent"
                        color:"transparent"
                        Image {

                            anchors.fill: parent
                            source: "images/wvga/ecg/btn_bg.png"
                        }

                    }
                    anchors{
                        top:parent.top
                        topMargin: adaptive_height/12.97
                        left: bt3.left
//                        verticalCenter: parent.verticalCenter
                        leftMargin: adaptive_width/20
                    }


                    MouseArea{
                        anchors.fill: parent

                        onExited:{
                           bt4.opacity = 1.0
                        }
                        onPressed: {

                          bt4.opacity = 0.5
                        }

                        onReleased: {

                          bt4.opacity = 1.0
                        }

                    }

                }
                Button{
                    id: bt5
//                    icon.source:"images/wvga/ecg/spinner.png"
//                    icon.color:"transparent"

                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 41
                        border.color: "transparent"
                        color:"transparent"
                        Image {

                            anchors.fill: parent
                            source: "images/wvga/ecg/spinner.png"
                        }

                    }
                    anchors{
//                        top:parent.top
//                        topMargin: adaptive_height/12.97
                        left: bt4.left
                        verticalCenter: bt4.verticalCenter
                        leftMargin: adaptive_width/20
                    }

                    MouseArea{
                        anchors.fill: parent
                        onExited:{
                           bt5.opacity = 1.0
                        }
                        onPressed: {

                          bt5.opacity = 0.5
                        }

                        onReleased: {

                          bt5.opacity = 1.0
                        }
                    }

                }


        }



    }





}
