import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.0
import GetSystemInfoAPI 1.0
SystemWindow {
    id: infoWindow
    title: "info"
    focus: true
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("系统信息")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            infoWindow.close()
            info_timer.stop()
        }

    }
    GetSystemInfo{
        id:getSyetemInfo
//        Component.onCompleted:get_cpu_info()
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
        width:adaptive_width/1.06
        height:adaptive_height*2
        SwipeView {
            id: view
            orientation:Qt.Vertical
            anchors.fill: parent
            interactive: false
            anchors{
                top: parent.top
                left: navigationbar.left
                leftMargin: adaptive_width/5.3
            }
            Item {
                id: firstPage

                Rectangle{
                    width:adaptive_width/1.26
                    height:adaptive_height*2
                    color:"transparent"


                    Text{
                        text: qsTr("基本信息")
                        font.pixelSize: 15;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            left: parent.left
                            leftMargin: 30
                        }
                    }

                    Text{
                        id:memory
                        text: qsTr("可用内存")
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 10;
                        color: "white"
                        anchors{
                            top: parent.top
                            topMargin: 30
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:memory_value
                        text: mem_free+"MB"
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"

                        anchors{
                            top: parent.top
                            topMargin: 30
                            left: memory.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:ip
                        text: qsTr("IP 地址")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: memory.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:ip_value
                        text: net_ip
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        Layout.row:2
                        Layout.column:1
                        anchors{
                            top: memory.top
                            topMargin: 20
                            left: ip.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:resolution
                        text: qsTr("屏幕分辨率")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: ip_value.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:resolution_value
                        text: Screen.desktopAvailableWidth+"*"+Screen.desktopAvailableHeight
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"

                        anchors{
                            top: ip_value.top
                            topMargin: 20
                            left: resolution.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:op
                        text: qsTr("操作系统")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: resolution.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:op_value
                        text:getSyetemInfo.read_system_version()
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"

                        anchors{
                            top: resolution.top
                            topMargin: 20
                            left: op.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:run_time
                        text: qsTr("系统运行时间")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: op.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }


                    Text{
                        id:run_time_value
                        text:day+qsTr("天")+hour+qsTr("时")+min+qsTr("分")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: op.top
                            topMargin: 20
                            left: run_time.left
                            leftMargin: 120
                        }

                    }
                    Text{
                        id:total_run_time
                        text: qsTr("总运行时间")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: run_time.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:total_run_time_value
                        text: day+qsTr("天")+hour+qsTr("时")+min+qsTr("分")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"

                        anchors{
                            top: run_time.top
                            topMargin: 20
                            left: total_run_time.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:battery_power
                        text: qsTr("电池电量")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: total_run_time.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:battery_power_value
                        text: "null"
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: total_run_time.top
                            topMargin: 20
                            left: battery_power.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:create
                        text: qsTr("创建")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: battery_power.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    Text{
                        id:create_value
                        text: qsTr("Yocto")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: battery_power.top
                            topMargin: 20
                            left: create.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:compile_time
                        text: qsTr("编译")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: create.top
                            topMargin: 20
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:compile_time_value
                        text: "2020-05-15 "
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: create.top
                            topMargin: 20
                            left: compile_time.left
                            leftMargin: 120
                        }
                    }
                    Image{
                        id:cpu_icon
                        width: adaptive_width/33.3
                        height: adaptive_height/19.2
                        source: "images/wvga/system/cpu.png"

                        anchors{

                            top: compile_time.bottom
                            topMargin: 40
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Rectangle{
                        id:cpu_processbar_ectangle
                        width: adaptive_width/1.8
                        height: adaptive_height/19.2
                        color: "transparent"
                        anchors{
                            top: compile_time_value.bottom
                            topMargin: 40

                            left: cpu_icon.right
                            leftMargin: 20

                        }
                        Text{
                            id:cpu_value
                            text:qsTr("系统CPU使用率: ")+cpu_percent+"%"
                            font.pixelSize: 10;
                            font.family: "Microsoft YaHei"
                            color: "white"

                            anchors{
                                top: parent.top
                                left:parent.top
                            }
                        }
                        Rectangle {
                            id:cpu_processbar
                            width: 402
                            height: 8
                            radius:10           //圆角角度
                            color: "transparent"
                            border.color: "transparent"
                            property int value: 80

                            Image {
                                id: processbar
                                source: "images/wvga/system/processbar.png"
                            }
                            Rectangle {
                              width: parent.width * cpu_percent / 100
                              height:parent.height // percentage
                              color: "#0CAA00"
                              radius:10
//                              anchors.bottom: parent.bottom
                            }
                            anchors{
                                bottom: parent.bottom

                            }

                        }

                    }


                    Image{
                        id:disk_icon
                        source: "images/wvga/system/disk.png"
                        width: adaptive_width/33.3
                        height: adaptive_height/19.2
                        anchors{
                            left: parent.left
                            leftMargin: 30
                            top: cpu_icon.bottom
                            topMargin: 30
                        }
                    }
                    Rectangle{
                        width: adaptive_width/1.8
                        height: adaptive_height/19.2
                        color: "transparent"
                        anchors{
                            top: cpu_icon.bottom
                            topMargin: 30

                            left: disk_icon.right
                            leftMargin: 20

                        }
                        Text{
                            id:disk_value
                            text:qsTr("系统内存使用率: ")+mem_usage+"-"+mem_percent+"%"
                            font.pixelSize: 10;
                            font.family: "Microsoft YaHei"
                            color: "white"
                            anchors{
                                top: parent.top
                                left:parent.top
                            }
                        }
                        Rectangle {
                            id:disk_processbar
                            width: 402
                            height: 8
                            radius:10           //圆角角度
                            color: "transparent"
                            border.color: "transparent"
                            property int value: 40
                            Image {
                                id: processbar_bg
                                source: "images/wvga/system/processbar.png"
                            }
                            Rectangle {
                              width: parent.width * mem_percent / 100
                              height:parent.height // percentage
                              color: "#0CAA00"
                              radius:10
//                              anchors.bottom: parent.bottom
                            }
                            anchors{
                                bottom: parent.bottom

                            }

                        }

                    }


                }

            }
            Item {
                id: secondPage
                Rectangle{
                    width:adaptive_width/1.26
                    height:adaptive_height*2
                    color:"transparent"

                    Text{
                        text: qsTr("网络信息")
                        font.pixelSize: 15;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            left: parent.left
                            leftMargin: 30
                        }

                    }

                    Text{
                        id:mac
                        text: qsTr("网卡MAC地址")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            topMargin: 40
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:mac_value
                        text: net_mac
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            topMargin: 40
                            left: mac.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:ip_text
                        text: qsTr("IP地址")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: mac.top
                            topMargin: 25
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:ip_text_value
                        text: net_ip
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: mac.top
                            topMargin: 25
                            left: ip_text.left
                            leftMargin: 120
                        }
                    }

                    Text{
                        id:speed
                        text: qsTr("速率 ")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: ip_text.top
                            topMargin: 25
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:speed_value
                        text: qsTr("1000")+"MB/s"
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: ip_text.top
                            topMargin: 25
                            left: speed.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:net_connect
                        text: qsTr("是否联网")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: speed.top
                            topMargin: 25
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:net_connect_value

                        text:{
                            if(getSyetemInfo.get_net_status())
                                qsTr("已联网")
                            else
                                qsTr("未联网")
                        }
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "green"
                        anchors{
                            top: speed.top
                            topMargin: 25
                            left: net_connect.left
                            leftMargin: 120
                        }
                    }

                }
            }
            Item {
                id: thirdPage
                Rectangle{
                    width:adaptive_width/1.26
                    height:adaptive_height*2
                    color:"transparent"


                    Text{
                        text: qsTr("版权信息")
                        font.pixelSize: 15;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            left: parent.left
                            leftMargin: 30
                        }
                    }

                    Text{
                        id:copyright
                        text: qsTr("版权声明")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            topMargin: 40
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:copyright_value
                        text: qsTr("Copyright © 2020 MYIR Electronics Limited. All rights reserved.")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: parent.top
                            topMargin: 40
                            left: copyright.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:qt_version
                        text: qsTr("QT版本")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: copyright.top
                            topMargin: 25
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:qt_version_value
                        text: qsTr("5.12")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: copyright.top
                            topMargin: 25
                            left: qt_version.left
                            leftMargin: 120
                        }
                    }
                    Text{
                        id:thirdpart_copyright
                        text: qsTr("MEasy HMI版本")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: qt_version.top
                            topMargin: 25
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{
                        id:thirdpart_copyright_value
                        text: qsTr("MEasy HMI v2.0 ")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: qt_version.top
                            topMargin: 25
                            left: thirdpart_copyright.left
                            leftMargin: 120
                        }
                    }


                }
            }
        }
        Rectangle{
            id:navigationbar
            width:adaptive_width/6.55
            height:adaptive_height/1.14
            anchors{
                top: parent.top
                left: parent.left
                leftMargin: 20
            }
            Image{
//                anchors.fill: parent
                width:adaptive_width/7.00
                height:adaptive_height/1.2
                source: "images/wvga/system/navigation.png"
            }
            color:"transparent"
            Column{
                id:coloumn;
                Rectangle{
                    id:basicinfo
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5

                    color:"transparent"
                    Image{
                        id: basicinfo_icon_bg
//                        anchors.fill: parent
                        width:adaptive_width/6.7
                        height:adaptive_height/7.5
                        source: 'images/wvga/system/button-bg.png'
                    }
                    Image{

                        id: basicinfo_icon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter : parent.horizontalCenter
                        source: 'images/wvga/system/basic1.png'
                    }
                    Text{
                        id:cake
                        text: qsTr("基本信息")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: basicinfo_icon.bottom

                        }


                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            copyright_icon.source = 'images/wvga/system/copyright.png'
                            netinfo_icon.source = "images/wvga/system/net.png"
                            basicinfo_icon.source = 'images/wvga/system/basic1.png'
                            netinfo_icon_bg.source= ''
                            basicinfo_icon_bg.source='images/wvga/system/button-bg.png'
                            copyright_icon_bg.source=''
                            console.log("基本信息")
                            view.currentIndex = 0
                        }
                    }
                }
                Rectangle{
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5
                    color:"transparent"
                    Image{
                        id: netinfo_icon_bg
                        width:adaptive_width/6.7
                        height:adaptive_height/7.5
//                        anchors.fill: parent
                        source: ''
                    }
                    Image{
                        id: netinfo_icon
                        anchors.horizontalCenter : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: 'images/wvga/system/net.png'
                    }
                    Text{
                        id:netinfo
                        text: qsTr("网络信息")
                        font.pixelSize:10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: netinfo_icon.bottom

                        }

                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {
                            copyright_icon.source = 'images/wvga/system/copyright.png'
                            netinfo_icon.source = 'images/wvga/system/net1.png'
                            basicinfo_icon.source = 'images/wvga/system/basic.png'
                            netinfo_icon_bg.source= 'images/wvga/system/button-bg.png'
                            basicinfo_icon_bg.source=''
                            copyright_icon_bg.source=''
                            console.log("网络信息")
                            view.currentIndex = 1
                        }
                    }
                }
                Rectangle{
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5
                    color:"transparent"
                    Image{
                        id: copyright_icon_bg
                        width:adaptive_width/6.7
                        height:adaptive_height/7.5
//                        anchors.fill: parent
                        source: ''
                    }
                    Image{
                        id: copyright_icon
                        anchors.horizontalCenter : parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: 'images/wvga/system/copyright.png'
                    }
                    Text{
                        id:copyright_button
                        text: qsTr("版权信息")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            horizontalCenter:    parent.horizontalCenter
                            top: copyright_icon.bottom
                        }

                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: {


                            copyright_icon.source = 'images/wvga/system/copyright1.png'
                            netinfo_icon.source = "images/wvga/system/net.png"
                            basicinfo_icon.source = 'images/wvga/system/basic.png'
                            netinfo_icon_bg.source= ''
                            basicinfo_icon_bg.source=''
                            copyright_icon_bg.source='images/wvga/system/button-bg.png'
                            console.log("版权信息")
                            view.currentIndex = 2;
                        }
                    }
                }
            }
        }
    }
    property int cpu_percent:50
    property int mem_percent:50
    property int mem_free:50
    property string mem_usage:""
    property int system_run_time : getSyetemInfo.read_system_runtime()

    property int day: system_run_time/86400
    property int hour:system_run_time/3600 % 24
    property int min:system_run_time%3600/60
    property int timer_count:0
    property string net_ip:getSyetemInfo.read_net_ip()
    property string net_mac:getSyetemInfo.read_net_mac()
    Timer{
        id:info_timer
        interval:1000;running:true;repeat: true

        onTriggered: {
            timer_count++
            if((timer_count%60) == 0 )
            {
                system_run_time = getSyetemInfo.read_system_runtime()
                day = system_run_time/86400
                hour = system_run_time/3600 % 24
                min = system_run_time%3600/60
            }
            cpu_percent = getSyetemInfo.read_cpu_percent()
            mem_percent = getSyetemInfo.read_memory_percent()
            mem_usage = getSyetemInfo.read_memory_usage()
            mem_free = getSyetemInfo.read_memory_free()

        }
//      Component.onCompleted:info_timer.start()
    }

}

