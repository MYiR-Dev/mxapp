import ChargeManage 1.0
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Rectangle {
    id: root
    visible: true
    anchors.fill: parent
    color: "#00000000"

    Image {
        id: background_img
        source: "qrc:/images/wvga/charge/background2.jpg"
        anchors.fill: parent
    }

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

    function init(){
        mode1()
        tip_text.visible=false
        charge_scheme.quick_flag=0
    }

    function init_win(){
        charge_scheme_one.color=Qt.rgba(0,0,0,0)
        charge_scheme_two.color=Qt.rgba(0,0,0,0)
        charge_scheme_three.color=Qt.rgba(0,0,0,0)
        charge_scheme_four.color=Qt.rgba(0,0,0,0)
        charge_scheme_five.color=Qt.rgba(0,0,0,0)
        charge_scheme_six.color=Qt.rgba(0,0,0,0)
    }

    function mode1(){
        mode_fee.color="#FA9D40"
        mode_time.color="#28529C"
        charge_scheme.choose_scheme=1
        charge_scheme.fee_flag=1
        charge_scheme.time_flag=0
        charge_scheme.choose_fee=0
        charge_scheme_two_text.text="¥60.00"
        charge_scheme_three_text.text="¥50.00"
        charge_scheme_four_text.text="¥40.00"
        charge_scheme_five_text.text="¥30.00"
        charge_scheme_six_text.text="¥20.00"
        update_win()
    }

    function mode2(){
        charge_scheme.choose_scheme=1
        mode_time.color="#FA9D40"
        mode_fee.color="#28529C"
        charge_scheme.fee_flag=0
        charge_scheme.time_flag=1
        charge_scheme.choose_fee=0
        charge_scheme_two_text.text="5小时"
        charge_scheme_three_text.text="4小时"
        charge_scheme_four_text.text="3小时"
        charge_scheme_five_text.text="2小时"
        charge_scheme_six_text.text="1小时"
        update_win()
    }

    function update_win(){
        if(charge_scheme.choose_scheme===1){
            init_win()
            charge_scheme_one.color="#FA9D40"
        }
        else if(charge_scheme.choose_scheme===2){
            init_win()
            charge_scheme_two.color="#FA9D40"
        }
        else if(charge_scheme.choose_scheme===3){
            init_win()
            charge_scheme_three.color="#FA9D40"
        }
        else if(charge_scheme.choose_scheme===4){
            init_win()
            charge_scheme_four.color="#FA9D40"
        }
        else if(charge_scheme.choose_scheme===5){
            init_win()
            charge_scheme_five.color="#FA9D40"
        }
        else if(charge_scheme.choose_scheme===6){
            init_win()
            charge_scheme_six.color="#FA9D40"
        }
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

    //取消按钮
    Rectangle{
        id:cancel_button
        visible: true
        height: 50
        width: 180
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: 15
        anchors.bottomMargin: 15
        radius: 5
        color: "#28529C"

        Text {
            text: qsTr("取消")
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
                charge_scheme.visible=false
            }
        }
    }

    //确认按钮
    Rectangle{
        id:normal_button
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
            id:normal_btn
            visible: true
            anchors.fill: parent
            text: "常规充电"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 30
            color: "white"
        }

        MouseArea{
            id:normal_mousearea
            visible: true
            anchors.fill: parent
            hoverEnabled: true

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                if(home_screen.amount===0 || (charge_scheme.fee_flag===1 && charge_scheme.choose_fee>home_screen.amount)){
                    tip_text.visible=true
                    tip_text.text="余额不足!!!"
                }
                else{
                    tip_text.visible=false
                    charge_scheme.quick_flag=0
                    charge_monitor.visible=true
                    charge_scheme.visible=false
                }
            }
        }
    }

    //确认按钮
    Rectangle{
        id:quick_button
        visible: true
        height: 50
        width: 180
        anchors.right: normal_button.left
        anchors.bottom: parent.bottom

        anchors.rightMargin: 15
        anchors.bottomMargin: 15
        color: "#28529C"
        radius: 5

        Text{
            id:quick_btn
            visible: true
            anchors.fill: parent
            text: "快速充电"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 30
            color: "white"
        }

        MouseArea{
            id:quick_mousearea
            visible: true
            anchors.fill: parent
            hoverEnabled: true

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                if(home_screen.amount===0 || (charge_scheme.fee_flag===1 && charge_scheme.choose_fee>home_screen.amount)){
                    tip_text.visible=true
                    tip_text.text="余额不足!!!"
                }
                else{
                    tip_text.visible=false
                    charge_scheme.quick_flag=1
                    charge_monitor.visible=true
                    charge_scheme.visible=false
                }
            }
        }
    }

    Label{
        id:tip_text
        visible: true
        height: 25
        width: 0.5*parent.width
        anchors.bottom: parent.bottom
        anchors.right: quick_button.left
        anchors.rightMargin: 15
        anchors.bottomMargin: 15
        color: "red"
        horizontalAlignment: "AlignRight"
        verticalAlignment: "AlignVCenter"
        font.family: "Microsoft YaHei"
        font.pixelSize: 20
        text: ""
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
            id:charge_title_label
            visible: true
            text: "充电方案"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            //anchors.topMargin: 10
            height: 0.1*parent.height
            color: "white"
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignHCenter"
            font.family: "Microsoft YaHei"
            font.pixelSize: 35
        }

        Rectangle{
            id:mode_choose
            visible: true
            height: 0.08*parent.height
            width: 0.4*parent.width
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 10
            anchors.leftMargin: 25

            color: "#00000000"
			
			/*
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: mode_choose.width
                    height: mode_choose.height
                    radius: mode_choose.radius
                }
            }
			*/

            Rectangle{
                id:mode_fee
                visible: true
                width: 0.4*parent.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                color:"#28529C"
                radius: 5
                Label{
                    anchors.fill: parent
                    verticalAlignment: "AlignVCenter"
                    horizontalAlignment: "AlignHCenter"
                    text: "按金额充电"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                    onClicked: {
                        mode1()
                    }
                }
            }

            Rectangle{
                id:mode_time
                visible: true
                width: 0.4*parent.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color:"#28529C"
                radius: 5
                Label{
                    anchors.fill: parent
                    verticalAlignment: "AlignVCenter"
                    horizontalAlignment: "AlignHCenter"
                    text: "按时间充电"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton
                    onClicked: {
                        mode2()
                    }
                }
            }
        }

        Rectangle{
            id:charge_scheme_one
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: parent.left
            anchors.top: charge_title_label.bottom
            anchors.leftMargin: (parent.width-3*width)/4
            anchors.topMargin: 10
            radius: 15
            border.color: "#528ED4"
            border.width: 2
            color: "#00000000"

            Text {
                id: charge_scheme_one_text
                visible: true
                anchors.fill: parent
                text: qsTr("充满自停")
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
                    charge_scheme.choose_scheme=1
                    update_win()
                    if(charge_scheme.fee_flag===1){
                        charge_scheme.choose_fee=0
                    }
                }
            }
        }

        Rectangle{
            id:charge_scheme_two
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: charge_scheme_one.right
            anchors.top: charge_title_label.bottom
            anchors.leftMargin: (parent.width-3*width)/4
            anchors.topMargin: 10
            radius: 15
            border.color: "#528ED4"
            border.width: 2
            color: "#00000000"

            Text {
                id: charge_scheme_two_text
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
                    charge_scheme.choose_scheme=2
                    update_win()
                    if(charge_scheme.fee_flag===1){
                        charge_scheme.choose_fee=60
                    }
                    else{
                        charge_scheme.choose_fee=0
                    }
                }
            }
        }

        Rectangle{
            id:charge_scheme_three
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: charge_scheme_two.right
            anchors.top: charge_title_label.bottom
            anchors.leftMargin: (parent.width-3*width)/4
            anchors.topMargin: 10
            radius: 15
            border.color: "#528ED4"
            border.width: 2
            color: "#00000000"

            Text {
                id: charge_scheme_three_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥50.00")
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
                    charge_scheme.choose_scheme=3
                    update_win()
                    if(charge_scheme.fee_flag===1){
                        charge_scheme.choose_fee=50
                    }
                    else{
                        charge_scheme.choose_fee=0
                    }
                }
            }
        }

        Rectangle{
            id:charge_scheme_four
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: parent.left
            anchors.top: charge_scheme_one.bottom
            anchors.topMargin: 0.1*parent.height
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 2
            color: "#00000000"
            Text {
                id: charge_scheme_four_text
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
                    charge_scheme.choose_scheme=4
                    update_win()
                    if(charge_scheme.fee_flag===1){
                        charge_scheme.choose_fee=40
                    }
                    else{
                        charge_scheme.choose_fee=0
                    }
                }
            }
        }

        Rectangle{
            id:charge_scheme_five
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: charge_scheme_four.right
            anchors.top: charge_scheme_one.bottom
            anchors.topMargin: 0.1*parent.height
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 2
            color: "#00000000"

            Text {
                id: charge_scheme_five_text
                visible: true
                anchors.fill: parent
                text: qsTr("¥30.00")
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
                    charge_scheme.choose_scheme=5
                    update_win()
                    if(charge_scheme.fee_flag===1){
                        charge_scheme.choose_fee=30
                    }
                    else{
                        charge_scheme.choose_fee=0
                    }
                }
            }
        }

        Rectangle{
            id:charge_scheme_six
            visible: true
            width: 0.25*parent.width
            height: 0.35*parent.height
            anchors.left: charge_scheme_five.right
            anchors.top: charge_scheme_one.bottom
            anchors.topMargin: 0.1*parent.height
            anchors.leftMargin: (parent.width-3*width)/4
            radius: 15
            border.color: "#528ED4"
            border.width: 2
            color: "#00000000"

            Text {
                id: charge_scheme_six_text
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
                    charge_scheme.choose_scheme=6
                    update_win()
                    if(charge_scheme.fee_flag===1){
                        charge_scheme.choose_fee=20
                    }
                    else{
                        charge_scheme.choose_fee=0
                    }
                }
            }
        }
    }
}
