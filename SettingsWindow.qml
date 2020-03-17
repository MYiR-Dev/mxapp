import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import GetSystemInfoAPI 1.0
//import QtQuick.VirtualKeyboard 2.1
import QtQuick.Layouts 1.0

SystemWindow {
    id: settingsWindow
    title: "settings"

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: "系统设置"
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            settingsWindow.close()
//            info_timer.stop()
        }

    }
    GetSystemInfo{
        id:getSyetemInfo

    }
    TitleRightBar{
        anchors{
            top: parent.top
            right: parent.right
            rightMargin: 10
        }
    }
    GetSystemInfo{
        id:getSystemInfo
    }
    Rectangle{
        anchors{
            top: parent.top
            topMargin: 50
        }
        color:"transparent"
        width:750
        height:480
        SwipeView {
            id: view
            orientation:Qt.Vertical
            anchors.fill: parent
            interactive: false
            anchors{
                top: parent.top
                left: navigationbar.left
                leftMargin: 150
            }
            Item {
                id: firstPage
                Rectangle{
                    width:630
                    height:300
                    color:"transparent"

                    Text{
                        id:title
                        text: qsTr("时间")
                        font.pointSize: 16;
                        font.bold: true
                        color: "white"
                        anchors{
                            left:    parent.left
                            leftMargin: 30

                        }
                    }

                    RowLayout{
                        id:row_layout
                        width:100
                        height:30
                        anchors{
                            top:    title.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

                        }

                        CustomCombox{
                            id:combox_hour
                             property date currentTime: new Date()
//                            property alias combox_control:control
//                            combox_control:ddd
//                            ComboBox.id:control
//                            control: "hour_control"
                            modeldata: ["0","1", "2", "3","4", "5", "6","7", "8", "9","10", "11", "12",
                                "13", "14", "15","16", "17", "18","19", "20", "21","22", "23", "24"]
                            Component.onCompleted: {

                                combox_hour.combox_control.currentIndex =Number(Qt.formatTime(currentTime,"hh"))

                            }
                        }

                        Text{

                            text: ":"
                            font.pointSize: 15;
                            font.bold: true
                            color: "white"

                        }
                        CustomCombox{
                            id:combox_min
                             property date currentTime: new Date()
                            modeldata: ["0","1", "2", "3","4", "5", "6","7", "8", "9","10",
                                        "11", "12", "13","14", "15", "16","17", "18", "19","20",
                                        "21", "22", "23","24", "25", "26","27", "28", "29","30",
                                        "31", "32", "33","34", "35", "36","37", "38", "39","40",
                                        "41", "42", "43","44", "45", "46","47", "48", "49","50",
                                        "51", "52", "53","54", "55", "56","57", "58", "59","60",]

                            Component.onCompleted: {

                                combox_min.combox_control.currentIndex =Number(Qt.formatTime(currentTime,"mm"))

                            }
                        }
                        Text{

                            text: ":"
                            font.pointSize: 15;
                            font.bold: true
                            color: "white"
                        }
                        CustomCombox{
                            id:combox_sec
                             property date currentTime: new Date()
                            modeldata: ["0","1", "2", "3","4", "5", "6","7", "8", "9","10",
                                        "11", "12", "13","14", "15", "16","17", "18", "19","20",
                                        "21", "22", "23","24", "25", "26","27", "28", "29","30",
                                        "31", "32", "33","34", "35", "36","37", "38", "39","40",
                                        "41", "42", "43","44", "45", "46","47", "48", "49","50",
                                        "51", "52", "53","54", "55", "56","57", "58", "59","60",]

                            Component.onCompleted: {

                                combox_sec.combox_control.currentIndex =Number(Qt.formatTime(currentTime,"ss"))
                            }
                        }
//                        Rectangle{
//                            id: comboBox
//                            width:47
//                            height:28
//                            color:"transparent"
//                            Image {
//                                anchors.fill: parent
//                                source: "images/wvga/system/day-rec.png"
//                            }
//                            Image {
//                                id:sec_dw
//                                source: "images/wvga/system/drop-down.png"
//                                anchors{
//                                    right:    parent.right
//                                    verticalCenter:parent.verticalCenter
//                                    rightMargin: 5
//                                }
//                            }
//                            Text{
//                                property date currentTime: new Date()
//                                text: {

//                                    Qt.formatTime(currentTime,"ss")
//                                }
//                                font.pointSize: 15;
//                                font.family:localFont.name

//                                color: "white"
//                                anchors{
//                                    verticalCenter:parent.verticalCenter
//                                    right:sec_dw.left
//                                    rightMargin: 5
//                                }
//                            }
//                        }


                    }
                    property var date
                    Text{
                        id:time_value
                        text: get_time()
                        font.pointSize: 12;
                        font.bold: true
                        color: "#059EC9"
                        anchors{
                            top:    row_layout.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

                        }

                        function get_time(){
                            return Qt.formatDateTime(new Date(), "yyyy年MM月dd日,ddd");

                        }



                    }
                    RowLayout{
                        id:row_layout1
                        width:100
                        height:30
                        anchors{
                            top:    time_value.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

                        }
                        CustomCombox{
                            id:combox_year
                            delegate_width:80
                            property date currentTime: new Date()
                            modeldata: ["2015"+qsTr("年"),+"2016"+qsTr("年"), "2017"+qsTr("年"),"2018"+qsTr("年"), "2019"+qsTr("年"), "2020"+qsTr("年"),
                                "2021"+qsTr("年"), "2022"+qsTr("年"), "2023"+qsTr("年"),"2024"+qsTr("年"),"2025"+qsTr("年")]
                            Component.onCompleted: {
                                if(currentTime.getFullYear()-2015 < 0)
                                    combox_year.combox_control.currentIndex = 0
                                else
                                    combox_year.combox_control.currentIndex =currentTime.getFullYear()-2015

                            }

                        }
                        CustomCombox{
                            id:combox_mon
                            delegate_width:60
                            property date currentTime: new Date()

                            modeldata: ["1"+qsTr("月"), "2"+qsTr("月"), "3"+qsTr("月"),"4"+qsTr("月"), "5"+qsTr("月"), "6"+qsTr("月"),
                                        "7"+qsTr("月"), "8"+qsTr("月"), "9"+qsTr("月"),"10"+qsTr("月"),"11"+qsTr("月"), "12"+qsTr("月")]
                            Component.onCompleted: {

                                combox_mon.combox_control.currentIndex = currentTime.getMonth()

                            }

                        }
                        CustomCombox{
                            id:combox_day
                            delegate_width:60
                            property date currentTime: new Date()
                            modeldata: ["1"+qsTr("日"), "2"+qsTr("日"), "3"+qsTr("日"),"4"+qsTr("日"), "5"+qsTr("日"), "6"+qsTr("日"),"7"+qsTr("日"), "8"+qsTr("日"),"9"+qsTr("日"),"10"+qsTr("日"),
                                        "11"+qsTr("日"), "12"+qsTr("日"), "13"+qsTr("日"),"14"+qsTr("日"), "15"+qsTr("日"), "16"+qsTr("日"),"17"+qsTr("日"), "18"+qsTr("日"),"19"+qsTr("日"),"20"+qsTr("日"),
                                        "21"+qsTr("日"), "22"+qsTr("日"), "23"+qsTr("日"),"24"+qsTr("日"), "25"+qsTr("日"), "26"+qsTr("日"),"27"+qsTr("日"), "28"+qsTr("日"),"29"+qsTr("日"),"30"+qsTr("日"),
                                         "31"+qsTr("日")]
                            Component.onCompleted: {
                                combox_day.combox_control.currentIndex =currentTime.getDate()-1

                            }
                        }
                    }

                    CustomCalendar{
                        id:custom_calendar
                        width:350
                        height: 210
                        color: "transparent"
                        anchors{
                            top:    row_layout1.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 20

                        }
                    }
                    Rectangle{
                        id:save_button_rec
                        width: 106
                        height: 31
                        color: "transparent"
                        anchors{
                            top: custom_calendar.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

                        }
                        Image {
                            id: name

                            anchors.fill: parent
                            source: "images/wvga/system/save-button.png"
                        }
                        Text{
                            id:save_button
                            text: qsTr("保存")
                            font.pointSize: 10;
                            font.bold: true
                            color: "white"
                            anchors{
                                centerIn: parent
                            }
                        }
                        MouseArea{
                            anchors.fill: parent;
                            onClicked: {
                                save_button_rec.opacity = 0.5

                                var date_string = combox_hour.combox_control.currentText + " " +combox_min.combox_control.currentText + " " +
                                        combox_sec.combox_control.currentText + " " + combox_year.combox_control.currentText + " " +
                                        combox_mon.combox_control.currentText + " " +combox_day.combox_control.currentText
                                getSyetemInfo.set_date(date_string)

                            }
                            onExited:{
                               save_button_rec.opacity = 1.0
                            }
                            onPressed: {

                               save_button_rec.opacity = 0.5
                            }
                        }
                    }

                }


            }
            Item {
                id: secondPage
                Rectangle{
                    width:630
                    height:419
                    color:"transparent"
                    Text{
                        id:eth
                        text: "以太网"
                        font.pointSize: 15;
                        font.bold: true
                        color: "white"
                        anchors{

                            left: parent.left
                            leftMargin: 30


                        }
                    }
                    GridLayout{
                        width:400
                        height:100
                        rows: 7
                        columns:2
                        anchors{

                            top: eth.bottom
                            topMargin: 30


                        }
                        Text{

                            text: "以太网"
                            font.pointSize: 10;

                            color: "white"
                            anchors{
                                left: parent.left
                                leftMargin: 30
                            }
                            Layout.row: 0
                            Layout.column: 0
                        }
                        Text{

                            text: "电缆已拔出"
                            font.pointSize: 10;

                            color: "white"
//                            anchors{
//                                left: parent.left
//                                leftMargin: 30
//                            }
                            Layout.row: 0
                            Layout.column: 1
                        }
                        Text{

                            text: "配置IPv4"
                            font.pointSize: 10;

                            color: "white"
                            anchors{
                                left: parent.left
                                leftMargin: 30
                            }
                            Layout.row: 1
                            Layout.column: 0
                        }
                        CustomCombox{
                            id:combox_dhcp
                            delegate_width:141
                            combox_bg:"images/wvga/system/input-bg.png"
                            modeldata: ["Manual", "DHCP"]

                            Layout.row: 1
                            Layout.column: 1
                        }
//                        Text{

//                            text: "xx"
//                            font.pointSize: 10;

//                            color: "white"

//                            Layout.row: 1
//                            Layout.column: 1
//                        }
                        Text{

                            text: "IP地址"
                            font.pointSize: 10;

                            color: "white"
                            anchors{
                                left: parent.left
                                leftMargin: 30
                            }

                            Layout.row: 2
                            Layout.column: 0
                        }

                        TextField {

                            id: digitsField
                            width: 141
                            height: 16
                            placeholderText: "192.168.30.111" /* 输入为空时显示的提示文字 */

//                            style:TextFieldStyle {
//                                textColor: "white"
//                                placeholderTextColor :"lightgrey"
//                            }
                            background: Rectangle{

                                implicitWidth:141
                                implicitHeight:16
                                color: "transparent"
                                Image {
                                    id: dd
                                    anchors.fill: parent
                                    source: "images/wvga/system/input-bg.png"
                                }
                            }



                            Layout.row: 2
                            Layout.column: 1
                        }
                        Text{

                            text: "子网掩码"
                            font.pointSize: 10;

                            color: "white"
                            anchors{
                                left: parent.left
                                leftMargin: 30
                            }
                            Layout.row: 3
                            Layout.column: 0
                        }
                        Text{

                            text: "255.255.255.0"
                            font.pointSize: 10;

                            color: "white"

                            Layout.row: 3
                            Layout.column: 1
                        }
                        Text{

                            text: "路由器"
                            font.pointSize: 10;

                            color: "white"
                            anchors{
                                left: parent.left
                                leftMargin: 30
                            }
                            Layout.row: 4
                            Layout.column: 0
                        }
                        Text{

                            text: "192.168.30.1"
                            font.pointSize: 10;

                            color: "white"

                            Layout.row: 4
                            Layout.column: 1
                        }
                    }

                }
            }
            Item {
                id: thirdPage
                Rectangle{
                    width:630
                    height:419
                    color:"transparent"
                    Text{
                        id:wifi_set_title
                        text: "WIFI设置"
                        font.pointSize: 15;
                        font.bold: true
                        color: "white"
                        anchors{

                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    Rectangle{
                         width: 60
                         height: 17
                         color: "transparent"
                         Image {
                             id: open_gb
                             anchors.fill: parent
                             source: "images/wvga/system/open-bg.png"
                         }
                         Image {
                             height: 20
                             id: open
                             source: "images/wvga/system/open-icon.png"
                             anchors.right: parent.right
                         }
                        anchors{
//                           left:wifi_set_title.right
                           bottom: wifi_set_title.bottom
                           right: parent.right
                        }
                    }
                    Rectangle{
                        id:serch_rec
                        width: 548
                        height: 32
                        color: "transparent"
                        Image {
                            id: serch_gb
                            anchors.fill: parent
                            source: "images/wvga/system/serch-bg.png"
                        }
                        Image {
                            id: serch_icon
                            anchors.centerIn: parent
                            source: "images/wvga/system/serch-icon.png"
                        }
                        Text{

                            text: qsTr("扫描")
                            font.pointSize: 12;
                            font.bold: true
                            color: "white"
                            anchors{
                                left: serch_icon.left
                                leftMargin: 20
                                verticalCenter: serch_icon.verticalCenter
                            }

                        }
                        MouseArea{
                            anchors.fill: parent;
                            onClicked: {
                                serch_rec.opacity = 0.5

                            }
                            onExited:{
                               serch_rec.opacity = 1.0
                            }
                            onPressed: {

                               serch_rec.opacity = 0.5
                            }
                        }
                        anchors{
                            left: parent.left
                            leftMargin: 30
                            top: wifi_set_title.bottom
                            topMargin: 10
                        }
                    }
                    Rectangle{
                        width: 548
                        height: 32
                        color: "transparent"
                        anchors{
                            left: parent.left
                            leftMargin: 30
                            top: serch_rec.bottom
                            topMargin: 10
                        }
                        Text{

                            text: qsTr("myir-wifi")
                            font.pointSize: 8;
                            font.bold: true
                            color: "white"
                            anchors{

                                top:parent.top

                            }

                        }
                        Text{

                            text: qsTr("未启用")
                            font.pointSize: 8;
                            font.bold: true
                            color: "white"
                            anchors{

                                bottom:parent.bottom

                            }

                        }
                        Image {
                            id: key_icon
//                            anchors.centerIn: parent
                            anchors{
//                                center: content_rec.Center

                                verticalCenter: content_rec.verticalCenter
                                right: content_rec.left
                                rightMargin: 150

                            }
                            source: "images/wvga/system/key.png"
                        }
                        Image {
                            id: wifi_signal
//                            anchors.centerIn: parent
                            anchors{
//                                horizontalCenter:content_rec
//                                center: content_rec.Center
                                  verticalCenter: content_rec.verticalCenter
//                                topMargin: 2
                                right: content_rec.left
                                rightMargin: 100

                            }
                            source: "images/wvga/system/wifi-signal.png"
                        }
                        Rectangle{
                            id:content_rec
                            width: 105
                            height: 31
                            color: "transparent"
                            anchors{
                                right: parent.right
                                rightMargin: 5
                            }

                            Image {
                                id: connect
                                anchors.fill: parent
                                source: "images/wvga/system/connect.png"
                            }
                            Text{

                                text: qsTr("连接")
                                font.pointSize: 12;
//                                font.bold: true
                                color: "white"
                                anchors{

                                    centerIn:parent
                                }

                            }
//                            MouseArea{
//                                anchors.fill: parent;
//                                onClicked: {
//                                    content_rec.opacity = 0.5

//                                }
//                                onExited:{
//                                   content_rec.opacity = 1.0
//                                }
//                                onPressed: {

//                                  content_rec.opacity = 0.5
//                                }
//                            }

                        }

                    }
                }
            }
        }
        Rectangle{
            id:navigationbar
            width: 122;
            height: 419;
            anchors{
                top: parent.top
                left: parent.left
                leftMargin: 20
            }
            Image{
                anchors.fill: parent
                source: "images/wvga/system/navigation.png"
            }
            color:"transparent"
            Column{
                id:coloumn;
                Rectangle{
                    id:time_rec
                    width: 122;
                    height: 64;
                    color:"transparent"
                    Image{
                        id: time_icon_bg
//                        anchors.fill: parent
                        source: 'images/wvga/system/button-bg.png'
                    }
                    Image{

                        id: time_icon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter : parent.horizontalCenter
                        source: 'images/wvga/system/time1.png'
                    }
                    Text{
                        id:cake
                        text: qsTr("时间设置")
                        font.pointSize: 6;
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: time_icon.bottom

                        }


                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            time_icon.source = 'images/wvga/system/time1.png'
                            ethernet_icon.source = "images/wvga/system/ethernet.png"
                            wifi_icon.source = 'images/wvga/system/wifi.png'
                            time_icon_bg.source= 'images/wvga/system/button-bg.png'
                            ethernet_icon_bg.source=''
                            wifi_icon_bg.source=''
                            console.log("基本信息")
                            view.currentIndex = 0
                        }
                    }
                }
                Rectangle{
                    width: 122;
                    height: 64;
                    color:"transparent"
                    Image{
                        id: ethernet_icon_bg
//                        anchors.fill: parent
                        source: ''
                    }
                    Image{
                        id: ethernet_icon
                        anchors.horizontalCenter : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: 'images/wvga/system/ethernet.png'
                    }
                    Text{
                        id:ethernet
                        text: qsTr("以太网设置")
                        font.pointSize: 6;
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: ethernet_icon.bottom

                        }

                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            time_icon.source = 'images/wvga/system/time.png'
                            ethernet_icon.source = "images/wvga/system/ethernet1.png"
                            wifi_icon.source = 'images/wvga/system/wifi.png'
                            time_icon_bg.source= ''
                            ethernet_icon_bg.source='images/wvga/system/button-bg.png'
                            wifi_icon_bg.source=''
                            console.log("net setting")
                            view.currentIndex = 1
                        }
                    }
                }
                Rectangle{
                    width: 122;
                    height: 64;
                    color:"transparent"
                    Image{
                        id: wifi_icon_bg
//                        anchors.fill: parent
                        source: ''
                    }
                    Image{
                        id: wifi_icon
                        anchors.horizontalCenter : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: 'images/wvga/system/wifi.png'
                    }
                    Text{
                        text: qsTr("WiFi设置")
                        font.pointSize: 6;
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: wifi_icon.bottom
                        }

                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            time_icon.source = 'images/wvga/system/time.png'
                            ethernet_icon.source = "images/wvga/system/ethernet.png"
                            wifi_icon.source = 'images/wvga/system/wifi1.png'
                            time_icon_bg.source= ''
                            ethernet_icon_bg.source=''
                            wifi_icon_bg.source='images/wvga/system/button-bg.png'
                            console.log("wifi setting")
                            view.currentIndex = 2;
                        }
                    }
                }
            }
        }
    }
}
