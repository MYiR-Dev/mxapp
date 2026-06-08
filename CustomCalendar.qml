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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: control
    color: "transparent"

    property alias font: monthGrid.font
    property alias year: monthGrid.year
    property alias month: monthGrid.month
    property date selectedDate: new Date()

    // 从全局 translator 读取当前语言，决定日历 locale
    // 首次创建时求值，运行时通过 onLanguageChanged 信号驱动刷新
    property var calendarLocale: {
        var loc = Qt.locale("zh_CN")
        try {
            if (typeof translator !== "undefined") {
                loc = (translator.get_current_language() === "English")
                    ? Qt.locale("en_US") : Qt.locale("zh_CN")
            }
        } catch(e) {}
        return loc
    }

    // 监听语言切换：仅在实际切换时局部刷新日历组件，不做全量销毁重建
    Connections {
        target: typeof translator !== "undefined" ? translator : null
        function onLanguageChanged() {
            // 1. 更新 locale
            control.calendarLocale = (translator.get_current_language() === "English")
                ? Qt.locale("en_US") : Qt.locale("zh_CN")
            // 2. 强制 MonthGrid 重建内部模型
            monthGrid.locale = control.calendarLocale
            var savedMonth = monthGrid.month
            monthGrid.month = (savedMonth + 1) % 12
            monthGrid.month = savedMonth
            // 3. 通过 Loader 重建 DayOfWeekRow（Qt6 bug QTBUG-129727 规避）
            weekRowLoader.shouldBeActive = false
            weekRowReloadTimer.start()
        }
    }

    Timer {
        id: weekRowReloadTimer
        interval: 0
        repeat: false
        onTriggered: { weekRowLoader.shouldBeActive = true }
    }

    // 自定义翻页按钮
    component CalendarButton : AbstractButton {
        implicitWidth: 28
        implicitHeight: 28
        contentItem: Text {
            font: control.font
            text: parent.text
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.down ? "#059EC9" : "transparent"
            radius: 4
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 2

        // 标题行：年月导航
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 36
            color: "transparent"
            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                CalendarButton {
                    text: "<"
                    onClicked: {
                        if (monthGrid.month === 0) {
                            monthGrid.year -= 1
                            monthGrid.month = 11
                        } else {
                            monthGrid.month -= 1
                        }
                    }
                }
                Text {
                    text: monthGrid.title
                    font: control.font
                    color: "white"
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                }
                CalendarButton {
                    text: ">"
                    onClicked: {
                        if (monthGrid.month === 11) {
                            monthGrid.year += 1
                            monthGrid.month = 0
                        } else {
                            monthGrid.month += 1
                        }
                    }
                }
                // 回今天按钮
                CalendarButton {
                    text: qsTr("今天")
                    implicitWidth: 40
                    onClicked: {
                        var now = new Date()
                        monthGrid.year = now.getFullYear()
                        monthGrid.month = now.getMonth()
                    }
                }
            }
        }

        // 星期头 — Loader 包裹，语言切换时销毁重建规避 QTBUG-129727
        Loader {
            id: weekRowLoader
            Layout.fillWidth: true

            property bool shouldBeActive: true
            active: shouldBeActive
            sourceComponent: weekRowComponent
        }

        // 日期网格
        MonthGrid {
            id: monthGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1
            font {
                family: "Microsoft YaHei"
                pixelSize: 13
            }
            locale: control.calendarLocale
            delegate: Rectangle {
                color: model.today ? "#059EC9"
                     : control.selectedDate.valueOf() === model.date.valueOf() ? "#0078D7"
                     : "transparent"
                border.color: "transparent"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: model.day
                    color: model.month === monthGrid.month ? "white" : "#555555"
                    font: monthGrid.font
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control.selectedDate = model.date
                        monthGrid.clicked(model.date)
                    }
                }
                required property var model
            }
        }
    }

    Component {
        id: weekRowComponent
        DayOfWeekRow {
            implicitHeight: 28
            spacing: 1
            topPadding: 0
            bottomPadding: 0
            font: control.font
            locale: control.calendarLocale
            delegate: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: shortName
                font: control.font
                color: "#A9A9A9"
                required property string shortName
            }
        }
    }
}
