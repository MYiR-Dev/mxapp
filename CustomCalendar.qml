/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024

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

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Layouts 1.0

Rectangle {
    id:control
    border.color: "black"
    visible: false
    property alias font: month_grid.font
    property alias locale: month_grid.locale
    property date selectDate: new Date()
    //property alias calendar_control:m_calendar

    //自定义按钮样式
    component CalendarButton : AbstractButton {
        id: c_btn
        implicitWidth: 30
        implicitHeight: 30
        contentItem: Text {
            font: control.font
            text: c_btn.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Item{}
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 2
        columns: 2
        rows: 3
        columnSpacing: 1
        rowSpacing: 1

        Rectangle {
            implicitWidth: 30
            implicitHeight: 40
            color: "gray"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    //日期复位
                    let cur_date=new Date();
                    month_grid.year=cur_date.getUTCFullYear();
                    month_grid.month=cur_date.getUTCMonth();
                }
            }
        }

        Rectangle {
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            implicitHeight: 40
            color: "gray"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                CalendarButton {
                    text: "<"
                    onClicked: {
                        month_grid.year-=1;
                    }
                }
                Text {
                    font: control.font
                    color: "white"
                    text: month_grid.year
                }
                CalendarButton {
                    text: ">"
                    onClicked: {
                        month_grid.year+=1;
                    }
                }
                Item {
                    implicitWidth: 20
                }
                CalendarButton {
                    text: "<"
                    onClicked: {
                        if(month_grid.month===0){
                            month_grid.year-=1;
                            month_grid.month=11;
                        }else{
                            month_grid.month-=1;
                        }
                    }
                }
                Text {
                    font: control.font
                    color: "white"
                    text: month_grid.month+1
                }
                CalendarButton {
                    text: ">"
                    onClicked: {
                        if(month_grid.month===11){
                            month_grid.year+=1;
                            month_grid.month=0;
                        }else{
                            month_grid.month+=1;
                        }
                    }
                }
            }
        }

        Rectangle {
            implicitWidth: 30
            implicitHeight: 40
            color: "gray"
        }

        //星期1-7
        DayOfWeekRow {
            id: week_row
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            implicitHeight: 40
            spacing: 1
            topPadding: 0
            bottomPadding: 0
            font: control.font
            //locale设置会影响显示星期数中英文
            locale: control.locale
            delegate: Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: shortName
                font: week_row.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                required property string shortName
            }
            contentItem: Rectangle {
                color: "gray"
                border.color: "black"
                RowLayout {
                    anchors.fill: parent
                    spacing: week_row.spacing
                    Repeater {
                        model: week_row.source
                        delegate: week_row.delegate
                    }
                }
            }
        }

        //左侧周数
        WeekNumberColumn {
            id: week_col
            Layout.row: 2
            Layout.fillHeight: true
            implicitWidth: 30
            spacing: 1
            leftPadding: 0
            rightPadding: 0
            font: control.font
            month: month_grid.month
            year: month_grid.year
            locale: control.locale
            delegate: Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: weekNumber
                font: week_col.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                required property int weekNumber
            }
            contentItem: Rectangle {
                color: "gray"
                border.color: "black"
                ColumnLayout {
                    anchors.fill: parent
                    spacing: week_col.spacing
                    Repeater {
                        model: week_col.source
                        delegate: week_col.delegate
                    }
                }
            }
        }

        //日期单元格
        MonthGrid {
            id: month_grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            //month: Calendar.December
            //year: 2022
            locale: Qt.locale("zh_CN")
            spacing: 1
            font{
                family: "SimHei"
                pixelSize: 14
            }
            delegate: Rectangle {
                color: model.today
                       ?"orange"
                       :control.selectDate.valueOf()===model.date.valueOf()
                         ?"darkCyan"
                         :"gray"
                border.color: "black"
                border.width: 1
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    color: "transparent"
                    border.color: "white"
                    visible: item_mouse.containsMouse
                }
                Text {
                    anchors.centerIn: parent
                    text: model.day
                    color: model.month===month_grid.month?"white":"black"
                }
                MouseArea {
                    id: item_mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
            onClicked: (date)=> {
                           control.selectDate=date;
                           console.log('click',month_grid.title,month_grid.year,month_grid.month,"--",
                                       date.getUTCFullYear(),date.getUTCMonth(),date.getUTCDate(),date.getUTCDay())
                       }
        }
    }
    // Calendar{
    //     id: m_calendar
    //     //anchors.centerIn: parent
    //     frameVisible: false
    //     navigationBarVisible: false
    //     weekNumbersVisible: false
    //     minimumDate: new Date(2015, 0, 1);
    //     maximumDate: new Date(2025, 0, 1);

    //     anchors{
    //         fill: parent
    //     }
    //     onClicked:
    //     {
    //         //m_calendar.visible = false;
    //     }

    //     style: CalendarStyle {
    //         gridVisible: false

    //         background: Image {//日历背景
    //             id: bg
    //             anchors.fill: parent
    //         }

    //         dayOfWeekDelegate://周的显示
    //                           Rectangle{
    //             id: rec1
    //             color: "transparent"
    //             height: 20

    //             Text {
    //                 id: weekTxt
    //                 font.pixelSize: 15
    //                 text:Qt.locale().dayName(styleData.dayOfWeek, control.dayOfWeekFormat)//转换为自己想要的周的内容的表达
    //                 anchors.centerIn: rec1
    //                 color: styleData.selected?"green":"gray"
    //                 font.family: "Microsoft YaHei"
    //             }
    //         }

    //         navigationBar:Rectangle {//导航控制栏，控制日期上下选择等
    //             color: "transparent"
    //             height: 40
    //         }

    //         dayDelegate:Rectangle{//显示日期
    //             color: "transparent"
    //             Image
    //             {
    //                 id: day_bg
    //                 height: 28
    //                 width: 28
    //                 anchors.centerIn: parent
    //                 //                                        anchors.centerIn: parent
    //                 source: styleData.selected ? "images/wvga/system/current-dat-bg.png" : ""
    //             }

    //             Label {
    //                 id: m_label
    //                 text: styleData.date.getDate()
    //                 font.pixelSize: 15
    //                 font.family: "Microsoft YaHei"
    //                 anchors.centerIn: parent
    //                 color: styleData.selected ? "yellow" :  (styleData.visibleMonth && styleData.valid ? "lightblue" : "grey");
    //             }
    //         }
    //     }
    // }
}
