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
import QtQuick.Dialogs
import QtQuick.Controls
import GetSystemInfoAPI 1.0
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import QtQuick.VirtualKeyboard.Styles
import QtQuick.Layouts
import QtQuick.Window
SystemWindow {
    id: settingsWindow
    title: "settings"

    property int adaptive_width: parent.width
    property int adaptive_height: parent.height
    property var netports: []
    property var selectedWifi: null
    property bool wifistatus: false
    width: adaptive_width
    height: adaptive_height
    signal message(string msg)
    signal wifiPoweredOff()  // 显式信号：WiFi 关闭时触发，供 Loader 内部清除列表
    property bool wifi_avail: false
    property string selectedEthPort: ""
    // 渐进式加载标记：所有页面首访后保持常驻
    // 日历语言刷新由 CustomCalendar 内部监听 translator.languageChanged 信号驱动
    property bool page1Loaded: true
    property bool page2Loaded: false
    property bool page3Loaded: false

    // 延迟初始化：先渲染 UI，再执行 I/O 检查，避免窗口打开时阻塞
    Timer {
        id: initTimer
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            wifi_avail = getSyetemInfo.isWifi_avail()
            console.log("wifi avail " + wifi_avail)
            getSyetemInfo.get_net_status()
            netports = getSyetemInfo.get_net_ports()
            if (netports.length > 0) selectedEthPort = netports[0]
        }
    }
    onVisibleChanged: {
        if(visible === true){
            // P4: setting_timer 仅在以太网页面可见时运行
            if (view.currentIndex === 1) setting_timer.start()
        } else {
            setting_timer.stop()
            if (connectDialog.opened) connectDialog.close()
        }
    }
    property string net_ip:getSyetemInfo.read_net_ip(selectedEthPort)
    property int connect_net:getSyetemInfo.get_net_status(selectedEthPort)
    Timer{
        id:setting_timer
        interval:1000;running:false;repeat: true

        onTriggered: {
            net_ip = getSyetemInfo.read_net_ip(selectedEthPort)
            connect_net = getSyetemInfo.get_net_status(selectedEthPort)
        }
    }
    // wifi连接超时时钟
    Timer{
        id:outtime_timer
        interval:12000;running:false;repeat: false  // 兜底: wpa 连不上时 C++ 不会启动 DHCP，由 QML 超时

        onTriggered: {
            if(!wifistatus){
                failText.visible = true
                connectbtn.enabled = true
                passwordField.text = ""
                passwordField.readOnly = false
                connectingSpinner.running = false
            }
        }
    }

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("系统设置")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {

            settingsWindow.close()
            setting_timer.stop()
//
//            settingsWindow.message("settingsWindow close!")
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
    property bool wifi_statu: false
    function openwifi(checked) {

        if(checked)
        {
            getSyetemInfo.wifi_open()
            getSyetemInfo.startwifitimer()
            wifi_statu = true
        }
        else
        {
            getSyetemInfo.disconnect_wifi()   // 异步: wpa_cli disconnect + ip addr flush
            getSyetemInfo.stopwifitimer()
            wifi_statu = false
            wifiPoweredOff()  // 显式信号通知 Loader 内部清除列表
        }
    }

    InputPanel {
        id: inputPanel_passwd
        anchors.fill: parent
        y: Qt.inputMethod.visible ? parent.height - height : parent.height
        visible: Qt.inputMethod.visible
        z:99
        anchors.left: parent.left
        anchors.right: parent.right
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        AutoScroller {}
    }

    // 非模态 Dialog 的点击遮罩 — z=98 在 InputPanel(z=99) 之下，SwipeView 之上
    MouseArea {
        anchors.fill: parent
        visible: connectDialog.opened
        z: 98
        onClicked: {}  // 消耗所有点击，阻止穿透到 SwipeView 和导航栏
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
            // P4: 页面切换时管理以太网轮询
            onCurrentIndexChanged: {
                if (settingsWindow.visible) {
                    if (currentIndex === 1)
                        setting_timer.start()
                    else
                        setting_timer.stop()
                }
            }
            Item {
                // 时间设置页面 — Loader 懒加载，仅当前页创建内容
                Loader {
                    anchors.fill: parent
                    active: page1Loaded
                    sourceComponent: Component {
                Rectangle{
                    width:adaptive_width/1.26
                    height:adaptive_height*2
                    color:"transparent"

                    Text{
                        id:title
                        text: qsTr("时间")
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 16;
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
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 15;
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
                                        "51", "52", "53","54", "55", "56","57", "58", "59"]

                            Component.onCompleted: {

                                combox_min.combox_control.currentIndex =Number(Qt.formatTime(currentTime,"mm"))

                            }
                        }
                        Text{

                            text: ":"
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 15;
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
                                        "51", "52", "53","54", "55", "56","57", "58", "59"]

                            Component.onCompleted: {

                                combox_sec.combox_control.currentIndex =Number(Qt.formatTime(currentTime,"ss"))
                            }
                        }
                    }
                    property var date
                    Text{
                        id:time_value
                        text: get_time()
                        font.pixelSize: 12;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        color: "#059EC9"
                        anchors{
                            top:    row_layout.bottom
                            topMargin: 10
                            left:    parent.left
                            leftMargin: 30

                        }

                        function get_time(){
                            return Qt.formatDateTime(new Date(), qsTr("yyyy年MM月dd日,ddd"));

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
                            delegate_width:85
                            property date currentTime: new Date()
                            function getYearModel() {
                                var years = [];
                                var currentYear = new Date().getFullYear();
                                for (var y = 2015; y <= currentYear; y++) {
                                    years.push(y + qsTr("年"));
                                }
                                return years;
                            }
                            modeldata: getYearModel()
                            Component.onCompleted: {
                                var idx = currentTime.getFullYear() - 2015;
                                combox_year.combox_control.currentIndex = (idx >= 0 && idx < modeldata.length) ? idx : 0;
                            }

                        }
                        CustomCombox{
                            id:combox_mon
                            delegate_width:65
                            property date currentTime: new Date()

                            modeldata: ["1"+qsTr("月"), "2"+qsTr("月"), "3"+qsTr("月"),"4"+qsTr("月"), "5"+qsTr("月"), "6"+qsTr("月"),
                                        "7"+qsTr("月"), "8"+qsTr("月"), "9"+qsTr("月"),"10"+qsTr("月"),"11"+qsTr("月"), "12"+qsTr("月")]
                            Component.onCompleted: {

                                combox_mon.combox_control.currentIndex = currentTime.getMonth()

                            }

                        }
                        CustomCombox{
                            id:combox_day
                            delegate_width:65
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
                        // color: "transparent"

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
                            font.pixelSize: 10;
                            font.family: "Microsoft YaHei"
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
                }}  // end Component, Loader
            }
            Item {
                // 以太网设置页面 — Loader 懒加载
                Loader {
                    anchors.fill: parent
                    active: page2Loaded
                    sourceComponent: Component {
                Rectangle{
                    width:650
                    height:800
                    color:"transparent"
                    MouseArea  {
                        id: content
                        anchors.fill: parent

                        onClicked: focus = true
                    }
                    Text{
                        id:eth
                        text: qsTr("以太网")
                        font.pixelSize: 15;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        color: "white"
                        anchors{
                            left: parent.left
                            leftMargin: 30
                        }
                    }


                    InputPanel {
                        id: inputPanel
                        x: adaptive_width/8
                        y: adaptive_height/1.06
                        visible: false
                        z:99
                        anchors.left: parent.left
                        anchors.right: parent.right

                        states: State {
                            name: "visible"
                            /*  The visibility of the InputPanel can be bound to the Qt.inputMethod.visible property,
                                but then the handwriting input panel and the keyboard input panel can be visible
                                at the same time. Here the visibility is bound to InputPanel.active property instead,
                                which allows the handwriting panel to control the visibility when necessary.
                            */
                            when: inputPanel.active
                            PropertyChanges {
                                target: inputPanel
                                y: adaptive_height/1.06 - inputPanel.height
                                visible: true
                            }
                        }
                        transitions: Transition {
                            id: inputPanelTransition
                            from: ""
                            to: "visible"
                            reversible: true
                            enabled: !VirtualKeyboardSettings.fullScreenMode
                            ParallelAnimation {
                                NumberAnimation {
                                    properties: "y"
                                    duration: 250
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        Binding {
                            target: InputContext
                            property: "animating"
                            value: inputPanelTransition.running
                        }
                            AutoScroller {}
                    }

                    Text{
                        id:ethport
                        text: qsTr("网口")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: eth.bottom
                            topMargin: 30
                            left: parent.left
                            leftMargin: 30
                        }
                    }

                    CustomCombox{
                        id:combox_ethport
                        delegate_width:141
                        delegate_height:30
                        combox_bg:"images/wvga/system/input-bg.png"
                        modeldata: netports

                        Component.onCompleted: {
                            if (combox_ethport.combox_control.currentText)
                                selectedEthPort = combox_ethport.combox_control.currentText
                        }

                        anchors{
                            top:eth.bottom
                            topMargin: 28
                            left: ethport.left
                            leftMargin: 250
                        }
                    }
                    Binding {
                        target: settingsWindow
                        property: "selectedEthPort"
                        value: combox_ethport.combox_control.currentText
                    }

                    Text{
                        id:t1
                        text: qsTr("以太网")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: ethport.top
                            topMargin: 35
                            left: parent.left
                            leftMargin: 30
                        }
                    }
                    Text{

                        text: connect_net ? qsTr("电缆已接入") : qsTr("电缆已拔出")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: ethport.top
                            topMargin: 35
                            left: t1.left
                            leftMargin: 250
                        }

                    }
                    Text{
                        id:t2
                        text: qsTr("配置IPv4")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top:t1.top
                            topMargin: 35
                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    CustomCombox{
                        id:combox_dhcp
                        delegate_width:141
                        delegate_height:30
                        combox_bg:"images/wvga/system/input-bg.png"
                        modeldata: ["Manual", "DHCP"]

                        anchors{
                            top:t1.top
                            topMargin: 28
                            left: t2.left
                            leftMargin: 250
                        }
                    }
                    Text{
                        id:t3
                        text: qsTr("IP地址")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top:t2.top
                            topMargin: 35
                            left: parent.left
                            leftMargin: 30
                        }

                    }

                    Text {
                        text: net_ip
                        font.pixelSize: 12
                        color: "white"
                        width:141
                        height:25
                        visible: combox_dhcp.combox_control.currentText === "Manual" ? false : true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Image {
                            anchors.fill: parent
                            source: "images/wvga/system/input-bg.png"
                            z: -1
                        }
                        anchors{
                            top:t2.top
                            topMargin: 30
                            left: t3.left
                            leftMargin: 250
                            // verticalCenter: parent.verticalCenter
                        }
                    }

                    TextField {

                        id: ip_input
//                        width: 141
//                        height: 16
                        placeholderText: "192.168.xx.xx" /* 输入为空时显示的提示文字 */
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onAccepted: digitsField.focus = true
                        font.family: "Microsoft YaHei"
                        color: "white"
                        visible: combox_dhcp.combox_control.currentText === "Manual" ? true : false
                        validator: RegularExpressionValidator{regularExpression:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
                        background: Rectangle{

                            implicitWidth:141
                            implicitHeight:25
                            color: "transparent"
                            Image {
                                anchors.fill: parent
                                source: "images/wvga/system/input-bg.png"
                            }
                        }

                        anchors{
                            top:t2.top
                            topMargin: 30
                            left: t3.left
                            leftMargin: 250
                        }
                    }
                    Text{
                        id:t4
                        text: qsTr("子网掩码")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top:t3.top
                            topMargin: 35
                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    TextField{

                        id: netmask_input
//                        width: 141
//                        height: 16
                        placeholderText: "255.255.xx.xx" /* 输入为空时显示的提示文字 */
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onAccepted: digitsField.focus = true
                        font.family: "Microsoft YaHei"
                        color: "white"
                        validator: RegularExpressionValidator{regularExpression:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
                        background: Rectangle{

                            implicitWidth:141
                            implicitHeight:25
                            color: "transparent"
                            Image {
                                anchors.fill: parent
                                source: "images/wvga/system/input-bg.png"
                            }
                        }

                        anchors{
                            top:t3.top
                            topMargin: 30
                            left: t4.left
                            leftMargin: 250
                        }
                    }
                    Text{
                        id:t5
                        text: qsTr("网关")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top:t4.top
                            topMargin: 35
                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    TextField{
                        id: gw_input
//                        width: 141
//                        height: 16
                        placeholderText: "192.168.xx.xx" /* 输入为空时显示的提示文字 */
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onAccepted: digitsField.focus = true
                        font.family: "Microsoft YaHei"
                        color: "white"
                        validator: RegularExpressionValidator{regularExpression:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
                        background: Rectangle{

                            implicitWidth:141
                            implicitHeight:25
                            color: "transparent"
                            Image {
                                anchors.fill: parent
                                source: "images/wvga/system/input-bg.png"
                            }
                        }


                        anchors{
                            top:t4.top
                            topMargin: 30
                            left: t5.left
                            leftMargin: 250
                        }
                    }
                    Text{
                        id:t6
                        text: qsTr("DNS")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top:t5.top
                            topMargin: 35
                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    TextField{
                        id: dns_input
//                        width: 141
//                        height: 16
                        placeholderText: "114.114.114.114" /* 输入为空时显示的提示文字 */
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onAccepted: digitsField.focus = true
                        font.family: "Microsoft YaHei"
                        color: "white"
                        validator: RegularExpressionValidator{regularExpression:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
                        background: Rectangle{

                            implicitWidth:141
                            implicitHeight:25
                            color: "transparent"
                            Image {
                                anchors.fill: parent
                                source: "images/wvga/system/input-bg.png"
                            }
                        }


                        anchors{
                            top:t5.top
                            topMargin: 30
                            left: t6.left
                            leftMargin: 250

                        }
                    }

                    // 保存按键
                    Rectangle{
                        id:net_save_button_rec
                        width: 106
                        height: 31
                        color: "transparent"

                        anchors{
                            top:t6.top
                            topMargin: 35
                            left:    parent.left
                            leftMargin: 30

                        }
                        Image {
                            anchors.fill: parent
                            source: "images/wvga/system/save-button.png"
                        }
                        Text{
                            id:net_save_button
                            text: qsTr("保存")
                            font.pixelSize: 10;
                            font.family: "Microsoft YaHei"
                            font.bold: true
                            color: "white"
                            anchors{
                                centerIn: parent
                            }
                        }
                        MouseArea{
                            anchors.fill: parent;
                            onClicked: {
                                net_save_button_rec.opacity = 0.5
                                var net_info_string = combox_dhcp.combox_control.currentText + " " +ip_input.text + " " +
                                        netmask_input.text + " " + gw_input.text + " " +dns_input.text + " " +combox_ethport.combox_control.currentText
                                console.log(net_info_string)
                                getSyetemInfo.set_net_info(net_info_string)
                            }
                            onExited:{
                               net_save_button_rec.opacity = 1.0
                            }
                            onPressed: {

                               net_save_button_rec.opacity = 0.5
                            }
                        }
                    }

                }
                }}  // end Component, Loader
            }
            Item {
                // WiFi 设置页面 — Loader 懒加载（含 Dialog，需 Item 包装器）
                Loader {
                    anchors.fill: parent
                    active: page3Loaded && settingsWindow.wifi_avail
                    sourceComponent: Component {
                Item {
                Rectangle{
                    width:adaptive_width/1.26
                    height:adaptive_height*2
                    color:"transparent"


                    Text{
                        id:wifi_set_title
                        text: qsTr("WiFi设置")
                        font.pixelSize: 15;
                        font.family: "Microsoft YaHei"
                        font.bold: true
                        color: "white"
                        anchors{

                            left: parent.left
                            leftMargin: 30
                        }

                    }
                    // 打开wifi 按键 — checked 绑定到 settingsWindow.wifi_statu，页面切换后状态不丢失
                    CustomSwitch {
                        id:wifi_switch
                        anchors{
//                           left:wifi_set_title.right
                           bottom: wifi_set_title.bottom
                           right: parent.right
                        }

                        checked: settingsWindow.wifi_statu

                        // Bug3 修复: Qt6 要求显式声明 signal handler 参数
                        onClicked: function(checked) { openwifi(checked) }
                    }

                    // 扫描按键
                    Rectangle{
                        id:serch_rec
                        width: adaptive_width/1.45
                        height: adaptive_height/15
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
                            font.pixelSize: 10;
                            font.family: "Microsoft YaHei"
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
                            enabled: !getSyetemInfo.isScanning()  // 扫描中禁用，防止重复点击
                            onClicked: {
                               serch_rec.opacity = 0.5
                               if(wifi_statu)
                                    getSyetemInfo.get_wifi_list()

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
                    ListModel {
                        id: wifi_list_model

//                        ListElement {
//                            wifi_essid: "myir1"
//                            wifi_connect_status: qsTr("已连接")
//                            key_image: "images/wvga/system/key.png"
//                            signal_iamge:"images/wvga/system/wifi-signal.png"

//                        }
                    }
                    // 监听显式信号：关闭 WiFi 时清除列表
                    // wifi_list_model 在 Loader 内部，不能从外层 openwifi() 跨作用域访问
                    Connections {
                        target: settingsWindow
                        function onWifiPoweredOff() {
                            wifi_list_model.clear()
                        }
                    }
                    Connections {
                        target: getSyetemInfo
                        function onWifiReady(wifi_data) {
                            var image
                            wifi_list_model.clear()
                            console.log("the number of wifi: "+wifi_data.length/4)
                            for(var j=0;j<wifi_data.length/4;j++)
                            {
                                if (wifi_data[j*4+1] === "on")
                                    image= "images/wvga/system/key.png"
                                else
                                    image=""
                                wifi_list_model.append({
                                    "wifi_essid": wifi_data[j*4+2],
                                    "wifi_connect_status": qsTr("未启用"),
                                    "key_image":image,
                                    "signal_iamge":"images/wvga/system/wifi-signal.png",
                                    "signal": +wifi_data[j*4+3],
                                    "mac_addr": wifi_data[j*4+0]
                                })
                            }
                            // 按信号强度排序
                            for(var m=0; m<wifi_list_model.count; m++)
                            {
                                for(var n=0; n<m; n++)
                                {
                                    if(wifi_list_model.get(m).signal > wifi_list_model.get(n).signal)
                                        wifi_list_model.move(m,n,1)
                                }
                            }
                            // 输出扫描到wifi
                            for(var i=0 ; i<wifi_list_model.count;i++ )
                            {
                                console.log("Received ++: " +wifi_list_model.get(i).wifi_essid + " " +wifi_list_model.get(i).signal)
                            }
                        }
                        function onWifiConnected(wifi_essid_info, flag) {
                            for(var k=0; k < wifi_list_model.count; k++)
                            {
                                if(wifi_list_model.get(k).mac_addr===wifi_essid_info)
                                {
                                    if(flag === "true"){
                                        wifi_list_model.setProperty(k, "wifi_connect_status", qsTr("已连接"))
                                        wifi_list_model.move(k,0,1)
                                        if(!wifistatus){
                                            // 清空连接ui状态
                                            successText.visible = true
                                            connectingSpinner.running = false
                                            failText.visible = false
                                            connectbtn.enabled = false
                                            passwordField.readOnly = false
                                            outtime_timer.stop()
                                            wifistatus = true
                                        }
                                    }else{
                                        wifi_list_model.setProperty(k, "wifi_connect_status", qsTr("未启用"))
                                        wifistatus = false
                                    }
                                }
                            }
                        }
                        // wifi连接脚本返回判断
                        function onWifiConnectedStatus(flag) {
                            console.log("onWifiConnectedStatus")
                            if(flag === "false"){
                                connectingSpinner.running = false
                                failText.visible = true
                                connectbtn.enabled = true
                                passwordField.text = ""
                                passwordField.readOnly = false
                                outtime_timer.stop()
                            }
                        }
                    }
                    // wifi列表每一行
                    Component {
                        id: listDelegate

                        Item{
                            id:itemDelegate
                            focus:true
                            width: adaptive_width/1.45
                            height: 32
                            clip: true

                            Text{
                                id:wifi_essid_text
                                text: wifi_essid
                                font.pixelSize: 9;
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                color: "white"
                                anchors{

                                    top:parent.top

                                }

                            }
                            Text{

                                text: wifi_connect_status
                                font.pixelSize: 7;
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                color: "#A9A9A9"
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
    //                            source: "images/wvga/system/key.png"
                                source: key_image
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
    //                            source: "images/wvga/system/wifi-signal.png"
                                source:signal_iamge
                            }
                            // 连接按钮
                            Item{
                                id:content_rec
                                width: 105
                                height: 31

//                                color: "transparent"
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
                                    id: bttxt
                                    text: {
                                        if(model.wifi_connect_status === qsTr("已连接"))
                                            return qsTr("断开")
                                        else
                                            return qsTr("连接")
                                    }
                                    font.pointSize: 12;
                                    font.family: "Microsoft YaHei"
    //                                font.bold: true
                                    color: "white"
                                    anchors{

                                        centerIn:parent
                                    }
                                }

                                MouseArea{
                                    anchors.fill: parent;
                                    onClicked: {
                                        content_rec.opacity = 0.5
                                        listView.currentIndex = index;
                                        if(bttxt.text === qsTr("断开")){
                                            getSyetemInfo.disconnect_wifi()
                                            // P2: 断开后恢复轮询以检测状态变化
                                            getSyetemInfo.startwifitimer()
                                            return
                                        }

                                        // 清空连接ui状态
                                        selectedWifi = model
                                        successText.visible = false
                                        failText.visible = false
                                        connectingSpinner.running = false
                                        connectbtn.enabled = true
                                        passwordField.readOnly = false
                                        // 打开连接弹窗
                                        connectDialog.open()
    //                                    myPopup.open()
                                    }
                                    onExited:{
                                       content_rec.opacity = 1.0
                                    }
                                    onPressed: {

                                      content_rec.opacity = 0.5
                                    }
                                }

                            }

                        }

                    }
ListView {
                        id: listView
                        width: 548
                        height: 340
                        focus:true
                        anchors {
                            left: parent.left
                            leftMargin: 30
                            top: serch_rec.bottom
                            topMargin: 10
                        }
                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                        spacing: 20
                        model: wifi_list_model
                        delegate: listDelegate
                    }
                }
            }
                }  // end Item
                }}  // end Component, Loader
            // 连接对话框 — 非模态，点击遮罩由 SettingsWindow 的 MouseArea 提供
            Dialog {
                id: connectDialog
                parent: mainWnd.contentItem
                modal: false
                closePolicy: Popup.NoAutoClose
                title: qsTr("Connect") + " " + (selectedWifi ? selectedWifi.wifi_essid : "")
                width: 360
                height: 220
                x: (mainWnd.width - width) / 2
                y: inputPanel_passwd.active
                     ? (mainWnd.height/2 - height) / 2
                     : (mainWnd.height - height) / 2

                Behavior on y {
                    NumberAnimation { duration: 200 }
                }

                background: Rectangle {
                    anchors.fill: parent
                    opacity: 0.5
                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/fhd/public/pop_bg.png"
                    }
                }

                ColumnLayout {
                    spacing: 16
                    width: parent.width

                    // 密码输入
                    TextField {
                        id: passwordField
                        visible: selectedWifi && selectedWifi.key_image
                        placeholderText: qsTr("Password field")
                        font.family: "Microsoft YaHei"
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                        echoMode: TextInput.Password
                        color: "black"
                        Layout.fillWidth: true
                        onActiveFocusChanged: {
                            if(activeFocus) {
                                successText.visible = false
                                failText.visible = false
                            }
                        }
                    }
                    // 连接状态区域
                    Item {
                        id: statusArea
                        Layout.fillWidth: true
                        height: 40

                        // 连接动画（BusyIndicator）
                        BusyIndicator {
                            id: connectingSpinner
                            running: false
                            anchors.centerIn: parent
                            visible: connectingSpinner.running
                        }

                        // 成功提示
                        Text {
                            id: successText
                            text: qsTr("Connected")
                            color: "green"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                            visible: false
                        }

                        // 失败提示
                        Text {
                            id: failText
                            text: qsTr("Failed")
                            color: "red"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                            visible: false
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20
                        Button {
                            id: connectbtn
                            onClicked: connectDialog.startConnecting()
                            background: Rectangle {
                                radius: 5
                                color: parent.pressed ? "#2196F3" : "#1976D2"
                            }
                            contentItem: Text {
                                text: qsTr("connect")
                                font.pixelSize: 14
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: {
                                passwordField.text = ""
                                passwordField.readOnly = false
                                successText.visible = false
                                failText.visible = false
                                connectingSpinner.running = false
                                outtime_timer.stop()
                                connectbtn.enabled = true
                                connectDialog.close()
                            }
                            background: Rectangle {
                                radius: 5
                                color: parent.pressed ? "#2196F3" : "#1976D2"
                            }
                            contentItem: Text {
                                text: qsTr("cancel")
                                font.pixelSize: 14
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                function startConnecting() {
                    var flag = selectedWifi.key_image === "" ? "false" : "true"
                    var essid_passwd = selectedWifi.wifi_essid+"+"+passwordField.text+"+"+flag
                    getSyetemInfo.connect_wifi(essid_passwd)

                    successText.visible = false
                    failText.visible = false
                    connectingSpinner.running = true
                    connectbtn.enabled = false
                    passwordField.readOnly = true
                    outtime_timer.start()
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
                    id:time_rec
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5

                    color:"transparent"
                    Image{
                        id: time_icon_bg
//                        anchors.fill: parent
                        width:adaptive_width/6.7
                        height:adaptive_height/7.5
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
                        font.family: "Microsoft YaHei"
                        font.pointSize: 8;
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
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5
                    color:"transparent"
                    Image{
                        id: ethernet_icon_bg
		        width:adaptive_width/6.7
                        height:adaptive_height/7.5
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
                        font.pointSize: 8;
                        font.family: "Microsoft YaHei"
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
                            page2Loaded = true
                            view.currentIndex = 1
                        }
                    }
                }
                Rectangle{
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5
                    color:"transparent"
                    visible: wifi_avail
                    Image{
                        id: wifi_icon_bg
                        width:adaptive_width/6.7
                        height:adaptive_height/7.5
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
                        font.pointSize: 8;
                        font.family: "Microsoft YaHei"
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
                            page3Loaded = true
                            view.currentIndex = 2;
                        }
                    }
                }
            }
        }
    }
}
