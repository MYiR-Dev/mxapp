import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import GetSystemInfoAPI 1.0
import QtQuick.VirtualKeyboard 2.2
import QtQuick.VirtualKeyboard.Settings 2.2
import QtQuick.VirtualKeyboard.Styles 2.2
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
SystemWindow {
    id: settingsWindow
    title: "settings"

    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
    signal message(string msg)
    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("系统设置")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {

            settingsWindow.close()
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
            wifi_statu = true
//            getSyetemInfo.get_wifi_list()
        }
        else
        {
            wifi_list_model.clear()

            getSyetemInfo.wifi_close()
            wifi_statu = false
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


            }
            Item {
                id: secondPage
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
                        id:t1
                        text: qsTr("以太网")
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
                    Text{

                        text: getSyetemInfo.get_net_status() ? qsTr("电缆已接入") : qsTr("电缆已拔出")
                        font.pixelSize: 10;
                        font.family: "Microsoft YaHei"
                        color: "white"
                        anchors{
                            top: eth.bottom
                            topMargin: 30
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
//                        Text{

//                            text: "xx"
//                            font.pointSize: 10;

//                            color: "white"

//                            Layout.row: 1
//                            Layout.column: 1
//                        }
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

                    TextField {

                        id: ip_input
//                        width: 141
//                        height: 16
                        placeholderText: "192.168.xx.xx" /* 输入为空时显示的提示文字 */
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onAccepted: digitsField.focus = true
                        font.family: "Microsoft YaHei"
                        color: "white"
                        validator: RegExpValidator{regExp:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
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
                        validator: RegExpValidator{regExp:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
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
                        validator: RegExpValidator{regExp:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
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
                        validator: RegExpValidator{regExp:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
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
//                                console.log(combox_dhcp.combox_control.currentText)
//                                console.log(ip_input.text)
//                                console.log(netmask_input.text)
//                                console.log(gw_input.text)
//                                console.log(dns_input.text)
                                var net_info_string = combox_dhcp.combox_control.currentText + " " +ip_input.text + " " +
                                        netmask_input.text + " " + gw_input.text + " " +dns_input.text
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
            }
            Item {
                id: thirdPage

                Rectangle{
                    width:adaptive_width/1.26
                    height:adaptive_height*2
                    color:"transparent"

                    InputPanel {
                        id: inputPanel_passwd
                        x: adaptive_width/8
                        y: adaptive_height/1.06
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
                            when: inputPanel_passwd.active
                            PropertyChanges {
                                target: inputPanel_passwd
                                y: adaptive_height/1.06 - inputPanel_passwd.height
                            }
                        }
                        transitions: Transition {
                            id: inputPanelTransition_passwd
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
                            value: inputPanelTransition_passwd.running
                        }
                            AutoScroller {}
                    }


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

                    CustomSwitch {
                        id:wifi_switch
                        anchors{
//                           left:wifi_set_title.right
                           bottom: wifi_set_title.bottom
                           right: parent.right
                        }
                        property bool backend: false

                        checked:   backend

                        onClicked: backend = checked
                        Component.onCompleted: clicked.connect(openwifi)
                    }


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
                        Component.onCompleted:{
//                            getSyetemInfo.get_wifi_list()
//                            getSyetemInfo.wifi_close()
//                            getSyetemInfo.wifi_open()
//                            getSyetemInfo.connect_wifi("long+6032509792+qrc:/images/wvga/system/key.png")
                        }

                        MouseArea{
                            anchors.fill: parent;
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
                    Connections {
                        target: getSyetemInfo
                        onWifiReady: {
                             var image
                             wifi_list_model.clear()
                             console.log(wifi_data.length/3)
                             for(var j=0;j<wifi_data.length/3;j++)
                             {
                                 if (wifi_data[j*3+1] === "on")
                                      image= "images/wvga/system/key.png"
                                 else
                                      image=""
//                                 console.log("Received ++: " +wifi_data[j*3+2])
                                 wifi_list_model.append({
                                     "wifi_essid": wifi_data[j*3+2],
                                     "wifi_connect_status": qsTr("未启用"),
                                     "key_image":image,
                                     "signal_iamge":"images/wvga/system/wifi-signal.png",
                                     "signal":wifi_data[j*3+0]
                                 })

                             }


                                   for(var m=0; m<wifi_list_model.count; m++)
                                   {
                                       for(var n=0; n<m; n++)
                                       {
                                           if(wifi_list_model.get(m).signal > wifi_list_model.get(n).signal)
                                               wifi_list_model.move(m,n,1)
//                                           break
                                       }
                                   }

                             for(var i=0 ; i<wifi_data.length/3;i++ )
                             {
                                 console.log("Received ++: " +wifi_list_model.get(i).wifi_essid)
//                                 console.log("Received ++: " +wifi_list_model.get(i).wifi_connect_status)
//                                 console.log("Received ++: " +wifi_list_model.get(i).key_image)
//                                 console.log("Received ++: " +wifi_list_model.get(i).signal_iamge)
                             }
                        }
                        onWifiConnected:{
                            for(var k=0; k < wifi_list_model.count; k++)
                            {
                                if(wifi_list_model.get(k).wifi_essid===wifi_essid_info)
                                {
                                    wifi_list_model.setProperty(k, "wifi_connect_status", qsTr("已连接"))
//                                   wifi_list_model.set(k).wifi_connect_status = "ddd"
//                                   console.log("Received ++: " +wifi_list_model.get(k).wifi_connect_status)
                                }
                                else
                                    wifi_list_model.setProperty(k, "wifi_connect_status", qsTr("未启用"))
                            }
//                            console.log("Received ++: " +wifi_essid_info)
                        }
                    }
                    Component {
                        id: listDelegate

                        Item{
                            id:itemDelegate
                            focus:true
                            width: adaptive_width/1.45
                            height: 32
                            clip: true

//                            color: "transparent"

//                            anchors{
//                                left: parent.left
//                                leftMargin: 30
//                                top: serch_rec.bottom
//                                topMargin: 10
//                            }
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
                            TextField{
                                id: passwd_input
                                width: 141
                                height: 32
                                echoMode: TextInput.Password
                                placeholderText: "Password field"
                                font.family: "Microsoft YaHei"
                                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                                onAccepted: upperCaseField.focus = true
                                color: "white"
                                background: Rectangle{

                                    implicitWidth:141
                                    implicitHeight:32
                                    color: "transparent"
                                    Image {
                                        anchors.fill: parent
                                        source: "images/wvga/system/input-bg.png"
                                    }
                                }
                                anchors{

                                    left:parent.left
                                    leftMargin: 100

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

                                    text: qsTr("连接")
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
                                        focus = true
                                        listView.currentIndex = index;

                                        getSyetemInfo.disconnect_wifi()
                                        var essid_passwd = wifi_essid_text.text+"+"+passwd_input.text+"+"+key_icon.source
                                        getSyetemInfo.connect_wifi(essid_passwd)
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
                            view.currentIndex = 1
                        }
                    }
                }
                Rectangle{
                    width:adaptive_width/6.55
                    height:adaptive_height/7.5
                    color:"transparent"
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
                            view.currentIndex = 2;
                        }
                    }
                }
            }
        }
    }
}
