import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

SystemWindow {
    id:scopeWindow
    title: qsTr("Hello QCustomPlot in QML")

//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

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
        source: 'images/wvga/ecg/ecg_bg4.png'
    }
    Rectangle{
        x:0
        y:0
        width: 800
        height:33
        color: "transparent"
        Layout.fillWidth: true


        HomeButton{
            id: logo
            label.visible: false
            clickable: true
            source: "images/wvga/home/header_logo.png"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: t1
            color: "#F5F5F5"
//            font.family: "Microsoft YaHei"
            text: qsTr("BED")
            anchors{
                left: logo.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: 100
                }
        }
        Text {
            id :t2
            color: "#F5F5F5"
//            font.family: "Microsoft YaHei"
            text: qsTr("NO:5")
            anchors{
                left: t1.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: 60
                }
        }
        Text {
            id: t3
            color: "#F5F5F5"
//            font.family: "Microsoft YaHei"
            text: qsTr("ADULT")
            anchors{
                left: t2.left
                verticalCenter: parent.verticalCenter
                topMargin: 10
                leftMargin: 60
                }
        }

        Rectangle{
            id:close_button
            width: 65
            height: 20
            color:"transparent"
            Image{
                anchors.fill: parent
                source: "images/wvga/ecg/health_off_bg.png"
            }
            Image{
                x:10
                y:5
                id:icon_image
                source:"images/wvga/ecg/health_off.png"
            }
            Text{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: icon_image.left
                anchors.leftMargin: 15
//                font.family: "Microsoft YaHei"
                text: qsTr("退出")
                color: "white"
            }
            anchors{
                left: t3.left
                verticalCenter: parent.verticalCenter
                topMargin: 0
                leftMargin: 430
            }
            MouseArea{
               anchors.fill: parent
                onExited:{
                   close_button.opacity = 1.0
                }
                onPressed: {

                   close_button.opacity = 0.5
                }

                onReleased: {
                    scopeWindow.close()
                    close_button.opacity = 1.0

                }
            }
        }
        Rectangle{
            id: tt
            color:"transparent"
            width:  100
            height: 33
            anchors.left: close_button.right
            anchors.right: parent.right


            Text {
                id: time
                 anchors.rightMargin: 10
                anchors.right: parent.right
                //anchors.leftMargin: 20
//                anchors.horizontalCenter: parent.horizontalCenter
                font{
                    family: "DS-Digital"
                    pointSize:14
                }
                text: "00:00:00";color: "white";// style: Text.Outline;
            }

            Text {
                id: date
                anchors.top:time.bottom
                anchors.rightMargin: 10
                anchors.right: parent.right
                //anchors.leftMargin: 20
                //anchors.horizontalCenter: parent.horizontalCenter

                font{
                    family:"DS-Digital"
                    pointSize:8
                }
        //        style: Text.Outline;
                text: qsTr("2020年2月25日")
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
        y:30
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
                anchors.margins: 10
                //anchors.left: 20
                columns:3
                rows:3

                Text {
//                    font.family: "Microsoft YaHei"
                    text:"ECG"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
//                    font.family: "Microsoft YaHei"
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
                    id:ecg_value
//                    font.family: "Microsoft YaHei"
                    text:"80"
                    color: "#00FF00"
                    Layout.row:1
                    Layout.column:0
                    font{
                        capitalization: Font.Capitalize
                        pointSize:20
                    }

                }
            }


        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 10
                //anchors.left: 20
                columns:3
                rows:3
                Text {
//                    font.family: "Microsoft YaHei"
                    text:"NIBP"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: time1
//                    font.family: "Microsoft YaHei"
                    text: "00:00:00"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:1
                }
                Text {
//                    font.family: "Microsoft YaHei"
                    text: "mmhg";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:2
                }
                Text {
                    id:nibp_value
//                    font.family: "Microsoft YaHei"
                    text: "120/80";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:0
                    font{
                        capitalization: Font.Capitalize
                        pointSize:20
                    }
                }
                Text {
                    id:mmhg_value
//                    font.family: "Microsoft YaHei"
                    text: "90";
                    color: "#F8F8FF"
                    Layout.row:1
                    Layout.column:2
                    font{
                        capitalization: Font.Capitalize
                        pointSize:20
                    }
                }

            }
        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 10
                //anchors.left: 20
                columns:2
                rows:3
                Text {
//                    font.family: "Microsoft YaHei"
                    text: "SPO2";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
//                    font.family: "Microsoft YaHei"
                    text: "PR";
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:1
                }
                Text {
                    id:spo2_value
//                    font.family: "Microsoft YaHei"
                    text: "98";
                    color: "#FF6347"
                    Layout.row:1
                    Layout.column:0
                    font{
                        capitalization: Font.Capitalize
                        pointSize:20
                    }
                }
                Text {
                    id:pr_value
                    text: "60";
//                    font.family: "Microsoft YaHei"
                    color: "#FF6347"
                    Layout.row:1
                    Layout.column:1
                    font{
                        capitalization: Font.Capitalize
                        pointSize:20
                    }
                }
            }
        }

        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.margins: 10
                //anchors.left: 20
                columns:2
                rows:3
                Text {
                    text: "RESP";
//                    font.family: "Microsoft YaHei"
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    id:resp_value
//                    font.family: "Microsoft YaHei"
                    text: "20";
                    color: "yellow"
                    Layout.row:1
                    Layout.column:0
                    font{
                        capitalization: Font.Capitalize
                        pointSize:20
                    }
                }
            }

        }
        Rectangle {
            color: "transparent"
            width: 227
            height: 74
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.leftMargin: 10
                columns:3
                rows:3
                Text {
//                    font.family: "Microsoft YaHei"
                    text: qsTr("TEMP(℃)");
                    color: "#F5F5F5"
                    Layout.row:0
                    Layout.column:0
                }
                Text {
                    id: temp1
                    text: "T1";
//                    font.family: "Microsoft YaHei"
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:0
                }
                Text {
                    id: temp2
                    text: "T2";
//                    font.family: "Microsoft YaHei"
                    color: "#F5F5F5"
                    Layout.row:2
                    Layout.column:0
                }
                Text {
                    id:temp1_value
//                    font.family: "Microsoft YaHei"
                    text: "37.7";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:1
                    anchors{
                        left: temp1.left
                        //topMargin: 10
                        leftMargin: 50
                    }
                    font{
                        capitalization: Font.Capitalize
                        pointSize:12
                    }
                }
                Text {
                    id:temp2_value
//                    font.family: "Microsoft YaHei"
                    text: "37.2";
                    color: "#F5F5F5"
                    Layout.row:2
                    Layout.column:1
                    anchors{
                        left: temp2.left
                        //topMargin: 10
                        leftMargin: 50
                    }
                    font{
                        capitalization: Font.Capitalize
                        pointSize:12
                    }
                }
                Text {
//                    font.family: "Microsoft YaHei"
                    text: "TD";
                    color: "#F5F5F5"
                    Layout.row:1
                    Layout.column:3
                }
                Text {
                    id:td_value
//                    font.family: "Microsoft YaHei"
                    text: "0.5";
                    color: "#F5F5F5"
                    Layout.row:2
                    Layout.column:3
                    font{
                        capitalization: Font.Capitalize
                        pointSize:12
                    }
                }
            }
        }
        Rectangle {
            id: btrec
            color: "transparent"
            width: 227
            height: 74

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
                        left: btrec.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
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
                       left: bt1.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 40
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
                        left: bt2.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 40
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
                        left: bt3.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 40
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
                        left: bt4.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 40
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
