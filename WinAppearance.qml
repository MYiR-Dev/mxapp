import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.3


Popup {
    id: appearance_Wd
    modal: false
    padding: 0
    margins: 0
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: mainWnd.width
    height: mainWnd.height

    Image {
        anchors.fill: parent
        visible: true
        source: "images/wvga/home/background-dark.png"
    }

    property var mode:1

    property var boom_angle: 30//大臂角度
    property var jib_angle: 30//小臂角度
    property var bucket_angle: 30//铲斗角度
    property var cab_angle: 0//驾驶室角度
    property var excavator_height: 2.50//挖机高度
    property var excavator_width: 4.33//挖机宽度

    property real total_consumption: 0//总油耗
    property real total_pumping_consumption: 0//累计泵送油耗
    property real total_boom_consumption: 0//累计臂架油耗
    property real total_idle_consumption: 0//累计怠速油耗
    property real pumping_consumption: 0//本次泵送油耗
    property real boom_consumption: 0//本次臂架油耗
    property real idle_consumption: 0//本次怠速油耗
    property real total_boom_angle: (total_boom_consumption===0 && total_pumping_consumption===0 && total_idle_consumption===0) ? 120 : total_boom_consumption/(total_boom_consumption+total_pumping_consumption+total_idle_consumption)*360
    property real total_pumping_angle: (total_boom_consumption===0 && total_pumping_consumption===0 && total_idle_consumption===0) ? 120 : (total_pumping_consumption)/(total_boom_consumption+total_pumping_consumption+total_idle_consumption)*360
    property real total_idle_angle: (total_boom_consumption===0 && total_pumping_consumption===0 && total_idle_consumption===0) ? 120 : (total_idle_consumption)/(total_boom_consumption+total_pumping_consumption+total_idle_consumption)*360
    property real actual_boom_angle: (boom_consumption===0 && pumping_consumption===0 && idle_consumption===0) ? 120 : boom_consumption/(boom_consumption+pumping_consumption+idle_consumption)*360
    property real actual_pumping_angle: (boom_consumption===0 && pumping_consumption===0 && idle_consumption===0) ? 120 : (pumping_consumption)/(boom_consumption+pumping_consumption+idle_consumption)*360
    property real actual_idle_angle: (boom_consumption===0 && pumping_consumption===0 && idle_consumption===0) ? 120 : (idle_consumption)/(boom_consumption+pumping_consumption+idle_consumption)*360

    property var fault_boom_num: 0//臂架故障次数
    property var fault_chassis_num: 0//底盘故障次数
    property var fault_pumping_num: 0//泵送故障次数

    onTotal_boom_angleChanged:{
        if(analy_consumption.visible===true)
            mode2()
        pie_total.requestPaint()
    }
    onTotal_pumping_angleChanged: {
        if(analy_consumption.visible===true)
            mode2()
        pie_total.requestPaint()
    }
    onTotal_idle_angleChanged: {
        if(analy_consumption.visible===true)
            mode2()
        pie_total.requestPaint()
    }

    onActual_boom_angleChanged: {
        if(analy_consumption.visible===true)
            mode2()
        pie_actual.requestPaint()
    }
    onActual_pumping_angleChanged: {
        if(analy_consumption.visible===true)
            mode2()
        pie_actual.requestPaint()
    }
    onActual_idle_angleChanged: {
        if(analy_consumption.visible===true)
            mode2()
        pie_actual.requestPaint()
    }

    onVisibleChanged: {
        if(visible===true){
            pumping_consumption=0
            boom_consumption=0
            idle_consumption=0

            mode=1
            choose_mode()
        }
    }

    function paintPer(ctx,x,y, r, startAngle,endAngle,color) {
        ctx.fillStyle = color
        ctx.save();         //ctx.save() 和 ctx.restore(); 搭配使用是清除画板的
        ctx.beginPath();
        ctx.moveTo(x,y);
        ctx.arc(x,y,r,startAngle*Math.PI/180, endAngle*Math.PI/180);
        ctx.closePath();
        ctx.fill()
        ctx.restore();
    }

    function choose_mode(){
        if(mode===1){
            page_main_right_img.source="images/wvga/appearance/delta1.png"
            mode1()
        }
        else if(mode===2){
            page_main_right_img.source="images/wvga/appearance/delta2.png"
            mode2()
        }
        else if(mode===3){
            page_main_right_img.source="images/wvga/appearance/delta3.png"
            mode3()
        }
    }


    function mode1(){
        analy_consumption.visible=false
        remote_control.visible=true
        fault_record.visible=false

        boom_data.text=boom_angle.toString()+"°"
        jib_data.text=jib_angle.toString()+"°"
        bucket_data.text=bucket_angle.toString()+"°"
        cab_data.text=cab_angle.toString()+"°"
        height_data.text=(5*Math.sin(boom_angle/180*Math.PI)).toFixed(2).toString()+"m"

        var width=5*Math.cos(boom_angle/180*Math.PI)
        if(jib_angle>90-boom_angle){
            width=width+5*Math.sin((jib_angle-90+boom_angle)/180*Math.PI)
        }
        width_data.text=width.toFixed(2).toString()+"m"
    }

    function mode2(){
        analy_consumption.visible=true
        remote_control.visible=false
        fault_record.visible=false
        total_oli_data.text=total_consumption.toFixed(2)+"L"
        total_boom_consumption_section_legend_data.text=total_boom_consumption.toFixed(2)+"L"
        total_idle_consumption_section_legend_data.text=total_idle_consumption.toFixed(2)+"L"
        total_pumping_consumption_section_legend_data.text=total_pumping_consumption.toFixed(2)+"L"
        boom_consumption_section_legend_data.text=boom_consumption.toFixed(2)+"L"
        idle_consumption_section_legend_data.text=idle_consumption.toFixed(2)+"L"
        pumping_consumption_section_legend_data.text=pumping_consumption.toFixed(2)+"L"
    }

    function mode3(){
        analy_consumption.visible=false
        remote_control.visible=false
        fault_record.visible=true

        var date=new Date()
        if(year_combox.currentText===date.getFullYear().toString() && month_combox.currentIndex > date.getMonth()){
            fault_boom_num=0
            fault_chassis_num=0
            fault_pumping_num=0
        }
        else{
            fault_boom_num=10-year_combox.currentIndex+12-month_combox.currentIndex-5
            fault_chassis_num=10-year_combox.currentIndex+12-month_combox.currentIndex-6
            fault_pumping_num=10-year_combox.currentIndex+12-month_combox.currentIndex-8

            if(fault_boom_num<=0)
                fault_boom_num=0
            if(fault_chassis_num<=0)
                fault_chassis_num=0
            if(fault_pumping_num<=0)
                fault_pumping_num=0
        }

        bar_boom.height=(fault_boom_num/20)*boom_fault_num.height
        bar_chassis.height=(fault_chassis_num/20)*chassis_fault_num.height
        bar_pumping.height=(fault_pumping_num/20)*pumping_fault_num.height
        num_boom.text=fault_boom_num.toString()
        num_chassis.text=fault_chassis_num.toString()
        num_pumping.text=fault_pumping_num.toString()
    }

    TitleRightBar{
        id:page_top
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
            appearance_Wd.close()
        }
    }

    Rectangle{
        id:page_main
        anchors.top: page_top.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 30
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        color: "#00000000"

        Rectangle{
            id:page_main_left
            width: 0.1*parent.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: "#00000000"

            Rectangle{
                id:remote_control_option
                width: parent.width
                height: parent.width+30
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: (parent.height-3*height)/4
                radius: 10
                border.width: 3
                border.color: "black"

                Image {
                    id:remote_control_option_img
                    width: parent.width
                    height: width
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: true
                    source: "images/wvga/appearance/RemoteControl.png"
                }

                Text {
                    text: "机械遥控"
                    visible: true
                    anchors.top: remote_control_option_img.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        mode=1
                        choose_mode()
                    }
                }
            }

            Rectangle{
                id:oli_consumption_option
                width: parent.width
                height: parent.width+30
                anchors.top: remote_control_option.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: (parent.height-3*height)/4
                radius: 10
                border.width: 3
                border.color: "black"

                Image {
                    id:oli_consumption_option_img
                    width: parent.width
                    height: width
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: true
                    source: "images/wvga/appearance/OilConsumption.png"
                }

                Text {
                    text: "油耗分析"
                    visible: true
                    anchors.top: oli_consumption_option_img.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        mode=2
                        choose_mode()
                    }
                }
            }

            Rectangle{
                id: data_option
                width: parent.width
                height: parent.width+30
                anchors.top: oli_consumption_option.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: (parent.height-3*height)/4
                radius: 10
                border.width: 3
                border.color: "black"

                Image {
                    id:data_option_img
                    width: parent.width
                    height: width
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: true
                    source: "images/wvga/appearance/Fault.png"
                }

                Text {
                    text: "故障查询"
                    visible: true
                    anchors.top: data_option_img.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 25
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        mode=3
                        choose_mode()
                    }
                }
            }
        }

        Rectangle{
            id:page_main_right
            anchors.top: parent.top
            anchors.left: page_main_left.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            color: "#00000000"
            Image {
                id: page_main_right_img
                visible: true
                anchors.fill: parent
                source: "images/wvga/appearance/delta1.png"
            }

            //遥控器监控
            Rectangle{
                id:remote_control
                anchors.fill: parent
                anchors.leftMargin: 0.025*parent.width
                color: "#00000000"

                //操作按钮表格部分
                Rectangle{
                    id:control_section
                    visible: true
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 10
                    height: 0.3*parent.height
                    color: "#00000000"

                    //操作大臂
                    Rectangle{
                        id:control_boom
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: parent.width/4
                        border.width: 4
                        border.color: "white"
                        color: "#00000000"
                        Rectangle{
                            anchors.fill: parent
                            anchors.bottomMargin: parent.height/3*2
                            color: "#00000000"
                            border.width: 4
                            border.color: "white"

                            Text{
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "大臂"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "white"
                            }
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: parent.width/3
                            anchors.rightMargin: parent.width/3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: parent.height/3
                            anchors.bottomMargin: parent.height/3
                            color: "#00000000"
                            Image {
                                id:boom_up_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Up.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    boom_up_img.source="images/wvga/appearance/up_press.png"
                                }

                                onReleased: {
                                    boom_up_img.source="images/wvga/appearance/Up.png"
                                }

                                onClicked: {
                                    if(boom_angle+10>=90){
                                        boom_angle=90
                                    }
                                    else{
                                        boom_angle=boom_angle+10
                                    }
                                    total_consumption+=0.02
                                    total_pumping_consumption+=0.01
                                    total_boom_consumption+=0.01

                                    pumping_consumption+=0.01
                                    boom_consumption+=0.01
                                    mode1()
                                }
                            }
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: parent.width/3
                            anchors.rightMargin: parent.width/3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: parent.height/3*2
                            color: "#00000000"
                            Image {
                                id:boom_down_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Down.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    boom_down_img.source="images/wvga/appearance/down_press.png"
                                }

                                onReleased: {
                                    boom_down_img.source="images/wvga/appearance/Down.png"
                                }

                                onClicked: {
                                    if(boom_angle-10<=30){
                                        boom_angle=30
                                    }
                                    else{
                                        boom_angle=boom_angle-10
                                    }
                                    total_consumption+=0.02
                                    total_pumping_consumption+=0.01
                                    total_boom_consumption+=0.01

                                    pumping_consumption+=0.01
                                    boom_consumption+=0.01
                                    mode1()
                                }
                            }
                        }
                    }

                    //操作小臂
                    Rectangle{
                        id:control_jib
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: control_boom.right
                        anchors.leftMargin: -4
                        width: parent.width/4
                        border.width: 4
                        border.color: "white"
                        color: "#00000000"

                        Rectangle{
                            anchors.fill: parent
                            anchors.bottomMargin: parent.height/3*2
                            color: "#00000000"
                            border.width: 4
                            border.color: "white"

                            Text{
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "小臂"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "white"
                            }
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: parent.width/3
                            anchors.rightMargin: parent.width/3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: parent.height/3
                            anchors.bottomMargin: parent.height/3
                            color: "#00000000"
                            Image {
                                id:jib_up_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Up.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    jib_up_img.source="images/wvga/appearance/up_press.png"
                                }

                                onReleased: {
                                    jib_up_img.source="images/wvga/appearance/Up.png"
                                }

                                onClicked: {
                                    if(jib_angle+10>=90){
                                        jib_angle=90
                                    }
                                    else{
                                        jib_angle=jib_angle+10
                                    }
                                    total_consumption+=0.01
                                    total_pumping_consumption+=0.005
                                    total_boom_consumption+=0.005

                                    pumping_consumption+=0.005
                                    boom_consumption+=0.005
                                    mode1()
                                }
                            }
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: parent.width/3
                            anchors.rightMargin: parent.width/3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: parent.height/3*2
                            color: "#00000000"
                            Image {
                                id:jib_down_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Down.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    jib_down_img.source="images/wvga/appearance/down_press.png"
                                }

                                onReleased: {
                                    jib_down_img.source="images/wvga/appearance/Down.png"
                                }

                                onClicked: {
                                    if(jib_angle-10<=30){
                                        jib_angle=30
                                    }
                                    else{
                                        jib_angle=jib_angle-10
                                    }
                                    total_consumption+=0.01
                                    total_pumping_consumption+=0.005
                                    total_boom_consumption+=0.005

                                    pumping_consumption+=0.005
                                    boom_consumption+=0.005
                                    mode1()
                                }
                            }
                        }
                    }

                    //操作铲斗
                    Rectangle{
                        id:control_bucket
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: control_jib.right
                        anchors.leftMargin: -4
                        width: parent.width/4
                        border.width: 4
                        border.color: "white"
                        color: "#00000000"

                        Rectangle{
                            anchors.fill: parent
                            anchors.bottomMargin: parent.height/3*2
                            color: "#00000000"
                            border.width: 4
                            border.color: "white"

                            Text{
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "铲斗"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "white"
                            }
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: parent.width/3
                            anchors.rightMargin: parent.width/3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: parent.height/3
                            anchors.bottomMargin: parent.height/3
                            color: "#00000000"
                            Image {
                                id:bucket_up_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Up.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    bucket_up_img.source="images/wvga/appearance/up_press.png"
                                }

                                onReleased: {
                                    bucket_up_img.source="images/wvga/appearance/Up.png"
                                }

                                onClicked: {
                                    if(bucket_angle+10>=90){
                                        bucket_angle=90
                                    }
                                    else{
                                        bucket_angle=bucket_angle+10
                                    }
                                    total_consumption+=0.006
                                    total_pumping_consumption+=0.003
                                    total_boom_consumption+=0.003

                                    pumping_consumption+=0.003
                                    boom_consumption+=0.003
                                    mode1()
                                }
                            }
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: parent.width/3
                            anchors.rightMargin: parent.width/3
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: parent.height/3*2
                            color: "#00000000"
                            Image {
                                id:bucket_down_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Down.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    bucket_down_img.source="images/wvga/appearance/down_press.png"
                                }

                                onReleased: {
                                    bucket_down_img.source="images/wvga/appearance/Down.png"
                                }

                                onClicked: {
                                    if(bucket_angle-10<=30){
                                        bucket_angle=30
                                    }
                                    else{
                                        bucket_angle=bucket_angle-10
                                    }
                                    total_consumption+=0.006
                                    total_pumping_consumption+=0.003
                                    total_boom_consumption+=0.003

                                    pumping_consumption+=0.003
                                    boom_consumption+=0.003
                                    mode1()
                                }
                            }
                        }
                    }

                    //操作驾驶室
                    Rectangle{
                        id:control_cab
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: control_bucket.right
                        anchors.right: parent.right
                        anchors.leftMargin: -4
                        width: parent.width/4
                        border.width: 4
                        border.color: "white"
                        color: "#00000000"

                        Rectangle{
                            anchors.fill: parent
                            anchors.bottomMargin: parent.height/3*2
                            color: "#00000000"
                            border.width: 4
                            border.color: "white"

                            Text{
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "驾驶室"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "white"
                            }
                        }

                        Rectangle{
                            height: parent.width/3
                            width: parent.height/3
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.topMargin: parent.height/3+(parent.height/3*2-height)/2
                            anchors.leftMargin: (parent.width-(parent.height-width))/2
                            color: "#00000000"
                            Image {
                                id:hand_left_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Left.png"
                            }

                            MouseArea{
                                id:left_btn
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    hand_left_img.source="images/wvga/appearance/left_press.png"
                                }

                                onReleased: {
                                    hand_left_img.source="images/wvga/appearance/Left.png"
                                }

                                onClicked: {
                                    if(hand.rotation-10<=-180){
                                        hand.rotation=-180
                                        cab_angle=-180
                                    }
                                    else{
                                        hand.rotation=hand.rotation-10
                                        cab_angle=cab_angle-10
                                    }
                                    total_consumption+=0.02
                                    total_pumping_consumption+=0.01
                                    total_idle_consumption+=0.01

                                    pumping_consumption+=0.01
                                    idle_consumption+=0.01
                                    mode1()
                                }
                            }
                        }

                        Rectangle{
                            height: parent.width/3
                            width: parent.height/3
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: parent.height/3+(parent.height/3*2-height)/2
                            anchors.rightMargin: (parent.width-(parent.height-width))/2
                            color: "#00000000"
                            Image {
                                id:hand_rignt_img
                                anchors.fill: parent
                                source: "images/wvga/appearance/Right.png"
                            }

                            MouseArea{
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onPressed: {
                                    hand_rignt_img.source="images/wvga/appearance/right_press.png"
                                }
                                onReleased: {
                                    hand_rignt_img.source="images/wvga/appearance/Right.png"
                                }

                                onClicked: {
                                    if(hand.rotation+10>=180){
                                        hand.rotation=180
                                        cab_angle=180
                                    }
                                    else{
                                        hand.rotation=hand.rotation+10
                                        cab_angle=cab_angle+10
                                    }
                                    total_consumption+=0.02
                                    total_pumping_consumption+=0.01
                                    total_idle_consumption+=0.01

                                    pumping_consumption+=0.01
                                    idle_consumption+=0.01
                                    mode1()
                                }
                            }
                        }
                    }
                }

                //显示挖机宽度、高度、机械臂角度等信息
                Rectangle{
                    id:control_info
                    anchors.top: parent.top
                    anchors.bottom: control_section.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.leftMargin: 10
                    anchors.bottomMargin: 10
                    width: 0.5*parent.width-15
                    color: "#00000000"

                    //大臂角度
                    Rectangle{
                        id:table_boom
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height/6
                        color: "#00000000"
                        border.width: 2
                        border.color: "white"

                        Rectangle{
                            id:boom_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 0.5*parent.width
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                text: qsTr("大臂角度")
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:boom_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: boom_title.right
                            anchors.right: parent.right
                            color: "#00000000"
                            anchors.leftMargin: -2
                            border.width: 2
                            border.color: "white"

                            Text {
                                id: boom_data
                                text: boom_angle.toString()+"°"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }
                    }

                    //小臂角度
                    Rectangle{
                        id:table_jib
                        anchors.top: table_boom.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        height: parent.height/6
                        color: "#00000000"
                        border.width: 2
                        border.color: "white"

                        Rectangle{
                            id:jib_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 0.5*parent.width
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                text: qsTr("小臂角度")
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:jib_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: jib_title.right
                            anchors.right: parent.right
                            anchors.leftMargin: -2
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                id: jib_data
                                text: jib_angle.toString()+"°"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }
                    }

                    //铲斗角度
                    Rectangle{
                        id:table_bucket
                        anchors.top: table_jib.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height/6
                        anchors.topMargin: -2
                        color: "#00000000"
                        border.width: 2
                        border.color: "white"

                        Rectangle{
                            id:bucket_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 0.5*parent.width
                            border.width: 2
                            border.color: "white"
                            color: "#00000000"

                            Text {
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                text: qsTr("铲斗角度")
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:bucket_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: bucket_title.right
                            anchors.right: parent.right
                            anchors.leftMargin: -2
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                id: bucket_data
                                text: bucket_angle.toString()+"°"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }
                    }

                    //驾驶室角度
                    Rectangle{
                        id:table_cab
                        anchors.top: table_bucket.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        height: parent.height/6
                        color: "#00000000"
                        border.width: 2
                        border.color: "white"

                        Rectangle{
                            id:cab_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 0.5*parent.width
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                text: qsTr("驾驶室角度")
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:cab_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: cab_title.right
                            anchors.right: parent.right
                            anchors.leftMargin: -2
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                id: cab_data
                                text: cab_angle.toString()+"°"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }
                    }

                    //当前高度
                    Rectangle{
                        id:table_height
                        anchors.top: table_cab.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        height: parent.height/6
                        color: "#00000000"
                        border.width: 2
                        border.color: "white"

                        Rectangle{
                            id:height_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 0.5*parent.width
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                text: qsTr("挖机高度")
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:height_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: height_title.right
                            anchors.right: parent.right
                            anchors.leftMargin: -2
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                id: height_data
                                text: excavator_height.toString()+"m"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }
                    }

                    //当前宽度
                    Rectangle{
                        id:table_width
                        anchors.top: table_height.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        height: parent.height/6
                        color: "#00000000"
                        border.width: 2
                        border.color: "white"

                        Rectangle{
                            id:width_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: 0.5*parent.width
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                text: qsTr("挖机宽度")
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:width_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: width_title.right
                            anchors.right: parent.right
                            anchors.leftMargin: -2
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"

                            Text {
                                id: width_data
                                text: excavator_width.toString()+"m"
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }
                        }
                    }
                }
                //显示挖机驾驶室旋转角度
                Rectangle{
                    id:control_revole
                    anchors.top: parent.top
                    anchors.bottom: control_section.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 10
                    width: 0.5*parent.width-15
                    color: "#00000000"

                    Rectangle{
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: parent.width>parent.height ? parent.height : parent.width
                        height: width
                        anchors.leftMargin: (parent.width-width)/2
                        anchors.topMargin: (parent.height-height)/2
                        color: "#00000000"

                        Text {
                            anchors.top: parent.top
                            anchors.bottom: outer_circle.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("车头")
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            color: "white"
                        }

                        Text {
                            anchors.top: outer_circle.bottom
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("车尾")
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            color: "white"
                        }

                        Text {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: outer_circle.left
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("左")
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            color: "white"
                        }

                        Text {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: outer_circle.right
                            anchors.right: parent.right
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("右")
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            color: "white"
                        }

                        Rectangle{
                            id:outer_circle
                            width: 0.8*parent.width
                            height: width
                            anchors.centerIn: parent
                            color: "#00000000"
                            border.width: 2
                            border.color: "white"
                            radius: width/2

                            Rectangle{
                                height: 2
                                color: "white"
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.topMargin: parent.height/2-1
                            }

                            Rectangle{
                                width: 2
                                color: "white"
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.leftMargin: parent.width/2-1
                            }

                            Rectangle{
                                id:hand
                                width: 5
                                height: parent.height
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.leftMargin: parent.width/2-1
                                color: "#00000000"
                                visible: true
                                rotation: 0

                                Rectangle{
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: parent.height/2
                                    color: "green"
                                }
                            }
                        }

                        Rectangle{
                            color: "#00000000"
                            width: 0.6*parent.width
                            height: width
                            anchors.centerIn: parent
                            border.width: 2
                            border.color: "white"
                            radius: width/2
                        }

                        Rectangle{
                            color: "#00000000"
                            width: 0.4*parent.width
                            height: width
                            anchors.centerIn: parent
                            border.width: 2
                            border.color: "white"
                            radius: width/2
                        }

                        Rectangle{
                            color: "#00000000"
                            width: 0.2*parent.width
                            height: width
                            anchors.centerIn: parent
                            border.width: 2
                            border.color: "white"
                            radius: width/2
                        }
                    }
                }
            }

            //油耗分析
            Rectangle{
                id:analy_consumption
                anchors.fill: parent
                anchors.leftMargin: 0.025*parent.width
                color: "#00000000"
                visible: false

                Rectangle{
                    id:total_oli
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 0.02*parent.width
                    width: 100
                    height: 50
                    color: "#00000000"
                    Text {
                        text: "总油耗:"
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 30
                        color: "white"
                    }
                }

                Rectangle{
                    anchors.top: parent.top
                    anchors.left: total_oli.right
                    height: 50
                    width: 100
                    anchors.leftMargin: 5
                    color: "#00000000"
                    Text {
                        id: total_oli_data
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 30
                        color: "green"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("")
                    }
                }

                Rectangle{
                    id:analy_consumption_left
                    width: 0.5*parent.width
                    anchors.left: parent.left
                    anchors.top: total_oli.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    color: "#00000000"

                    Rectangle{
                        id:analy_consumption_left_title
                        anchors.top:parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 50
                        color: "#00000000"

                        Text {
                            anchors.fill: parent
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 35
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("累计油耗")
                            color: "white"
                        }
                    }

                    Rectangle{
                        id:analy_consumption_left_pie
                        anchors.top: analy_consumption_left_title.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 30
                        width: 0.6*parent.width
                        height: 0.6*parent.width
                        anchors.leftMargin: (parent.width-width)/2
                        anchors.rightMargin: (parent.width-width)/2
                        color: "#00000000"

                        Canvas{
                            id:pie_total
                            width: parent.width > parent.height ? parent.height : parent.width
                            height: width
                            anchors.margins: 30
                            anchors.centerIn: parent
                            contextType:  "2d";
                            onPaint: {
                                var ctx = getContext("2d"); //画师
                                paintPer(ctx,0.5*width, 0.5*width, 0.5*width,0,total_boom_angle,"red")
                                paintPer(ctx,0.5*width, 0.5*width, 0.5*width,total_boom_angle,total_boom_angle+total_pumping_angle,"blue")
                                paintPer(ctx,0.5*width, 0.5*width, 0.5*width,total_boom_angle+total_pumping_angle,360,"yellow")
                                paintPer(ctx,0.5*width, 0.5*width, 0.3*width,0,360,"white")
                            }
                        }
                    }


                    //累计泵送油耗图例
                    Rectangle{
                        id:total_pumping_consumption_section_legend
                        anchors.top:analy_consumption_left_pie.bottom
                        anchors.left: analy_consumption_left.left
                        anchors.right: analy_consumption_left.right
                        anchors.leftMargin: 0.25*analy_consumption_left.width
                        anchors.rightMargin: 0.25*analy_consumption_left.width
                        anchors.topMargin: 30
                        height: 30
                        color: "#00000000"

                        Rectangle{
                            id:total_pumping_consumption_section_legend_img
                            height: parent.height-10
                            width: height
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            color: "blue"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            radius: 5
                        }

                        Rectangle{
                            id:total_pumping_consumption_section_legend_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left:total_pumping_consumption_section_legend_img.right
                            anchors.right:parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 80
                            color: "#00000000"

                            Text {
                                anchors.fill: parent
                                text: qsTr("累计泵送油耗:")
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:total_pumping_consumption_section_legend_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: total_pumping_consumption_section_legend_title.right
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            color: "#00000000"

                            Text {
                                id: total_pumping_consumption_section_legend_data
                                anchors.fill: parent
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "green"
                                text: qsTr("0.0L")
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }


                    //累计臂架油耗图例
                    Rectangle{
                        id:total_boom_consumption_section_legend
                        anchors.top:total_pumping_consumption_section_legend.bottom
                        anchors.left: analy_consumption_left.left
                        anchors.right: analy_consumption_left.right
                        anchors.leftMargin: 0.25*analy_consumption_left.width
                        anchors.rightMargin: 0.25*analy_consumption_left.width
                        anchors.topMargin: 5
                        color: "#00000000"
                        height: 30

                        Rectangle{
                            id:total_boom_consumption_section_legend_img
                            height: parent.height-10
                            width: height
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            color: "red"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            radius: 5
                        }

                        Rectangle{
                            id:total_boom_consumption_section_legend_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left:total_boom_consumption_section_legend_img.right
                            anchors.right:parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 80
                            color: "#00000000"

                            Text {
                                anchors.fill: parent
                                text: qsTr("累计臂架油耗:")
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:total_boom_consumption_section_legend_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: total_boom_consumption_section_legend_title.right
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            color: "#00000000"

                            Text {
                                id: total_boom_consumption_section_legend_data
                                anchors.fill: parent
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "green"
                                text: qsTr("0.0L")
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    //累计怠速油耗
                    Rectangle{
                        id:total_idle_consumption_section_legend
                        anchors.top:total_boom_consumption_section_legend.bottom
                        anchors.left: analy_consumption_left.left
                        anchors.right: analy_consumption_left.right
                        anchors.leftMargin: 0.25*analy_consumption_left.width
                        anchors.rightMargin: 0.25*analy_consumption_left.width
                        anchors.topMargin: 5
                        height: 30
                        color: "#00000000"

                        Rectangle{
                            id:total_idle_consumption_section_legend_img
                            height: parent.height-10
                            width: height
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            color: "yellow"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            radius: 5
                        }

                        Rectangle{
                            id:total_idle_consumption_section_legend_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left:total_idle_consumption_section_legend_img.right
                            anchors.right:parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 80
                            color: "#00000000"

                            Text {
                                anchors.fill: parent
                                text: qsTr("累计怠速油耗:")
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:total_idle_consumption_section_legend_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: total_idle_consumption_section_legend_title.right
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            color: "#00000000"

                            Text {
                                id: total_idle_consumption_section_legend_data
                                anchors.fill: parent
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "green"
                                text: qsTr("0.0L")
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }



                Rectangle{
                    id:analy_consumption_right
                    width: 0.5*parent.width
                    height: width
                    anchors.right: parent.right
                    anchors.top: total_oli.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    color: "#00000000"

                    Rectangle{
                        id:analy_consumption_right_title
                        anchors.top:parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 50
                        color: "#00000000"

                        Text {
                            anchors.fill: parent
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 35
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("实时油耗")
                            color: "white"
                        }
                    }

                    Rectangle{
                        id:analy_consumption_right_pie
                        anchors.top: analy_consumption_right_title.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 30
                        width: 0.6*parent.width
                        height: 0.6*parent.width
                        anchors.leftMargin: (parent.width-width)/2
                        anchors.rightMargin: (parent.width-width)/2
                        color: "#00000000"
                        Canvas{
                            id:pie_actual
                            width: parent.width > parent.height ? parent.height : parent.width
                            height: width
                            anchors.margins: 60
                            anchors.centerIn: parent
                            contextType:  "2d";

                            onPaint: {
                                var ctx = getContext("2d"); //画师
                                paintPer(ctx,0.5*width, 0.5*width, 0.5*width,0,actual_boom_angle,"red")
                                paintPer(ctx,0.5*width, 0.5*width, 0.5*width,actual_boom_angle,actual_boom_angle+actual_pumping_angle,"blue")
                                paintPer(ctx,0.5*width, 0.5*width, 0.5*width,actual_boom_angle+actual_pumping_angle,360,"yellow")
                                paintPer(ctx,0.5*width, 0.5*width, 0.3*width,0,360,"white")
                            }
                        }
                    }

                    //本次泵送油耗图例
                    Rectangle{
                        id:pumping_consumption_section_legend
                        anchors.top:analy_consumption_right_pie.bottom
                        anchors.left: analy_consumption_right.left
                        anchors.right: analy_consumption_right.right
                        anchors.leftMargin: 0.25*analy_consumption_right.width
                        anchors.rightMargin: 0.25*analy_consumption_right.width
                        anchors.topMargin: 30
                        height: 30
                        color: "#00000000"

                        Rectangle{
                            id:pumping_consumption_section_legend_img
                            height: parent.height-10
                            width: height
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            color: "blue"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            radius: 5
                        }

                        Rectangle{
                            id:pumping_consumption_section_legend_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left:pumping_consumption_section_legend_img.right
                            anchors.right:parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 80
                            color: "#00000000"

                            Text {
                                anchors.fill: parent
                                text: qsTr("本次泵送油耗:")
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:pumping_consumption_section_legend_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: pumping_consumption_section_legend_title.right
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            color: "#00000000"

                            Text {
                                id: pumping_consumption_section_legend_data
                                anchors.fill: parent
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "green"
                                text: qsTr("0.0L")
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }


                    //本次臂架油耗图例
                    Rectangle{
                        id:boom_consumption_section_legend
                        anchors.top:pumping_consumption_section_legend.bottom
                        anchors.left: analy_consumption_right.left
                        anchors.right: analy_consumption_right.right
                        anchors.leftMargin: 0.25*analy_consumption_right.width
                        anchors.rightMargin: 0.25*analy_consumption_right.width
                        anchors.topMargin: 5
                        color: "#00000000"
                        height: 30

                        Rectangle{
                            id:boom_consumption_section_legend_img
                            height: parent.height-10
                            width: height
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            color: "red"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            radius: 5
                        }

                        Rectangle{
                            id:boom_consumption_section_legend_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left:boom_consumption_section_legend_img.right
                            anchors.right:parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 80
                            color: "#00000000"

                            Text {
                                anchors.fill: parent
                                text: qsTr("本次臂架油耗:")
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:boom_consumption_section_legend_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: boom_consumption_section_legend_title.right
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            color: "#00000000"

                            Text {
                                id: boom_consumption_section_legend_data
                                anchors.fill: parent
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "green"
                                text: qsTr("0.0L")
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    //本次怠速油耗
                    Rectangle{
                        id:idle_consumption_section_legend
                        anchors.top:boom_consumption_section_legend.bottom
                        anchors.left: analy_consumption_right.left
                        anchors.right: analy_consumption_right.right
                        anchors.leftMargin: 0.25*analy_consumption_right.width
                        anchors.rightMargin: 0.25*analy_consumption_right.width
                        anchors.topMargin: 5
                        height: 30
                        color: "#00000000"

                        Rectangle{
                            id:idle_consumption_section_legend_img
                            height: parent.height-10
                            width: height
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            color: "yellow"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            radius: 5
                        }

                        Rectangle{
                            id:idle_consumption_section_legend_title
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left:idle_consumption_section_legend_img.right
                            anchors.right:parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 80
                            color: "#00000000"

                            Text {
                                anchors.fill: parent
                                text: qsTr("本次怠速油耗:")
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                color: "white"
                            }
                        }

                        Rectangle{
                            id:idle_consumption_section_legend_text
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: idle_consumption_section_legend_title.right
                            anchors.right: parent.right
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            color: "#00000000"

                            Text {
                                id: idle_consumption_section_legend_data
                                anchors.fill: parent
                                font.family: "Microsoft YaHei"
                                font.pixelSize: 25
                                color: "green"
                                text: qsTr("0.0L")
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            //故障信息
            Rectangle{
                id:fault_record
                anchors.fill: parent
                anchors.leftMargin: 0.025*parent.width+5
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                anchors.rightMargin: 5
                color: "#00000000"
                visible: false

                Rectangle{
                    id:date_choose
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 50
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    color: "#00000000"
                    ComboBox{
                        id:year_combox
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        currentIndex: 0
                        width: 150
                        font.family: "Microsoft YaHei"
                        font.pointSize: 25
                        model: ListModel{
                            id: year_listModel
                        }
                    }

                    Rectangle{
                        id:year_title
                        anchors.left: year_combox.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 5
                        height: parent.height
                        width: height
                        color: "#00000000"

                        Text {
                            text: qsTr("年")
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            color: "white"
                        }
                    }

                    ComboBox{
                        id:month_combox
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: year_title.right
                        anchors.leftMargin: 5
                        currentIndex: 0
                        width: 150
                        font.family: "Microsoft YaHei"
                        font.pointSize: 25
                        model: ListModel{
                            id:month_listModel
                        }
                    }

                    Rectangle{
                        id:month_title
                        anchors.left: month_combox.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 5
                        height: parent.height
                        width: height
                        color: "#00000000"

                        Text {
                            text: qsTr("月")
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            color: "white"
                        }
                    }

                    Rectangle{
                        id:choose_time_button
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: month_title.right
                        anchors.leftMargin: 5
                        width: 150
                        color: "#9EE82E"
                        radius: 5

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Microsoft YaHei"
                            font.pixelSize: 25
                            text: qsTr("选择时间")
                        }

                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            onPressed: {
                                choose_time_button.color="#FA9D40"
                            }

                            onReleased: {
                                choose_time_button.color="#9EE82E"
                            }

                            onClicked: {
                                mode3()
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    var i
                    var year=new Date().getFullYear()
                    for(i=0;i<10;i++){
                        year_listModel.append({"text":year.toString()})
                        year--
                    }

                    for(i=1;i<=12;i++){
                        month_listModel.append({"text":i.toString()})
                    }
                }
                Rectangle{
                    anchors.top: date_choose.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 5
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    anchors.bottomMargin: 5
                    color: "#00000000"

                    Rectangle{
                        visible: true
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 50
                        anchors.bottomMargin: 50
                        anchors.leftMargin: 50
                        anchors.rightMargin: 50
                        color: "#00000000"

                        border.width: 2
                        border.color: Qt.rgba(128/255,128/255,128/255,128/255)

                        //臂架故障次数
                        Rectangle{
                            id:boom_fault_num
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: parent.width/3
                            color: "#00000000"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)

                            //0~5
                            Rectangle{
                                id:axisY_1
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: 0
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //6~10
                            Rectangle{
                                id:axisY_2
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: parent.height/4-2
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //11~15
                            Rectangle{
                                id:axisY_3
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: parent.height/4*2-4
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //16~20
                            Rectangle{
                                id:axisY_4
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.top: parent.top
                                anchors.bottomMargin: parent.height/4*3-6
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //设置Y轴坐标
                            Rectangle{
                                width: 30
                                height: 30
                                anchors.right: axisY_1.left
                                anchors.top: axisY_1.bottom
                                anchors.topMargin: -15
                                color: "#00000000"

                                Text {
                                    text: qsTr("0")
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                width: 30
                                height: 30
                                anchors.right: axisY_2.left
                                anchors.top: axisY_2.bottom
                                anchors.topMargin: -15
                                color: "#00000000"

                                Text {
                                    text: qsTr("5")
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                width: 30
                                height: 30
                                anchors.right: axisY_3.left
                                anchors.top: axisY_3.bottom
                                anchors.topMargin: -15
                                color: "#00000000"

                                Text {
                                    text: qsTr("10")
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                width: 30
                                height: 30
                                anchors.right: axisY_4.left
                                anchors.top: axisY_4.bottom
                                anchors.topMargin: -15
                                color: "#00000000"

                                Text {
                                    text: qsTr("15")
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                width: 30
                                height: 30
                                anchors.right: axisY_4.left
                                anchors.bottom: axisY_4.top
                                anchors.bottomMargin: -15
                                color: "#00000000"

                                Text {
                                    text: qsTr("20")
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                id:bar_boom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: fault_boom_num/20*parent.height
                                anchors.leftMargin: parent.width/4
                                anchors.rightMargin: parent.width/4
                                color: "blue"
                            }

                            Rectangle{
                                anchors.left: bar_boom.left
                                anchors.right: bar_boom.right
                                anchors.bottom: bar_boom.top
                                height: 30
                                color: "#00000000"
                                Text {
                                    id: num_boom
                                    text: fault_boom_num
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }


                            Rectangle{
                                anchors.left: bar_boom.left
                                anchors.right: bar_boom.right
                                anchors.top: bar_boom.bottom
                                height: 30
                                color: "#00000000"
                                Text {
                                    text: "臂架故障次数"
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }
                        }

                        //底盘故障次数
                        Rectangle{
                            id:chassis_fault_num
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: boom_fault_num.right
                            anchors.leftMargin: -2
                            width: parent.width/3
                            color: "#00000000"
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)

                            //0~5
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: 0
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //6~10
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: parent.height/4-2
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //11~15
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: parent.height/4*2-4
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //16~20
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.top: parent.top
                                anchors.bottomMargin: parent.height/4*3-6
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            Rectangle{
                                id:bar_chassis
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: fault_chassis_num/20*parent.height
                                anchors.leftMargin: parent.width/4
                                anchors.rightMargin: parent.width/4
                                color: "blue"
                            }

                            Rectangle{
                                anchors.left: bar_chassis.left
                                anchors.right: bar_chassis.right
                                anchors.bottom: bar_chassis.top
                                height: 30
                                color: "#00000000"
                                Text {
                                    id: num_chassis
                                    text: fault_chassis_num
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                anchors.left: bar_chassis.left
                                anchors.right: bar_chassis.right
                                anchors.top: bar_chassis.bottom
                                height: 30
                                color: "#00000000"
                                Text {
                                    text: "底盘故障次数"
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }
                        }

                        //泵送故障次数
                        Rectangle{
                            id:pumping_fault_num
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: chassis_fault_num.right
                            anchors.right: parent.right
                            color: "#00000000"
                            anchors.leftMargin: -2
                            border.width: 2
                            border.color: Qt.rgba(128/255,128/255,128/255,128/255)

                            //0~5
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: 0
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //6~10
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: parent.height/4-2
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //11~15
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height/4
                                anchors.bottomMargin: parent.height/4*2-4
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            //16~20
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.top: parent.top
                                anchors.bottomMargin: parent.height/4*3-6
                                color: "#00000000"
                                border.width: 2
                                border.color: Qt.rgba(128/255,128/255,128/255,128/255)
                            }

                            Rectangle{
                                id:bar_pumping
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: fault_pumping_num/20*parent.height
                                anchors.leftMargin: parent.width/4
                                anchors.rightMargin: parent.width/4
                                color: "blue"
                            }

                            Rectangle{
                                anchors.left: bar_pumping.left
                                anchors.right: bar_pumping.right
                                anchors.bottom: bar_pumping.top
                                height: 30
                                color: "#00000000"
                                Text {
                                    id: num_pumping
                                    text: fault_pumping_num
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }

                            Rectangle{
                                anchors.left: bar_pumping.left
                                anchors.right: bar_pumping.right
                                anchors.top: bar_pumping.bottom
                                height: 30
                                color: "#00000000"
                                Text {
                                    text: "泵送故障次数"
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 25
                                    color: "white"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
