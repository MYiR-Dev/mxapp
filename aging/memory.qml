/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024 XuMR <2801739946@qq.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
***********************************************************************/

import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.1

import GetSystemInfoAPI 1.0

Item {
    id: firstPage
    width:parent.width
    height:parent.height

    Settings{
        id:settings
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

    GetSystemInfo{
        id:getSyetemInfo
//        Component.onCompleted:get_cpu_info()
    }

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

    Rectangle{
        width:parent.width
        height:parent.height
        color:"black"


//        Text{
//            text: qsTr("基本信息")
//            font.pixelSize: 15;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: parent.top
//                left: parent.left
//                leftMargin: 30
//            }
//        }

        Text{
            id:memory
            text: qsTr("可用内存")
            font.family: "Microsoft YaHei"
            font.pixelSize: 10;
            color: "white"
            anchors{
                top: parent.top
                topMargin: 5
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
                topMargin: 5
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
                top: memory.bottom
                topMargin: 5
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
                top: memory.bottom
                topMargin: 5
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
                top: ip_value.bottom
                topMargin: 5
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
                top: ip_value.bottom
                topMargin: 5
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
                top: resolution.bottom
                topMargin: 2
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
                top: resolution.bottom
                topMargin: 2
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
                top: op.bottom
                topMargin: 2
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
                top: op.bottom
                topMargin: 2
                left: run_time.left
                leftMargin: 120
            }

        }
        Text{
            id:total_run_time
            text: qsTr("总开机/复位次数")
            font.pixelSize: 10;
            font.family: "Microsoft YaHei"
            color: "white"
            anchors{
                top: run_time.bottom
                topMargin: 2
                left: parent.left
                leftMargin: 30
            }
        }
        Text{
            id:total_run_time_value
            text: settings.value("hmiBootCount")//day+qsTr("天")+hour+qsTr("时")+min+qsTr("分")
            font.pixelSize: 10;
            font.family: "Microsoft YaHei"
            color: "white"

            anchors{
                top: run_time.bottom
                topMargin: 2
                left: total_run_time.left
                leftMargin: 120
            }
        }
//        Text{
//            id:battery_power
//            text: qsTr("电池电量")
//            font.pixelSize: 10;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: total_run_time.top
//                topMargin: 20
//                left: parent.left
//                leftMargin: 30
//            }
//        }
//        Text{
//            id:battery_power_value
//            text: "null"
//            font.pixelSize: 10;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: total_run_time.top
//                topMargin: 20
//                left: battery_power.left
//                leftMargin: 120
//            }
//        }
//        Text{
//            id:create
//            text: qsTr("创建")
//            font.pixelSize: 10;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: battery_power.top
//                topMargin: 20
//                left: parent.left
//                leftMargin: 30
//            }

//        }
//        Text{
//            id:create_value
//            text: qsTr("Yocto")
//            font.pixelSize: 10;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: battery_power.top
//                topMargin: 20
//                left: create.left
//                leftMargin: 120
//            }
//        }
//        Text{
//            id:compile_time
//            text: qsTr("编译")
//            font.pixelSize: 10;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: create.top
//                topMargin: 20
//                left: parent.left
//                leftMargin: 30
//            }
//        }
//        Text{
//            id:compile_time_value
//            text: "2020-05-15 "
//            font.pixelSize: 10;
//            font.family: "Microsoft YaHei"
//            color: "white"
//            anchors{
//                top: create.top
//                topMargin: 20
//                left: compile_time.left
//                leftMargin: 120
//            }
//        }
        Image{
            id:cpu_icon
            width: 24
            height: 24
            source: "../images/wvga/system/cpu.png"

            anchors{
                top: total_run_time.bottom
                topMargin: 2
                left: parent.left
                leftMargin: 30
            }
        }
        Rectangle{
            id:cpu_processbar_ectangle
            width: 100
            height: 20
            color: "transparent"
            anchors{
                top: total_run_time_value.bottom
                topMargin: 2

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
                width: 200
                height: 8
                radius:10           //圆角角度
                color: "transparent"
                border.color: "transparent"
                property int value: 80

//                Image {
//                    id: processbar
//                    source: "../images/wvga/system/processbar.png"
//                }
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
            source: "../images/wvga/system/disk.png"
            width: 24
            height: 24
            anchors{
                left: parent.left
                leftMargin: 30
                top: cpu_icon.bottom
                topMargin: 2
            }
        }
        Rectangle{
            width: parent.width
            height: 20
            color: "transparent"
            anchors{
                top: cpu_icon.bottom
                topMargin: 2

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
                width: parent.width
                height: 8
                radius:10           //圆角角度
                color: "transparent"
                border.color: "transparent"
                property int value: 40
//                Image {
//                    id: processbar_bg
//                    width: parent.width - 30
//                    source: "../images/wvga/system/processbar.png"
//                }
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
