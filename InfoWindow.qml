import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.0
SystemWindow {
    id: infoWindow
    title: "info"

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: "系统信息"
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            infoWindow.close()
        }

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

                    GridLayout {
                        width:630
                        height:300
                        columns:5
                        rows:18
                        anchors{
                            top: parent.top
                            left: parent.left
                            leftMargin: 30
                        }
                        Text{
                            text: "基本信息"
                            font.pointSize: 15;
                            color: "white"
                            Layout.row:0
                            Layout.column:0
                        }

                        Text{
                            text: "可用内存"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:1
                            Layout.column:0
                        }
                        Text{
                            id:memory
                            text: "200MB"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:1
                            Layout.column:1
                        }
                        Text{
                            text: "IP 地址"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:2
                            Layout.column:0
                        }
                        Text{
                            id:ip
                            text: "192.168.30.1"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:2
                            Layout.column:1
                        }
                        Text{
                            text: "屏幕分辨率"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:3
                            Layout.column:0
                        }
                        Text{
                            id:resolution
                            text: "800*480"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:3
                            Layout.column:1
                        }
                        Text{
                            text: "操作系统"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:4
                            Layout.column:0
                        }
                        Text{
                            id:op
                            text: "Linux 4.1.18"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:4
                            Layout.column:1
                        }
                        Text{
                            text: "系统运行时间"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:5
                            Layout.column:0
                        }
                        Text{
                            id:run_time
                            text: "11分钟"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:5
                            Layout.column:1
                        }
                        Text{
                            text: "总运行时间"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:6
                            Layout.column:0
                        }
                        Text{
                            id:total_run_time
                            text: "2小时13分"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:6
                            Layout.column:1
                        }
                        Text{
                            text: "电池电量"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:7
                            Layout.column:0
                        }
                        Text{
                            id:battery_power
                            text: "86%"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:7
                            Layout.column:1
                        }
                        Text{
                            text: "创建"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:8
                            Layout.column:0
                        }
                        Text{
                            id:create
                            text: "Buildroot "
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:8
                            Layout.column:1
                        }
                        Text{
                            text: "编译"
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:9
                            Layout.column:0
                        }
                        Text{
                            id:compile
                            text: "2020-09-15 "
                            font.pointSize: 8;
                            color: "white"
                            Layout.row:9
                            Layout.column:1
                        }
                        Image{

                            source: "images/wvga/system/cpu.png"
                            Layout.row:11
                            Layout.rowSpan: 3
                            Layout.column:0
                        }
                        Image{

                            source: "images/wvga/system/disk.png"
                            Layout.row:14
                            Layout.rowSpan: 3
                            Layout.column:0
                        }

                    }
                }

            }
            Item {
                id: secondPage
                Rectangle{
                    width:630
                    height:419
                    color:"blue"
                }
            }
            Item {
                id: thirdPage
                Rectangle{
                    width:630
                    height:419
                   color:"transparent"
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
                    id:basicinfo
                    width: 122;
                    height: 64;
                    color:"transparent"
                    Image{

                        id: basicinfo_icon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter : parent.horizontalCenter
                        source: 'images/wvga/system/basic.png'
                    }
                    Text{
                        id:cake
                        text: "基本信息"
                        font.pointSize: 6;
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: basicinfo_icon.bottom

                        }


                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
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
                        id: netinfo_icon
                        anchors.horizontalCenter : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: 'images/wvga/system/net.png'
                    }
                    Text{
                        id:netinfo
                        text: "网络信息"
                        font.pointSize: 6;
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: netinfo_icon.bottom

                        }

                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            console.log("网络信息")
                            view.currentIndex = 1
                        }
                    }
                }
                Rectangle{
                    width: 122;
                    height: 64;
                    color:"transparent"
                    Image{
                        id: copyright_icon
                        anchors.horizontalCenter : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: 'images/wvga/system/copyright.png'
                    }
                    Text{
                        id:copyright
                        text: "版权信息"
                        font.pointSize: 6;
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: copyright_icon.bottom
                        }

                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            console.log("版权信息")
                            view.currentIndex = 2;
                        }
                    }
                }
            }
        }
    }


}

