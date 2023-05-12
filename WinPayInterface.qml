import ChargeManage 1.0
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3


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

    property var time_flag: 0

    onVisibleChanged: {
        if(visible==true){
            mode1()
            sign_init()
            connect_timer.start()
            cancel_mousearea.enabled=true
            page_main_title_text.text="扫码支付:¥"+String(Number(recharge_select.recharge_num).toFixed(2))
            cancel_button.visible=true
        }
        else{
            connect_timer.stop()
        }
    }

    function mode1(){
        pay_success_text.visible=false
        page_main_title.visible=true
        code_image.height=0.7*page_main.height
        code_image.width=code_image.height
        code_image.source="qrc:/images/wvga/charge/code.png"
        wechat_pay.visible=true
        wechat_pay_text.visible=true
        ali_pay.visible=true
        ali_pay_text.visible=true
        app_text.visible=true
    }

    function mode2(){
        time_flag=2
        pay_success_text.visible=true
        page_main_title.visible=false
        code_image.height=0.4*page_main.height
        code_image.width=code_image.height
        code_image.source="qrc:/images/wvga/charge/pay_success.png"
        wechat_pay.visible=false
        wechat_pay_text.visible=false
        ali_pay.visible=false
        ali_pay_text.visible=false
        app_text.visible=false
    }

    function sign_init(){
        if(charge_Wd.client_connect_flag===1 && charge_Wd.client_connect_server_flag===1){
            sign_104_des_text.text="connect"
            sign_104_img.source="qrc:/images/wvga/charge/connect.png"
        }
        else{
            sign_104_des_text.text="disconnect"
            sign_104_img.source="qrc:/images/wvga/charge/disconnect.png"
        }
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

    //取消充电按钮
    Rectangle{
        id:cancel_button
        visible: true
        height: 50
        width: 180
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 15
        anchors.bottomMargin: 15
        color: "#28529C"
        radius: 5

        Text{
            visible: true
            anchors.fill: parent
            text: "取消充值"
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
                pay_interface.visible=false
                recharge_select.visible=true
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

        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 15
        anchors.bottomMargin: 15

        color: "#00000000"
        radius: 10
        border.color: "#8E9BBB"
        border.width: 3

        Rectangle{
            id:page_main_title
            visible: true
            anchors.left: parent.left
            anchors.top: parent.top

            width: 0.7*parent.height
            height: 50

            anchors.leftMargin: (parent.width-width)/2
            anchors.topMargin: 10
            color: "#00000000"

            Text {
                id: page_main_title_text
                visible: true
                anchors.fill: parent
                text: qsTr("扫码支付:")

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                font.family: "Microsoft YaHei"
                font.pixelSize: 35
                color: "white"
            }
        }

        Image {
            id: code_image
            visible: true
            anchors.top: page_main_title.bottom
            anchors.left: parent.left

            width: 0.7*parent.height
            height: width
            anchors.topMargin: 5
            anchors.leftMargin: (parent.width-width)/2
            source: "qrc:/images/wvga/charge/code.png"

            MouseArea{
                anchors.fill: parent
                visible: true
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                onClicked: {
                    mode2()
                    timer.start()
                    cancel_mousearea.enabled=false
                    cancel_button.visible=false
                }
            }
        }

        Timer{
            id:timer
            interval: 1000
            running: false
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                time_flag--
                if(time_flag===0){
                    timer.stop()
                    home_screen.amount=Number(home_screen.amount)+Number(recharge_select.recharge_num)
                    recharge_select.recharge_num=0
                    pay_interface.visible=false
                    home_screen.visible=true
                }
            }
        }

        Rectangle{
            id:pay_method
            visible: true
            height: 50
            anchors.top: code_image.bottom
            anchors.left: code_image.left
            anchors.right: code_image.right
            anchors.topMargin: 5
            //anchors.right: parent.right
            color: "#00000000"

            Text {
                id: pay_success_text
                visible: true
                anchors.fill: parent
                text: qsTr("支付成功")
                color: "white"
                font.family: "Microsoft YaHei"
                font.pixelSize: 45
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Image {
                id: wechat_pay
                visible: true
                height: 50
                width: height
                anchors.top: parent.top
                anchors.left: parent.left
                source: "qrc:/images/wvga/charge/wechat.png"
            }

            Label{
                id:wechat_pay_text
                visible: true
                height: 50
                anchors.top: parent.top
                anchors.left: wechat_pay.right
                text: "微信/"
                font.family: "Microsoft YaHei"
                font.pixelSize: 30
                color: "white"
            }

            Image {
                id: ali_pay
                visible: true
                height: 50
                width: height
                anchors.top: parent.top
                anchors.left: wechat_pay_text.right
                source: "qrc:/images/wvga/charge/alipay.png"
            }

            Label{
                id:ali_pay_text
                visible: true
                height: 50
                anchors.top: parent.top
                anchors.left: ali_pay.right

                text: "支付宝"
                font.family: "Microsoft YaHei"
                font.pixelSize: 30
                color: "white"
            }

            Label{
                id:app_text
                visible: true
                height: 50
                anchors.top: parent.top
                anchors.left: ali_pay_text.right

                text: "APP扫码支付"
                font.family: "Microsoft YaHei"
                font.pixelSize: 30
                color: "white"
            }
        }
    }
}
