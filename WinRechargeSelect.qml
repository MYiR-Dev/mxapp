import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ChargeManage 1.0

Rectangle {
    id:root
    visible: true
    anchors.fill: parent
    color: "#00000000"

    Image {
        id: background_img
        source: "qrc:/images/wvga/charge/background2.jpg"
        anchors.fill: parent
    }

    property var choose_scheme: 0
    signal recharge_amount(var value)
    onVisibleChanged: {
        if(visible==true){
            init()
            sign_init()
            connect_timer.start()
        }
        else{
            connect_timer.stop()
        }
    }

    function sign_init(){
        if(charge_Wd.client_connect_flag===1 && charge_Wd.client_connect_server_flag===0){
            sign_104_des_text.text="disconnect"
            sign_104_img.source="qrc:/images/wvga/charge/disconnect.png"
        }
        else if(charge_Wd.client_connect_flag===1 && charge_Wd.client_connect_server_flag===1){
            sign_104_des_text.text="connect"
            sign_104_img.source="qrc:/images/wvga/charge/connect.png"
        }
        else if(charge_Wd.client_connect_flag===0){
            sign_104_des_text.text="disconnect"
            sign_104_img.source="qrc:/images/wvga/charge/disconnect.png"
        }
    }

    function update_win(){
        if(choose_scheme==100){
            init_win()
            recharge_scheme_one.color="#FA9D40"
        }
        else if(choose_scheme==80){
            init_win()
            recharge_scheme_two.color="#FA9D40"
        }
        else if(choose_scheme==60){
            init_win()
            recharge_scheme_three.color="#FA9D40"
        }
        else if(choose_scheme==40){
            init_win()
            recharge_scheme_four.color="#FA9D40"
        }
        else if(choose_scheme==20){
            init_win()
            recharge_scheme_five.color="#FA9D40"
        }
        else if(choose_scheme==10){
            init_win()
            recharge_scheme_six.color="#FA9D40"
        }
    }

    function init_win(){
        recharge_scheme_one.color=Qt.rgba(0,0,0,0)
        recharge_scheme_two.color=Qt.rgba(0,0,0,0)
        recharge_scheme_three.color=Qt.rgba(0,0,0,0)
        recharge_scheme_four.color=Qt.rgba(0,0,0,0)
        recharge_scheme_five.color=Qt.rgba(0,0,0,0)
        recharge_scheme_six.color=Qt.rgba(0,0,0,0)
    }

    function init(){
        choose_scheme=100
        init_win()
        update_win()
    }

    TitleRightBar{
        id:current_time_show
        anchors{
            top: parent.top
            right: parent.right
            rightMargin: 10
        }
    }

    Rectangle{
        id:sign_104
        visible: true
        height: 40
        width: 150
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 150
        radius: 10
        color: "#00000000"

        Image {
            id: sign_104_img
            visible: true
            source: "qrc:/images/wvga/charge/disconnect.png"
            width: 40
            height: 40
            anchors.left: parent.left
            anchors.top: parent.top
        }

        Label{
            id:sign_104_des
            visible: true
            anchors.left: sign_104_img.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            Text {
                id: sign_104_des_text
                color: "white"
                anchors.fill: parent
                visible: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 15
                text: qsTr("")
            }
        }

        Timer{
            id:connect_timer
            repeat: true
            running: false
            triggeredOnStart: true
            interval: 1000
            onTriggered: {
                sign_init()
            }
        }
    }

    //确认按钮
    Rectangle{
        id:sure_button
        visible: true
        height: 50
        width: 180
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 15
        color: "#28529C"
        radius: 5

        Text{
            visible: true
            anchors.fill: parent
            text: "确认"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 30
            color: "white"
        }

        MouseArea{
            id:sure_mousearea
            visible: true
            anchors.fill: parent
            hoverEnabled: true

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                if(choose_scheme>0){
                    recharge_amount(choose_scheme)
                    pay_interface.visible=true
                    recharge_select.visible=false
                }
            }
        }
    }

    //取消按钮
    Rectangle{
        id:cancel_button
        visible: true
        height: 50
        width: 180
        anchors.right: sure_button.left
        anchors.bottom: parent.bottom
        anchors.rightMargin: 15
        color: "#28529C"
        radius: 5

        Text{
            visible: true
            anchors.fill: parent
            text: "取消"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 30
            color: "white"
        }

        MouseArea{
            id:cancel_mousearea
            visible: true
            anchors.fill: parent
            hoverEnabled: true

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                home_screen.visible=true
                recharge_select.visible=false
            }
        }
    }

    Rectangle{
        id:page_top
        visible: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 15
        anchors.topMargin: 0.08*parent.height
        height:30
        color: "#00000000"

        Image {
            id: page_top_icon
            visible: true
            width: parent.height
            height: parent.height
            anchors.top: parent.top
            anchors.left: parent.left
            source: "qrc:/images/wvga/charge/head.png"
        }

        Label{
            id:page_top_label_1
            visible: true
            height: 30
            anchors.top: parent.top
            anchors.left: page_top_icon.right
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignLeft"
            text: "姓名:许梦燃\t余额:"+String((home_screen.amount).toFixed(2))
            color: "white"
            font.family: "Microsoft YaHei"
            font.pixelSize: 20
        }
    }

    Rectangle{
        id:page_main
        visible: true
        anchors.top: page_top.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: cancel_button.top
        anchors.topMargin: 15
        anchors.bottomMargin: 15
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        color: "#00000000"
        border.color: "#8E9BBB"
        border.width: 3
        radius: 20

        Label{
            id:recharge_title_label
            visible: true
            text: "充值金额"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            //anchors.topMargin: 10
            height: 50
            color:"white"
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignHCenter"
            font.family: "Microsoft YaHei"
            font.pixelSize: 35
        }

        Rectangle{
            id:recharge_scheme_one
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: parent.left
            anchors.top: recharge_title_label.bottom
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 3
            color: "#00000000"
			
			/*
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: recharge_scheme_one.width
                    height: recharge_scheme_one.height
                    radius: recharge_scheme_one.radius
                }
            }
			*/

            Text {
                id: recharge_scheme_one_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥100.00")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 40
                color: "white"
            }

            MouseArea{
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    choose_scheme=100
                    update_win()
                }
            }
        }

        Rectangle{
            id:recharge_scheme_two
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: recharge_scheme_one.right
            anchors.top: recharge_title_label.bottom
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 3
            color: "#00000000"

            Text {
                id: recharge_scheme_two_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥80.00")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 40
                color: "white"
            }

            MouseArea{
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    choose_scheme=80
                    update_win()
                }
            }
        }

        Rectangle{
            id:recharge_scheme_three
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: recharge_scheme_two.right
            anchors.top: recharge_title_label.bottom
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 3
            color: "#00000000"

            Text {
                id: recharge_scheme_three_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥60.00")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 40
                color: "white"
            }

            MouseArea{
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    choose_scheme=60
                    update_win()
                }
            }
        }

        Rectangle{
            id:recharge_scheme_four
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: parent.left
            anchors.top: recharge_scheme_one.bottom
            anchors.topMargin: 0.1*parent.height
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 3
            color: "#00000000"

            Text {
                id: recharge_scheme_four_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥40.00")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 40
                color: "white"
            }

            MouseArea{
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    choose_scheme=40
                    update_win()
                }
            }
        }

        Rectangle{
            id:recharge_scheme_five
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: recharge_scheme_four.right
            anchors.top: recharge_scheme_one.bottom
            anchors.topMargin: 0.1*parent.height
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 3
            color: "#00000000"

            Text {
                id: recharge_scheme_five_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥20.00")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 40
                color: "white"
            }

            MouseArea{
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    choose_scheme=20
                    update_win()
                }
            }
        }

        Rectangle{
            id:recharge_scheme_six
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: recharge_scheme_five.right
            anchors.top: recharge_scheme_one.bottom
            anchors.topMargin: 0.1*parent.height
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 3
            color: "#00000000"

            Text {
                id: recharge_scheme_six_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥10.00")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 40
                color: "white"
            }

            MouseArea{
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    choose_scheme=10
                    update_win()
                }
            }
        }
    }
}
