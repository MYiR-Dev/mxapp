import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Window 2.2
import GetSystemInfoAPI 1.0

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
    Rectangle{
        anchors{
            top: parent.top
            topMargin: 50
        }
        color:"transparent"
        width:750
        height:430
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
                    height:419
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
                            topMargin: 20
                            left:    parent.left
                            leftMargin: 30

                        }
                        Rectangle{
                            width:47
                            height:28
                            color:"transparent"
                            Image {

                                source: "images/wvga/system/day-rec.png"
                            }
                            Image {
                                id:hour_dw
                                source: "images/wvga/system/drop-down.png"
                                anchors{
                                    right:    parent.right
                                    verticalCenter:parent.verticalCenter
                                    rightMargin: 5

                                }
                            }
                            Text{

                                text: "18"
                                font.pointSize: 15;
                                font.bold: true
                                color: "white"
                                anchors{
                                    verticalCenter:parent.verticalCenter
                                    right:hour_dw.left
                                    rightMargin: 5


                                }
                            }

                        }
                        Text{

                            text: ":"
                            font.pointSize: 15;
                            font.bold: true
                            color: "white"
                        }
                        Rectangle{
                            width:47
                            height:28
                            color:"transparent"
                            Image {
                                anchors.fill: parent
                                source: "images/wvga/system/day-rec.png"
                            }
                            Image {
                                id:min_dw
                                source: "images/wvga/system/drop-down.png"
                                anchors{
                                    right:    parent.right
                                    verticalCenter:parent.verticalCenter
                                    rightMargin: 5

                                }
                            }
                            Text{

                                text: "18"
                                font.pointSize: 15;
                                font.bold: true
                                color: "white"
                                anchors{
                                    verticalCenter:parent.verticalCenter
                                    right:min_dw.left
                                    rightMargin: 5


                                }
                            }

                        }
                        Text{

                            text: ":"
                            font.pointSize: 15;
                            font.bold: true
                            color: "white"
                        }
                        Rectangle{
                            width:47
                            height:28
                            color:"transparent"
                            Image {
                                anchors.fill: parent
                                source: "images/wvga/system/day-rec.png"
                            }
                            Image {
                                id:sec_dw
                                source: "images/wvga/system/drop-down.png"
                                anchors{
                                    right:    parent.right
                                    verticalCenter:parent.verticalCenter
                                    rightMargin: 5
                                }
                            }
                            Text{

                                text: "18"
                                font.pointSize: 15;
                                font.bold: true
                                color: "white"
                                anchors{
                                    verticalCenter:parent.verticalCenter
                                    right:sec_dw.left
                                    rightMargin: 5
                                }
                            }

                        }

                    }
                    Text{
                        id:time_value
                        text: qsTr("2020年2月2日，星期日")
                        font.pointSize: 16;
                        font.bold: true
                        color: "blue"
                        anchors{
                            top:    row_layout.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

                        }
                       function get_time(){

                       }

                    }
                    CustomCalendar{
                        width:350
                        height: 250
                        color: "transparent"
                        anchors{
                            top:    time_value.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

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
                        Text{

                            text: "xx"
                            font.pointSize: 10;

                            color: "white"

                            Layout.row: 1
                            Layout.column: 1
                        }
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
                        Text{

                            text: "192.168.30.188"
                            font.pointSize: 10;

                            color: "white"

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
                        id:wifi
                        text: "WIFI设置"
                        font.pointSize: 15;
                        font.bold: true
                        color: "white"
                        anchors{

                            left: parent.left
                            leftMargin: 30


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
