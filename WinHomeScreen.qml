import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ChargeManage 1.0

Rectangle {
    visible: true
    anchors.fill: parent
    color: "#00000000"

    Image {
        id: background_img
        source: "qrc:/images/wvga/charge/background.jpg"
        anchors.fill: parent
    }

    onVisibleChanged: {
        charge_Wd.client_connect_flag=1
        if(visible==true){
            if(charge_Wd.server_open_flag===1){
                server_104.color="#FA9D40"
                charge_Wd.server_open_flag=1
                server_104_text.text="关闭104服务端"
            }
            else{
                server_104.color="#2453A1"
                charge_Wd.server_open_flag=0
                server_104_text.text="启动104服务端"
            }

            sign_init()
            connect_timer.start()
            if(home_screen.sign_flag===0){
                mode1()
            }
            else{
                mode2()
            }
        }
    }

    function mode1(){
        sign_flag=0
        tip_text.visible=false
        sign_in_section_title.visible=true
        sign_in_section_image.visible=true
        sign_in_account_image.visible=false
        label_1.visible=false
        label_2.visible=false
        btn_log_out.visible=false
        btn_recharge.visible=false
    }

    function mode2(){
        sign_flag=1
        tip_text.visible=false
        sign_in_section_title.visible=false
        sign_in_section_image.visible=false
        sign_in_account_image.visible=true
        label_1_text.text="姓名:许梦燃"
        label_2_text.text="余额:¥"+String((home_screen.amount).toFixed(2))
        label_1.visible=true
        label_2.visible=true
        btn_log_out.visible=true
        btn_recharge.visible=true
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

    TitleLeftBar{
        id: leftBar
        titleIcon: "qrc:/images/wvga/back_icon_nor.png"
        titleName: qsTr("")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            home_screen.sign_flag=0
            var result=charge104_c.close_server
            charge_Wd.client_connect_flag=0
            charge_Wd.server_open_flag=0
            charge_Wd.client_connect_server_flag=0
            connect_timer.stop()
            charge_Wd.close()
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
                var result1=charge104_c.get_connect_state
                charge_Wd.client_connect_server_flag=result1
                if(charge_Wd.server_open_flag===1 && result1===0){
                    var result2=charge104_c.tcp_connect
                }
            }
        }
    }

    Rectangle{
        id:server_104
        visible: true
        width: 180
        height: 40
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 15
        anchors.bottomMargin: 40
        radius: 5
        Text {
            id: server_104_text
            text: qsTr("启动104服务端")
            anchors.fill: parent
            visible: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 20
            color: "white"
        }

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            visible: true
            acceptedButtons: Qt.LeftButton

            onClicked: {
                if(charge_Wd.server_open_flag===0){
                    var result1=charge104_c.open_server
                    if(result1===1){
                        server_104.color="#FA9D40"
                        charge_Wd.server_open_flag=1
                        server_104_text.text="关闭104服务端"
                    }
                    else{
                        server_104.color="#2453A1"
                        charge_Wd.server_open_flag=0
                        server_104_text.text="启动104服务端"
                    }
                }
                else{
                    var result2=charge104_c.close_server
                    server_104.color="#28529C"
                    charge_Wd.server_open_flag=0
                    server_104_text.text="启动104服务端"
                }
            }
        }
    }

    Rectangle{
        id:page_main
        visible: true
        anchors.top:current_time_show.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 15
        anchors.bottomMargin: 15
        color: "#00000000"

        Rectangle{
            id:connect_gun_section
            visible: true
            width: page_main.width/2
            height: page_main.height
            color: "#00000000"
            anchors.top: page_main.top
            anchors.left: page_main.left
            Rectangle{
                id:connect_gun_section_title
                visible: true
                width: 0.5*parent.width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 0.2*parent.height
                anchors.leftMargin: 0.25*parent.width
                color: "#00000000"

                Text {
                    id: connect_gun_section_title_text
                    visible: true
                    anchors.fill: parent
                    text: qsTr("请连接充电枪")
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 30
                }
            }

            Rectangle{
                id:connect_gun_section_image
                visible: true
                width: sign_in_account_icon.width
                height: sign_in_account_icon.height
                anchors.top: connect_gun_section_title.bottom
                anchors.left: parent.left
                anchors.topMargin: 0.05*parent.height
                anchors.leftMargin: (parent.width-width)/2
                radius: 30
                color: "#00000000"
				/*
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: connect_gun_section_image.width
                        height: connect_gun_section_image.height
                        radius: connect_gun_section_image.radius
                    }
                }
				*/

                Image {
                    id:pile_imgae
                    visible: true
                    anchors.fill: parent
                    source: "qrc:/images/wvga/charge/pile.png"
                }
            }

            Rectangle{
                id:connect_gun_section_btn
                visible: true
                width: 0.4*connect_gun_section_image.width
                height: 0.2*connect_gun_section_image.height
                anchors.top: connect_gun_section_image.bottom
                anchors.left: parent.left
                anchors.topMargin: 15
                //anchors.topMargin: 0.05*parent.height
                anchors.leftMargin: (parent.width-width)/2
                color: "#28529C"
                radius: 5

                Text{
                    visible: true
                    anchors.fill: parent
                    text: "确认连接"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                    onClicked: {
                        if(sign_flag==0){
                            tip_text.visible=true
                        }
                        else{
                            charge_scheme.visible=true
                            home_screen.visible=false
                        }
                    }
                }
            }

            Label{
                id:tip_text
                visible: false
                height: 50
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: connect_gun_section_btn.bottom
                anchors.topMargin: 10
                verticalAlignment: "AlignVCenter"
                horizontalAlignment: "AlignHCenter"

                text: "请先进行扫码登录"
                font.family: "Microsoft YaHei"
                font.pixelSize: 20
                color: "red"
            }
        }

        Rectangle{
            id:sign_in_section
            visible: true
            width: page_main.width/2-1
            height: page_main.height
            color: "#00000000"
            anchors.top: page_main.top
            anchors.right: page_main.right

            Rectangle{
                id:sign_in_section_title
                visible: true
                width: 0.5*parent.width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 0.2*parent.height
                anchors.leftMargin: 0.25*parent.width
                color: "#00000000"

                Text {
                    id: sign_in_section_title_text
                    visible: true
                    anchors.fill: parent
                    text: qsTr("扫码登录")
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 30
                }
            }

            Rectangle{
                id:sign_in_section_icon
                visible: true
                width: connect_gun_section_image.height
                height: width
                anchors.top: sign_in_section_title.bottom
                anchors.left: parent.left
                anchors.topMargin: 0.05*parent.height
                anchors.leftMargin: (parent.width-width)/2
                radius: 30
                color: "#00000000"
				/*
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: sign_in_section_icon.width
                        height: sign_in_section_icon.height
                        radius: sign_in_section_icon.radius
                    }
                }
				*/
                Image {
                    id:sign_in_section_image
                    visible: true
                    anchors.fill: parent
                    source: "qrc:/images/wvga/charge/code.png"
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                    onClicked: {
                        if(sign_flag==0){
                            if(home_screen.first_sign_flag===0){
                                home_screen.first_sign_flag=1
                                home_screen.amount=100
                            }
                            mode2()
                        }
                    }
                }
            }

            Rectangle{
                id:sign_in_account_icon
                visible: true
                width: 0.5*parent.width
                height: 0.6*width
                anchors.top: sign_in_section_title.bottom
                anchors.left: parent.left
                anchors.topMargin: 0.05*parent.height
                anchors.leftMargin: (parent.width-width)/2
                radius: 30
                color: "#00000000"
				/*
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: sign_in_account_icon.width
                        height: sign_in_account_icon.height
                        radius: sign_in_account_icon.radius
                    }
                }
				*/

                Image {
                    id: sign_in_account_image
                    visible: true
                    anchors.fill: parent
                    source: "qrc:/images/wvga/charge/account.png"
                }

                Label{
                    id:label_1
                    visible: false
                    anchors.bottom: sign_in_account_icon.bottom
                    anchors.left: sign_in_account_icon.left
                    anchors.bottomMargin: 25
                    anchors.leftMargin: 0.2*parent.width
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                    Text {
                        id: label_1_text
                        text: "姓名:许梦燃"
                        anchors.fill: parent
                        color: "black"
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }


                Label{
                    id:label_2
                    visible: false
                    anchors.bottom: sign_in_account_icon.bottom
                    anchors.right: sign_in_account_icon.right
                    anchors.bottomMargin: 25
                    anchors.rightMargin: 0.2*parent.width
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                    Text {
                        id: label_2_text
                        text: "账户余额:¥100.00"
                        color: "black"
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 20
                        anchors.fill:parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle{
                id:btn_log_out
                visible: false
                width: connect_gun_section_btn.width
                height: connect_gun_section_btn.height
                anchors.left: sign_in_account_icon.left
                anchors.top: sign_in_account_icon.bottom
                anchors.topMargin: 15
                color: "#28529C"
                radius: 5

                Text{
                    visible: true
                    anchors.fill: parent
                    text: "退出登录"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        mode1()
                    }
                }
            }

            Rectangle{
                id:btn_recharge
                visible: false
                width: connect_gun_section_btn.width
                height: connect_gun_section_btn.height
                anchors.right: sign_in_account_icon.right
                anchors.top: sign_in_account_icon.bottom
                anchors.topMargin: 15
                color: "#28529C"
                radius: 5

                Text{
                    visible: true
                    anchors.fill: parent
                    text: "充值余额"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        home_screen.visible=false
                        recharge_select.visible=true
                    }
                }
            }
        }
    }
}
