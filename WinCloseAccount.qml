import ChargeManage 1.0
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Rectangle{
    id: root
    visible: true
    anchors.fill: parent
    color: "#00000000"

    Image {
        id: background_img
        source: "qrc:/images/wvga/charge/background2.jpg"
        anchors.fill: parent
    }

    property var total_time: 0
    property var actual_time: 0
    property var electricity: 0
    property var charge_fee: 0
    property var service_fee: 0
    property var total_fee: 0

    function init(){
        total_consumption_amount_data.text=""//消费总金额
        charging_charge_data.text=""//充电电费
        charging_service_charge_data.text=""//充电服务费
        actual_charging_duration_data.text=""//实际充电时长
        charge_quantity_data.text=""//充电电量
    }

    function update_actual_time_text(){
        var num=actual_time
        var min=(num/60).toFixed(0)
        var sec=num%60

        var sec_str,min_str;
        if(min*60>num){
            min=min-1
        }
        if(min<10){
            min_str="0%1"
            min_str=min_str.arg(min)
        }
        else{
            min_str="%1"
            min_str=min_str.arg(min)
        }
        if(sec<10){
            sec_str="0%1"
            sec_str=sec_str.arg(sec)
        }
        else{
            sec_str="%1"
            sec_str=sec_str.arg(sec)
        }
        var str="%1:%2"
        str=str.arg(min_str).arg(sec_str)
        actual_charging_duration_data.text=str
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

    onVisibleChanged: {
        if(visible==true){
            init()
            sign_init()
            connect_timer.start()
            actual_time=close_account.actual_time
            electricity=close_account.electricity
            charge_fee=close_account.charge_fee
            service_fee=close_account.service_fee
            total_fee=close_account.total_fee

            update_actual_time_text()

            var str="%1"
            charge_quantity_data.text=str.arg(Number(electricity.toFixed(2)))+"kWh"
            charging_charge_data.text="￥"+str.arg(Number(charge_fee).toFixed(2))
            charging_service_charge_data.text="￥"+str.arg(Number(service_fee).toFixed(2))
            total_consumption_amount_data.text="￥"+str.arg(Number(total_fee).toFixed(2))
        }
        else{
            connect_timer.stop()
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

    Rectangle{
        id:close_account_page_info
        visible: true
        width: 0.7*parent.width
        height: 300
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 0.2*parent.height
        anchors.leftMargin: 0.15*parent.width
        anchors.rightMargin: 0.15*parent.width
        color: "white"
        radius: 25
        border.color: "#8E9BBB"
        border.width: 5

        Rectangle{
            id:close_account_page_btn
            width: 180
            height: 50
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 15
            anchors.leftMargin: (parent.width-width)/2
            anchors.rightMargin: (parent.width-width)/2
            color: "#28529C"
            radius: 5
            Text {
                id: close_account_page_btn_text
                text: qsTr("确   认")
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 35
                color: "white"
            }

            MouseArea{
                id:close_account_page_btn_mouseArea
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: {
                    close_account.visible=false
                    home_screen.visible=true
                }
            }
        }

        Label{
            id:actual_charging_duration_label
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 0.1*parent.width

            Text {
                id: actual_charging_duration_label_text
                visible: true
                anchors.fill: parent
                text: qsTr("充电时长:")
                font.family: "Microsoft YaHei"
                font.pixelSize: 25

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{
            id:actual_charging_duration_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: actual_charging_duration_label.right
            anchors.top: parent.top
            anchors.topMargin: 20
            color: "white"

            Text {
                id: actual_charging_duration_data
                visible: true
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }

        Label{
            id:charge_quantity_label
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.left: actual_charging_duration_text.right
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.leftMargin: 0.1*parent.width

            Text {
                id: charge_quantity_label_text
                visible: true
                anchors.fill: parent
                text: qsTr("充电电量:")
                font.family: "Microsoft YaHei"
                font.pixelSize: 25

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{
            id:charge_quantity_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: charge_quantity_label.right
            anchors.top: parent.top
            anchors.topMargin: 20
            color: "white"

            Text {
                id: charge_quantity_data
                visible: true
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }

        Label{
            id:charging_charge_label
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.left: charge_quantity_text.right
            anchors.top: parent.top
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: charging_charge_label_text
                visible: true
                anchors.fill: parent
                text: qsTr("充电电费:")
                font.family: "Microsoft YaHei"
                font.pixelSize: 25

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{
            id:charging_charge_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: charging_charge_label.right
            anchors.top: parent.top
            anchors.topMargin: 20
            color: "white"

            Text {
                id: charging_charge_data
                visible: true
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }

        Label{
            id:charging_service_charge_label
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.left: parent.left
            anchors.top: charging_charge_text.bottom
            anchors.leftMargin: 0.2*parent.width
            anchors.topMargin: 20

            Text {
                id: charging_service_charge_label_text
                visible: true
                anchors.fill: parent
                text: qsTr("充电服务费:")
                font.family: "Microsoft YaHei"
                font.pixelSize: 25

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{
            id:charging_service_charge_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: charging_service_charge_label.right
            anchors.top: charging_charge_text.bottom
            anchors.topMargin: 20
            color: "white"

            Text {
                id: charging_service_charge_data
                visible: true
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }


        Label{
            id:total_consumption_amount_label
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.left: charging_service_charge_text.right
            anchors.top: charging_charge_text.bottom
            anchors.topMargin: 20
            anchors.leftMargin: 0.2*parent.width

            Text {
                id: total_consumption_amount_label_text
                visible: true
                anchors.fill: parent
                text: qsTr("消费总金额:")
                font.family: "Microsoft YaHei"
                font.pixelSize: 25

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{
            id:total_consumption_amount_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: total_consumption_amount_label.right
            anchors.top: charging_charge_text.bottom
            anchors.topMargin: 20
            color: "white"

            Text {
                id: total_consumption_amount_data
                visible: true
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: ""
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }
    }
}
