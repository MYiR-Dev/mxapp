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
        source: "qrc:/images/wvga/charge/background3.jpg"
        anchors.fill: parent
        visible: true
    }

    property var start_total_electricity: 0
    property var stop_total_electricity: 0
    property var total_electricity: 0
    property var power_factory: 0
    property var voltage: 0
    property var current: 0

    property var total_time: 0
    property var charge_time: 0

    property var charge_fee: 0
    property var service_fee: 0
    property var total_fee: 0
    property var home_amount: 0
    property var amount: 0

    property var charge_btn: false
    property var fee_btn: false
    property var meter_btn: false
    property var start_soc: 0
    property var flag: 0
    property var connect_flag: 0
    property var connect_count_back_flag: 0
    signal closeAccount(var charge_time,var electricity,var charge_fee,var service_fee,var total_fee)

    onVisibleChanged: {
        if(root.visible==true){
            sign_init()
            connect_timer.start()
            if(charge_scheme.choose_scheme>1){
                if(charge_scheme.fee_flag===1){
                    if(charge_scheme.choose_scheme===2){
                        amount=60
                    }
                    else if(charge_scheme.choose_scheme===3){
                        amount=50
                    }
                    else if(charge_scheme.choose_scheme===4){
                        amount=40
                    }
                    else if(charge_scheme.choose_scheme===5){
                        amount=30
                    }
                    else if(charge_scheme.choose_scheme===6){
                        amount=20
                    }
                }

                else if(charge_scheme.time_flag===1){
                    if(charge_scheme.choose_scheme===2){
                        total_time=5*3600
                    }
                    else if(charge_scheme.choose_scheme===3){
                        total_time=4*3600
                    }
                    else if(charge_scheme.choose_scheme===4){
                        total_time=3*3600
                    }
                    else if(charge_scheme.choose_scheme===5){
                        total_time=2*3600
                    }
                    else if(charge_scheme.choose_scheme===6){
                        total_time=1*3600
                    }
                }
            }

            home_amount=home_screen.amount
            if(charge_scheme.quick_flag===1){
                start_total_electricity=charge_manage_c.start_quick_total_electricity
            }
            else{
                start_total_electricity=charge_manage_c.start_slow_total_electricity
            }

            root.start_soc=Math.random(4)+1
            connect_flag=1
            charge_time=0
            connect_count_back_flag=4
            charging_info_timer.start()
            charge_manage()
            update_page_info()
        }
        else{
            connect_timer.stop()
            if(flag==1){
                charging_info_timer.stop()
                stop_total_electricity=charge_manage_c.stop_total_electricity
                home_screen.amount=Number(home_screen.amount)-Number(total_fee)
                closeAccount(charge_time,total_electricity-start_total_electricity,charge_fee,service_fee,total_fee)
            }
            else if(flag==0){
                flag++
            }
        }
    }

    function charge_time_set_text()
    {
        var min=(charge_time/60).toFixed(0)
        var sec=charge_time%60

        var sec_str,min_str
        if(min*60>charge_time){
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
        charge_time_data.text=str;
    }

    function update_page_info(){

        charge_fee=0.9*(total_electricity-start_total_electricity)
        if(charge_scheme.quick_flag===1){
            service_fee=0.2*(total_electricity-start_total_electricity)
        }
        else{
            service_fee=0.1*(total_electricity-start_total_electricity)
        }
        total_fee=service_fee+charge_fee

        if(connect_flag==1){
            charge_state_data.text="正在充电"
            charge_state_data.color="white"
        }
        else{
            charge_state_data.text="连接断开"
            charge_state_data.color="red"
        }
        var num1
        var str1="%1"
        num1=(total_electricity-start_total_electricity)
        charge_electricity_data.text=str1.arg(num1.toFixed(2))+"kWh"

        var num2
        num2=(total_electricity-start_total_electricity+start_soc)/10*100
        soc_data.text=str1.arg(num2.toFixed(2))+"%"

        if(num2<20){
            soc_fill_one.visible=false
            soc_fill_two.visible=false
            soc_fill_three.visible=false
            soc_fill_four.visible=false
            soc_fill_five.visible=false
        }

        else if(num2>=20 && num2<40){
            soc_fill_one.visible=true
            soc_fill_two.visible=false
            soc_fill_three.visible=false
            soc_fill_four.visible=false
            soc_fill_five.visible=false
        }

        else if(num2>=40 && num2<60){
            soc_fill_one.visible=true
            soc_fill_two.visible=true
            soc_fill_three.visible=false
            soc_fill_four.visible=false
            soc_fill_five.visible=false
        }

        else if(num2>=60 && num2<80){
            soc_fill_one.visible=true
            soc_fill_two.visible=true
            soc_fill_three.visible=true
            soc_fill_four.visible=false
            soc_fill_five.visible=false
        }

        else if(num2>=80 && num2<100){
            soc_fill_one.visible=true
            soc_fill_two.visible=true
            soc_fill_three.visible=true
            soc_fill_four.visible=true
            soc_fill_five.visible=false
        }

        else if(num2>=100){
            soc_fill_one.visible=true
            soc_fill_two.visible=true
            soc_fill_three.visible=true
            soc_fill_four.visible=true
            soc_fill_five.visible=true

            charge_monitor.visible=false
            close_account.visible=true
        }

        //充电监控
        if(charge_btn==true){
            page_info_one_data.text=str1.arg(current.toFixed(2))+"A"
            page_info_two_data.text=str1.arg(voltage.toFixed(2))+"V"
            num1=(current*voltage)/1000
            page_info_three_data.text=str1.arg(num1.toFixed(2))+"kW"
        }
        else if(fee_btn==true){
            page_info_one_data.text="0.9元/kWh"
            page_info_two_data.text="¥"+str1.arg(charge_fee.toFixed(2))
            page_info_three_data.text="¥"+str1.arg(total_fee.toFixed(2))
            if(charge_scheme.quick_flag===1)
                page_info_four_data.text="0.2元/kWh"
            else
                page_info_four_data.text="0.1元/kWh"
            page_info_five_data.text="¥"+str1.arg(service_fee.toFixed(2))
        }
        else if(meter_btn==true){
            var num3
            num3=(current*voltage)/1000
            page_info_one_data.text=str1.arg(current.toFixed(2))+"A"
            page_info_two_data.text=str1.arg(voltage.toFixed(2))+"V"
            page_info_three_data.text=str1.arg(num3.toFixed(2))+"kW"
            page_info_four_data.text=str1.arg(power_factory.toFixed(2))
            page_info_five_data.text=str1.arg(total_electricity.toFixed(2))+"kWh"
        }
    }

    //充电管理
    function charge_manage(){
        root.charge_btn=true
        root.fee_btn=false
        root.meter_btn=false
        choose_manage.source="qrc:/images/wvga/charge/delta1.png"

        page_info_one_label.visible=true
        page_info_one_text.visible=true
        page_info_two_label.visible=true
        page_info_two_text.visible=true
        page_info_three_label.visible=true
        page_info_three_text.visible=true
        page_info_four_label.visible=false
        page_info_four_text.visible=false
        page_info_five_label.visible=false
        page_info_five_text.visible=false

        page_info_one_label_text.text="充电电流:"
        page_info_two_label_text.text="充电电压:"
        page_info_three_label_text.text="充电功率:"
        page_info_four_label_text.text="充电功率:"
        page_info_five_label_text.text="充电功率:"

        page_info_one_data.text=""
        page_info_two_data.text=""
        page_info_three_data.text=""
        page_info_four_data.text=""
        page_info_five_data.text=""

        update_page_info()
    }

    //费用管理
    function fee_manage(){
        root.charge_btn=false
        root.fee_btn=true
        root.meter_btn=false
        choose_manage.source="qrc:/images/wvga/charge/delta2.png"

        page_info_one_label.visible=true
        page_info_one_text.visible=true
        page_info_two_label.visible=true
        page_info_two_text.visible=true
        page_info_three_label.visible=true
        page_info_three_text.visible=true
        page_info_four_label.visible=true
        page_info_four_text.visible=true
        page_info_five_label.visible=true
        page_info_five_text.visible=true

        page_info_one_label_text.text="当前电费单价:"
        page_info_two_label_text.text="累计充电电费:"
        page_info_three_label_text.text="累计充电金额:"
        page_info_four_label_text.text="当前服务费单价:"
        page_info_five_label_text.text="累计服务费金额:"

        page_info_one_data.text=""
        page_info_two_data.text=""
        page_info_three_data.text=""
        page_info_four_data.text=""
        page_info_five_data.text=""

        update_page_info()
    }

    //电表管理
    function meter_manage(){
        root.charge_btn=false
        root.fee_btn=false
        root.meter_btn=true
        choose_manage.source="qrc:/images/wvga/charge/delta3.png"

        page_info_one_label.visible=true
        page_info_one_text.visible=true
        page_info_two_label.visible=true
        page_info_two_text.visible=true
        page_info_three_label.visible=true
        page_info_three_text.visible=true
        page_info_four_label.visible=true
        page_info_four_text.visible=true
        page_info_five_label.visible=true
        page_info_five_text.visible=true

        page_info_one_label_text.text="电流:"
        page_info_two_label_text.text="电压:"
        page_info_three_label_text.text="功率:"
        page_info_four_label_text.text="功率因子:"
        page_info_five_label_text.text="总电能:"

        page_info_one_data.text=""
        page_info_two_data.text=""
        page_info_three_data.text=""
        page_info_four_data.text=""
        page_info_five_data.text=""

        update_page_info()
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

    Timer{
        id:charging_info_timer
        running: false
        repeat: true
        triggeredOnStart: true
        interval: 1000
        onTriggered: {
            var num;
            num=charge_manage_c.total_electricity
            if(num>=0 && num>total_electricity){
                total_electricity=num
            }

            num=charge_manage_c.power_factory
            if(num>=0){
                power_factory=num/100
            }

            num=charge_manage_c.voltage
            if(num>=0){
                voltage=num
            }

            num=charge_manage_c.current
            if(num>=0){
                current=num
            }

            if((charge_scheme.time_flag===1 && charge_scheme.choose_scheme>1 && root.charge_time<root.total_time && ((total_electricity-start_total_electricity)*power_factory+start_soc)<10 && total_fee<home_amount) ||
                    (charge_scheme.fee_flag===1 && charge_scheme.choose_scheme>1 && ((total_electricity-start_total_electricity)*power_factory+start_soc)<10 && total_fee<amount && total_fee<home_amount) ||
                    (charge_scheme.choose_scheme===1 && total_fee<home_amount)){
                root.charge_time++
                charge_time_set_text()
                update_page_info()

                if(current==0){
                    connect_count_back_flag--
                    if(connect_count_back_flag==0){
                        connect_flag=0
                        update_page_info()
                    }
                }

                else if(current>0){
                    connect_count_back_flag=4
                    connect_flag=1
                    update_page_info()
                }
            }

            else{
                charge_monitor.visible=false
                close_account.visible=true
            }
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
            id:cancel_btn
            visible: true
            anchors.fill: parent
            text: "结束充电"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 35
            color: "white"
        }
        MouseArea{
            id:cancel_mousearea
            visible: true
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                charge_monitor.visible=false
                close_account.visible=true
            }
        }
    }

    Image {
        source: "qrc:/images/wvga/charge/navigation.png"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: charge_manage_page_btn.left
        anchors.right: charge_manage_page_btn.right
        anchors.topMargin: 0.06*parent.height
        visible: true
    }

    Rectangle{
        id:charge_manage_page_btn
        visible: true
        width: 0.08*parent.width
        anchors.top: current_time_show.bottom
        anchors.bottom: cancel_button.top
        anchors.left: parent.left
        anchors.topMargin: 0.15*parent.height
        anchors.bottomMargin: 15
        anchors.leftMargin: 15
        color: "#00000000"

        //充电监控按钮
        Rectangle{
            id:btn_charge_manage
            visible: true

            height: 1.2*parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: (parent.height-3*btn_charge_manage.height)/4
            color: "#00000000"

            Image {
                id: btn_charge_manage_image
                visible: true
                anchors.fill: parent
                source: "qrc:/images/wvga/charge/charge_manage.png"
            }

            MouseArea{
                id:btn_charge_manage_mousearea
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: charge_manage()
            }
        }
        //费用信息按钮
        Rectangle{
            id:btn_fee_manage
            visible: true

            height: 1.2*parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: btn_charge_manage.bottom
            anchors.topMargin: (parent.height-3*btn_fee_manage.height)/4
            color: "#00000000"

            Image {
                id: btn_fee_manage_image
                visible: true
                anchors.fill: parent
                source: "qrc:/images/wvga/charge/fee_manage.png"
            }

            MouseArea{
                id:btn_fee_manage_mousearea
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: fee_manage()
            }
        }

        //电表信息
        Rectangle{
            id: btn_meter_manage
            visible: true
            height: 1.2*parent.width

            anchors.top: btn_fee_manage.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: (parent.height-3*btn_meter_manage.height)/4
            color: "#00000000"

            Image {
                id: btn_meter_manage_image
                visible: true
                anchors.fill: parent
                source: "qrc:/images/wvga/charge/meter_manage.png"
            }

            MouseArea{
                id:btn_meter_manage_mousearea
                visible: true
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: meter_manage()
            }
        }
    }



    Rectangle{
        id:page_info
        visible: true
        anchors.left: charge_manage_page_btn.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: cancel_button.top

        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 0.15*parent.height
        anchors.bottomMargin: 15
        color: "#00000000"

        Image {
            id: choose_manage
            source: "qrc:/images/wvga/charge/delta1.png"
            anchors.fill: parent
            visible: true
        }


        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: page_info_five_text.bottom
            anchors.left: page_info_five_text.right
            anchors.rightMargin: 0.05*parent.width
            anchors.bottomMargin: 0.05*parent.height
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20
            color: "#00000000"
            border.color: "#71BBF8"
            border.width: 2
            radius: 20

            Label{
                id:charge_state
                visible: true
                width: 0.5*parent.width
                height: 50
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 10
                Text {
                    anchors.fill: parent
                    text: qsTr("充电状态:")
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: "#71BBF8"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                }
            }

            Rectangle{
                id:charge_state_text
                visible: true
                width: 0.5*parent.width
                height: 50
                anchors.left: charge_state.right
                anchors.top: parent.top
                anchors.topMargin: 10
                color: "#00000000"
                Text {
                    id: charge_state_data
                    visible: true
                    anchors.fill: parent
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    font.underline: true
                    color: "white"
                }
            }

            Label{
                id:charge_time_label
                visible: true
                width: 0.5*parent.width
                height: 50
                anchors.left: parent.left
                anchors.top: charge_state.bottom
                anchors.topMargin: 10

                Text {
                    visible: true
                    anchors.fill: parent
                    text: qsTr("充电时间:")
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: "#71BBF8"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                }
            }

            Rectangle{
                id:charge_time_text
                visible: true
                width: 0.5*parent.width
                height: 50
                anchors.left: charge_time_label.right
                anchors.top: charge_state_text.bottom
                anchors.topMargin: 5
                color: "#00000000"
                Text {
                    id: charge_time_data
                    visible: true
                    anchors.fill: parent
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    font.underline: true
                    color: "white"
                }
            }

            Label{
                id:charge_electricity
                visible: true
                width: 0.5*parent.width
                height: 50
                anchors.left: parent.left
                anchors.top: charge_time_label.bottom
                anchors.topMargin: 5
                Text {
                    visible: true
                    anchors.fill: parent
                    text: qsTr("充电电量:")
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: "#71BBF8"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                }
            }

            Rectangle{
                id:charge_electricity_text
                visible: true
                width: 0.5*parent.width
                height: 50
                anchors.left: charge_electricity.right
                anchors.top: charge_time_label.bottom
                anchors.topMargin: 5
                color: "#00000000"
                Text {
                    id:charge_electricity_data
                    visible: true
                    anchors.fill: parent
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    font.underline: true
                    color: "white"
                }
            }
            Rectangle{
                id:soc_icon
                visible: true
                color: "#00000000"
                width: 0.5*parent.width
                height: width
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.top: charge_electricity_text.bottom
                anchors.bottomMargin: 0.02*parent.height
                anchors.topMargin: 0.02*parent.height
                anchors.leftMargin: 0.2*parent.width
                anchors.rightMargin: 0.3*parent.width
                border.color: "#71BBFA"
                border.width: 5
                radius: 10

                /*
                Image {
                    id: soc_icon_image
                    visible: true
                    anchors.fill: parent
                    source: "qrc:/images/wvga/charge/cell.png"
                }
                */

                Rectangle{
                    id:soc_fill_one
                    visible: true
                    color: "#71BBFA"
                    width: (parent.width-40)/5
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    anchors.leftMargin: 10
                    radius: 10
                }

                Rectangle{
                    id:soc_fill_two
                    visible: true
                    color: "#71BBFA"
                    width: (parent.width-40)/5
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: soc_fill_one.right
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    anchors.leftMargin: 5
                    radius: 10
                }

                Rectangle{
                    id:soc_fill_three
                    visible: true
                    color: "#71BBFA"
                    width: (parent.width-40)/5
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: soc_fill_two.right
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    anchors.leftMargin: 5
                    radius: 10
                }


                Rectangle{
                    id:soc_fill_four
                    visible: true
                    color: "#71BBFA"
                    width: (parent.width-40)/5
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: soc_fill_three.right
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    anchors.leftMargin: 5
                    radius: 10
                }


                Rectangle{
                    id:soc_fill_five
                    visible: true
                    color: "#71BBFA"
                    width: (parent.width-40)/5
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: soc_fill_four.right
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    anchors.leftMargin: 5
                    radius: 10
                }
            }

            Rectangle{
                width: 0.05*parent.width+5
                height: 0.3*soc_icon.height
                anchors.left: soc_icon.right
                anchors.leftMargin: -5
                anchors.top: soc_icon.top
                anchors.topMargin: 0.35*soc_icon.height
                color: "#71BBF8"
                radius: 5
            }
        }

        Label{
            id:soc_label
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: soc_label_text
                visible: true
                anchors.fill: parent
                anchors.leftMargin: 5
                text: "当前电池电量为:"
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "#71BBF8"
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
            }
        }

        Rectangle{
            id:soc_text
            visible: true
            height: 50
            width: 0.1*parent.width
            anchors.top: parent.top
            anchors.left: soc_label.right
            anchors.topMargin: 20
            color: "#00000000"
            Text {
                id: soc_data
                text: ""
                anchors.fill: parent
                color: "white"
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }



        Label{
            id:page_info_one_label
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: parent.left
            anchors.top: soc_label.bottom
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: page_info_one_label_text
                visible: true
                anchors.fill: parent
                text: ""
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "#71BBF8"
                font.family: "Microoft YaHei"
                font.pixelSize: 25
            }
        }

        Rectangle{
            id:page_info_one_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_one_label.right
            anchors.top: soc_label.bottom
            anchors.topMargin: 20
            color: "#00000000"
            Text {
                id: page_info_one_data
                visible: true
                anchors.fill: parent
                text: ""
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }


        Label{
            id:page_info_two_label
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_one_text.right
            anchors.top: soc_label.bottom
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: page_info_two_label_text
                visible: true
                anchors.fill: parent
                text: ""
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "#71BBF8"
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
            }
        }

        Rectangle{
            id:page_info_two_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_two_label.right
            anchors.top: soc_label.bottom
            anchors.topMargin: 20
            color: "#00000000"
            Text {
                id: page_info_two_data
                visible: true
                anchors.fill: parent
                text: ""
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }


        Label{
            id:page_info_three_label
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_two_text.right
            anchors.top: soc_label.bottom
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: page_info_three_label_text
                visible: true
                anchors.fill: parent
                text: ""
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "#71BBF8"
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
            }
        }

        Rectangle{
            id:page_info_three_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_three_label.right
            anchors.top: soc_label.bottom
            anchors.topMargin: 20
            color: "#00000000"
            Text {
                id: page_info_three_data
                visible: true
                anchors.fill: parent
                text: ""
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }


        Label{
            id:page_info_four_label
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: parent.left
            anchors.top: page_info_one_label.bottom
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: page_info_four_label_text
                visible: true
                anchors.fill: parent
                text: ""
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "#71BBF8"
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
            }
        }

        Rectangle{
            id:page_info_four_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_four_label.right
            anchors.top: page_info_one_label.bottom
            anchors.topMargin: 20
            color: "#00000000"
            Text {
                id: page_info_four_data
                visible: true
                anchors.fill: parent
                text: ""
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }

        Label{
            id:page_info_five_label
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_four_text.right
            anchors.top: page_info_one_label.bottom
            anchors.leftMargin: 0.1*parent.width
            anchors.topMargin: 20

            Text {
                id: page_info_five_label_text
                visible: true
                anchors.fill: parent
                text: ""
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: "#71BBF8"
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
            }
        }

        Rectangle{
            id:page_info_five_text
            visible: true
            width: 0.1*parent.width
            height: 50
            anchors.left: page_info_five_label.right
            anchors.top: page_info_one_label.bottom
            anchors.topMargin: 20
            color: "#00000000"
            Text {
                id: page_info_five_data
                visible: true
                anchors.fill: parent
                text: ""
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Microsoft YaHei"
                font.pixelSize: 25
                font.underline: true
            }
        }
    }
}
