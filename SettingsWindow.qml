import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import GetSystemInfoAPI 1.0
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


            }
            Item {
                id: secondPage
            }
            Item {
                id: thirdPage
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
