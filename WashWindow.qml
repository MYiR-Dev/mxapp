import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
SystemWindow {
    id: washWindow
//    title: "Wash"
//    flags:Qt.FramelessWindowHint

    property int mode: -1; // 当前洗涤模式

    property int totalwatertime: 180    // model:3 总加水时间  (modelData+1)*60s
    property int totaltemeraturetime: 180 // model:60 总加热时间 modelData*3s
    property int totalwashtime: 4500      // model:66 总洗涤时间 (modelData+10)*60s
    property int totalrinsetime: 240      // model:3 总漂洗时间 modelData*120s
    property int totaldehydrationtime: 1800 // model:31 总脱水时间 modelData*60s
    property int totaldrytime: 3600         // model:61 总烘干时间 modelData*60s
    property int totalarragetime: 240       // model:3 总整理时间 modelData*120s
    property int totaltime: 10740        // 总时间

    property int currenttime: 10740        // 剩余时间

    Binding{
        target: washWindow;property: 'totalwatertime'
        value:(tumbler0.currentIndex+1)*60
    }
    Binding{
        target: washWindow;property: 'totaltemeraturetime'
        value:(tumbler1.currentIndex)*3
    }
    Binding{
        target: washWindow;property: 'totalwashtime'
        value:(tumbler2.currentIndex+10)*60
    }
    Binding{
        target: washWindow;property: 'totalrinsetime'
        value:(tumbler3.currentIndex)*120
    }
    Binding{
        target: washWindow;property: 'totaldehydrationtime'
        value:(tumbler4.currentIndex)*60
    }
    Binding{
        target: washWindow;property: 'totaldrytime'
        value:(tumbler5.currentIndex)*60
    }
    Binding{
        target: washWindow;property: 'totalarragetime'
        value:(tumbler6.currentIndex)*120
    }

    onVisibleChanged: {
        console.log("washWindow is visible? "+washWindow.visible);
        stateGrp.state = "MODE";
        mode = 0;
        rect.rotation = 0
        washing.waterlevel = 0;
        washing.progress = 0;
    }

    onModeChanged: {
        enable_mode(mode)
        var para = modes.model[mode]._parm;

        tumbler0.positionViewAtIndex(para[0]-1,Tumbler.Beginning)
        tumbler1.positionViewAtIndex(para[1]-1,Tumbler.Beginning)
        tumbler2.positionViewAtIndex(para[2]-1,Tumbler.Beginning)
        tumbler3.positionViewAtIndex(para[3]-1,Tumbler.Beginning)
        tumbler4.positionViewAtIndex(para[4]-1,Tumbler.Beginning)
        tumbler5.positionViewAtIndex(para[5]-1,Tumbler.Beginning)
        tumbler6.positionViewAtIndex(para[6]-1,Tumbler.Beginning)
        get_total_time()
        console.log("mode changed:"+mode)
        console.log("totalwatertime is "+ totalwatertime)
        console.log("totaltemeraturetime is "+ totaltemeraturetime)
        console.log("totalwashtime is "+ totalwashtime)
        console.log("totalrinsetime is "+ totalrinsetime)
        console.log("totaldehydrationtime is "+ totaldehydrationtime)
        console.log("totaldrytime is "+ totaldrytime)
        console.log("totalarragetime is "+ totalarragetime)
        console.log("totaltime is "+totaltime)
    }

    function toTime(s){
        var time;
        if(s > -1){
            var hour = Math.floor(s/3600);
            var min = Math.floor((s/60)%60);
            var sec = s % 60;
            if(hour < 10){
                time = hour + ":";
            }
            if(min < 10){
                time += "0";
            }
            time += min + ":";
            if(sec < 10){
                time += "0";
            }
            time += sec.toFixed(0);
        }
        return time;
    }

    onCurrenttimeChanged: {
        var elapsedtime = totaltime-currenttime;
        var time0 = totalwatertime
        var time1 = totalwatertime+totaltemeraturetime
        var time2 = totalwatertime+totaltemeraturetime+totalwashtime
        var time3 = totalwatertime+totaltemeraturetime+totalwashtime+totalrinsetime
        var time4 = totalwatertime+totaltemeraturetime+totalwashtime+totalrinsetime+totaldehydrationtime
        var time5 = totalwatertime+totaltemeraturetime+totalwashtime+totalrinsetime+totaldehydrationtime+totaldrytime
        var time6 = totalwatertime+totaltemeraturetime+totalwashtime+totalrinsetime+totaldehydrationtime+totaldrytime+totalarragetime
        // display currenttime
        countdown.text=toTime(currenttime)
        washing.progress = Math.min(Math.floor(elapsedtime*100/totaltime),100)
        washing.step = washing.progress
        console.log("Currenttime:"+ currenttime+" elaspedtime:"+elapsedtime+" Totaltime:"+totaltime +" Progress:"+washing.progress)

//        console.log("time0 is "+ time0)
//        console.log("time1 is "+ time1)
//        console.log("time2 is "+ time2)
//        console.log("time3 is "+ time3)
//        console.log("time4 is "+ time4)
//        console.log("time5 is "+ time5)
//        console.log("time6 is "+ time6)


        if((0<elapsedtime)&&(elapsedtime<time0))
        {
            washing.txt=qsTr("正在加水")
            washing.waterlevel = Math.min(Math.floor(elapsedtime*100/180),100)
            console.log("we are watering: "+ washing.waterlevel)
        }
        if((time0<elapsedtime)&&(elapsedtime<time1))
        {
            console.log("we are hoting")
            washing.txt=qsTr("正在加热")
        }
        if((time1<elapsedtime)&&(elapsedtime<time2))
        {
            console.log("we are washing")
            washing.txt=qsTr("正在洗涤")
        }
        if((time2<elapsedtime)&&(elapsedtime<time3))
        {
            console.log("we are rinsing")
            washing.txt=qsTr("正在漂洗")
        }
        if((time3<elapsedtime)&&(elapsedtime<time4))
        {
            washing.txt=qsTr("正在脱水")
            if(totaldehydrationtime>0){
                washing.waterlevel=Math.floor((time4-elapsedtime)*washing.waterlevel/totaldehydrationtime)
            }
            console.log("we are dehydrating "+washing.waterlevel)
        }
        if((time4<elapsedtime)&&(elapsedtime<time5))
        {
            console.log("we are drying")
            washing.txt=qsTr("正在烘干")
        }
        if((time5<elapsedtime)&&(elapsedtime<time6))
        {
            console.log("we are arranging")
            washing.txt=qsTr("正在整理")
        }
        if(elapsedtime===time0)
        {
            console.log("we are waterd")
            washing.txt=qsTr("加水完毕")
        }
        if(elapsedtime===time1)
        {
            console.log("we are hotted")
            washing.txt=qsTr("加热完毕")
        }
        if(elapsedtime===time2)
        {
            console.log("we are washed")
            washing.txt=qsTr("洗涤完毕")
        }
        if(elapsedtime===time3)
        {
            console.log("we are rinsed")
            washing.txt=qsTr("漂洗完毕")
        }
        if(elapsedtime===time4)
        {
            console.log("we are dehyrated")
            washing.txt=qsTr("脱水完毕")
        }
        if(elapsedtime===time5)
        {
            console.log("we are dryed")
            washing.waterlevel = 0;
            washing.txt=qsTr("烘干完毕")
        }
        if(elapsedtime>=time6)
        {
            console.log("we are finished")
            washing.waterlevel = 0;
            washing.txt=""

            currenttime = 0;
            icondoor.source="qrc:/images/wvga/smart/smart_icon_lock_open_nor.png"
            counter.stop();
        }
    }

    function disable_modes(){
         for(var i=0; i< modes.count;++i){
             modes.itemAt(i).state="OFF"
         }
    }

    function enable_mode(index){
        disable_modes()
        if((index>=0)&&(index<modes.count)){
            mode = index;
            modes.itemAt(index).state="ON"
        }
    }

// 预计总时间
    function get_total_time(){
        totaltime = (totalwatertime+totaltemeraturetime+totalwashtime+totalrinsetime+totaldehydrationtime+totaldrytime+totalarragetime)
        return totaltime;
    }
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
//  background:
        Image {
        id: washbg
        anchors.fill: parent
        source: "qrc:/images/wvga/smart/wash_bg.png"
    }

//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

    Rectangle {
        id:tBar
        width:adaptive_width
        height:adaptive_height/15
        color: "transparent"

        HomeButton{
            id: logo
            width: adaptive_width/9.09
            height: adaptive_height/34.28
            label.visible: false
            clickable: true
            source: "qrc:/images/fhd/ecg/header_logo.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
        }

        Image{
                id: close
                source: "qrc:/images/wvga/smart/smart_btn_quit_nor.png"
//                width: adaptive_width/12
//                height: adaptive_height/19.2
                width: 66
                height:25
                anchors{
                    right:tt.left
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
                Image {
                    id: pwroff
//                    width: adaptive_width/66.66
//                    height: adaptive_height/40
                    width: 12
                    height: 12
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_quit_nor.png"
                }

                Text {
                    id: txtexit
                    anchors.left: pwroff.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Microsoft YaHei"
                    text: qsTr("退出")
                    font.pointSize: 11
                    color: "white"
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        washWindow.close();
                    }

                    onPressed: {
                        close.source="qrc:/images/wvga/smart/smart_btn_quit_hover.png"
                    }
                    onReleased: {
                        close.source="qrc:/images/wvga/smart/smart_btn_quit_nor.png"
                    }
                }
        }

        Rectangle{
            id:tt
            color:"transparent"

            width: 80
            height: 30/*adaptive_height/15*/
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
    //        anchors.rightMargin: 20
    //        anchors.topMargin: 5


        Text {
            id: time
            anchors.leftMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            font{
                family:"DS-Digital"
                pixelSize:14
            }
            text: "00:00:00";color: "white";// style: Text.Outline;
        }

        Text {
            id: date
            anchors.top:time.bottom
            anchors.leftMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
    //        font.pointSize:8; text: qsTr("2020年2月25日");style: Text.Outline;styleColor: "white"
            font{
                family: "DS-Digital"
                pixelSize: 10
            }
    //        style: Text.Outline;
    //        text: qsTr("2020年2月25日")
            color: "white"

        }
    }

        Timer{
            id:timer
            interval:500;running:true;repeat: true
            onTriggered: {
                var currentTime = new Date();
                time.text = Qt.formatTime(currentTime,"hh:mm:ss");
                date.text = Qt.formatDate(currentTime,"yyyy-MM-dd");
            }
        }

        Component.onCompleted: {
            timer.start();
        }
    }

    Rectangle{
        id: bottombar
        width:adaptive_width
        height:adaptive_height/6.85
//        width: 800
//        height: 70
        anchors.bottom: parent.bottom
        color: Qt.rgba(0,0,0,0)

        RowLayout {
            id: bottomlayout
            anchors.fill: parent
            spacing: 0
            Rectangle{
                id:currentrect
                color: Qt.rgba(0,0,0,0)
//                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.fillWidth: true
//                Layout.minimumWidth: 80
//                Layout.preferredWidth: 99
//                Layout.maximumWidth: 300
//                Layout.minimumHeight: 150
                Image {
                    id: currentmode
                    anchors{
                        left: currentrect.left
                        leftMargin:currentrect.height/4
                        verticalCenter: currentrect.verticalCenter
                    }

                    width: currentrect.height/3
                    height:currentrect.height/3
                    source: modes.model[mode]._icon
                }
                Text{
                    id:currenttitle
                    anchors{
                        left: currentmode.right
                        top:currentrect.top
                        topMargin: adaptive_height/32
                        leftMargin: adaptive_width/160
                    }
                    text: qsTr("当前设置")
                    horizontalAlignment: Text.AlignHCenter
                    color: "#dcdde4";
                    font.family: "Microsoft YaHei";
                    font.pixelSize: 10;
                    wrapMode: Text.Wrap;
                }
                Text {
                    id:currenttext
                    anchors{
                        left: currentmode.right
                        bottom:currentrect.bottom
                        bottomMargin: adaptive_height/32
                        leftMargin: adaptive_width/160
                    }
                    text: modes.model[mode]._text
                    horizontalAlignment: Text.AlignHCenter
                    color: "#dcdde4";
                    font.family: "Microsoft YaHei";
                    font.pixelSize: 12;
                    font.bold: true
                    wrapMode: Text.Wrap;
                }

            }
// 水位
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
//                Rectangle{
//                    color: "#02b9db"
//                    opacity: 1.0
//                    width: 1
//                    height: parent.height*3/4
//                    anchors.left: parent.left
//                    anchors.verticalCenter: parent.verticalCenter
//                }
                Image {
                    id: paraimage0
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_water.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt0
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler0

                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 3
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: {
                                    if(modelData === 0){
                                        qsTr("低")
                                    }
                                    else if(modelData === 1){
                                        qsTr("中")
                                    }
                                    else if(modelData === 2){
                                        qsTr("高")
                                    }
                                }

                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler0.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView0
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler0.model
                                delegate: tumbler0.delegate
                                clip: true
                                pathItemCount: tumbler0.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView0.width / 2
                                    startY: -pathView0.delegateHeight / 2
                                    PathLine {
                                        x: pathView0.width / 2
                                        y: pathView0.pathItemCount * pathView0.delegateHeight - pathView0.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler0.availableHeight / tumbler0.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt0.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt0.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("水位")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
// 温度
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle{
                    color: "#02b9db"
                    opacity: 0.5
                    width: 1
                    height: parent.height*2/4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: paraimage1
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_temperature.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt1
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler1
                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 60
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: {
                                    if(modelData+40>40){
                                        qsTr("%1 ℃").arg(modelData+40)
                                    }
                                    else
                                    {
                                        qsTr("常温")
                                    }
                                }
                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler1.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView1
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler1.model
                                delegate: tumbler1.delegate
                                clip: true
                                pathItemCount: tumbler1.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView1.width / 2
                                    startY: -pathView1.delegateHeight / 2
                                    PathLine {
                                        x: pathView1.width / 2
                                        y: pathView1.pathItemCount * pathView1.delegateHeight - pathView1.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler1.availableHeight / tumbler1.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt1.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt1.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("温度")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
// 洗涤
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle{
                    color: "#02b9db"
                    opacity: 0.6
                    width: 1
                    height: parent.height*3/5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: paraimage2
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_wash.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt2
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler2
                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 66
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: qsTr("%1 分").arg(modelData+10)
                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler2.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView2
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler2.model
                                delegate: tumbler2.delegate
                                clip: true
                                pathItemCount: tumbler2.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView2.width / 2
                                    startY: -pathView2.delegateHeight / 2
                                    PathLine {
                                        x: pathView2.width / 2
                                        y: pathView2.pathItemCount * pathView2.delegateHeight - pathView2.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler2.availableHeight / tumbler2.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt2.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt2.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("洗涤")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
// 漂洗
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle{
                    color: "#02b9db"
                    opacity: 0.75
                    width: 1
                    height: parent.height*3/4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: paraimage3
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_rinse.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt3
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler3
                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 3
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: qsTr("%1 次").arg(modelData)
                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler3.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView3
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler3.model
                                delegate: tumbler3.delegate
                                clip: true
                                pathItemCount: tumbler3.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView3.width / 2
                                    startY: -pathView3.delegateHeight / 2
                                    PathLine {
                                        x: pathView3.width / 2
                                        y: pathView3.pathItemCount * pathView3.delegateHeight - pathView3.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler3.availableHeight / tumbler3.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt3.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt3.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("漂洗")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
// 脱水
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle{
                    color: "#02b9db"
                    opacity: 0.75
                    width: 1
                    height: parent.height*3/4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: paraimage4
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_dehydration.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt4
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler4
                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 31
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: qsTr("%1 分").arg(modelData)
                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler4.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView4
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler4.model
                                delegate: tumbler4.delegate
                                clip: true
                                pathItemCount: tumbler4.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView4.width / 2
                                    startY: -pathView4.delegateHeight / 2
                                    PathLine {
                                        x: pathView4.width / 2
                                        y: pathView4.pathItemCount * pathView4.delegateHeight - pathView4.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler4.availableHeight / tumbler4.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt4.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt4.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("脱水")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
// 烘干
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle{
                    color: "#02b9db"
                    opacity: 0.6
                    width: 1
                    height: parent.height*3/5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: paraimage5
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_dry.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt5
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler5
                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 61
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: qsTr("%1 分").arg(modelData)
                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler5.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView5
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler5.model
                                delegate: tumbler5.delegate
                                clip: true
                                pathItemCount: tumbler5.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView5.width / 2
                                    startY: -pathView5.delegateHeight / 2
                                    PathLine {
                                        x: pathView5.width / 2
                                        y: pathView5.pathItemCount * pathView5.delegateHeight - pathView5.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler5.availableHeight / tumbler5.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt5.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt5.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("烘干")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }

// 整理
            Rectangle{
                color: "transparent"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle{
                    color: "#02b9db"
                    opacity: 0.5
                    width: 1
                    height: parent.height*2/4
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    id: paraimage6
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/40
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_icon_arrange.png"

                }
                Rectangle{
                    width: parent.width-40
                    height: 60
                    anchors.left: parent.left
                    anchors.leftMargin: adaptive_width/20
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle{
                        id: paratxt6
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 40
                        height: 40
                        color: "transparent"
                        Image{
                            source: "qrc:/images/wvga/smart/smart_icon_up_nor.png"
                            width: 10
                            height: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    pathView.decrementCurrentIndex()
//                                }
//                            }
                        }
                        Image{
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            source: "qrc:/images/wvga/smart/smart_icon_dn_nor.png"
                            width: 10
                            height: 5
//                            MouseArea{
//                                anchors.fill: parent;
//                                hoverEnabled: true;
//                                cursorShape: Qt.PointingHandCursor;

//                                onClicked: {
//                                    control.positionViewAtIndex(0)
//                                }
//                            }
                        }

                        Tumbler {
                            id: tumbler6
                            anchors.fill: parent
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: 3
                            visibleItemCount: 1
                            enabled: stateGrp.state==="MODE"

                            delegate: Text {
                                text: qsTr("%1 次").arg(modelData)
                    //            font: control.font
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler6.visibleItemCount / 2)
                            }

                            contentItem: PathView {
                                id: pathView6
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: tumbler6.model
                                delegate: tumbler6.delegate
                                clip: true
                                pathItemCount: tumbler6.visibleItemCount + 1
                                preferredHighlightBegin: 0.5
                                preferredHighlightEnd: 0.5
                                dragMargin: width / 2

                                path: Path {
                                    startX: pathView6.width / 2
                                    startY: -pathView6.delegateHeight / 2
                                    PathLine {
                                        x: pathView6.width / 2
                                        y: pathView6.pathItemCount * pathView6.delegateHeight - pathView6.delegateHeight / 2
                                    }
                                }

                                property real delegateHeight: tumbler6.availableHeight / tumbler6.visibleItemCount
                            }
                        }
                    }
                    Text {
                        anchors.top: paratxt6.bottom
//                        anchors.topMargin: 6
                        anchors.horizontalCenter: paratxt6.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Microsoft YaHei"
                        text: qsTr("整理")
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }
// start
            Rectangle {
                color: 'transparent'
                Layout.fillHeight: true
                Layout.minimumWidth: 80
                Layout.preferredWidth: 99

                Image {
                    id: btnStart
                    width: 50
                    height: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/wvga/smart/smart_btn_suspend_nor.png"
                }

                MouseArea{
                    anchors.fill: parent

                    onPressed: {
                        btnStart.scale=0.9
                    }
                    onReleased: {
                        btnStart.scale=1.0
                    }

                    onClicked: {
                        console.log("state is " + stateGrp.state)
                        if(stateGrp.state==="WASH"){
                            stateGrp.state="MODE"
                            modes.itemAt(0).state="ON"
                        }else if((stateGrp.state==="MODE")||(stateGrp.state==="")){
                            stateGrp.state="WASH"
                            modes.itemAt(0).state="OFF"
                        }
                    }

                }

            }
        }

    }

    // ModeSelector
    Rectangle{
        id:modesel
        anchors.top: parent.top
        anchors.topMargin: adaptive_height/15
        width:adaptive_width
        height:adaptive_height/1.26
//        width: 800
//        height:378
        color: "transparent"

        onVisibleChanged: {
            console.log("modesel is visible? "+modesel.visible);
            if(visible === false){
                mode = -1;
            }
            else
            {
                mode = 0;
                rect.rotation = 0
            }
        }

        property real iconrad : 20
        property real iconmags: 20
        property real moderad: height/2-iconrad-iconmags
        property real iconang: Math.PI/8

        Repeater{
            id: modes
            model: [
                {
                     "_icon":"qrc:/images/wvga/smart/smart_icon_mixdwash_nor.png",
                     "_text":qsTr("混合洗"),
                    "_parm":[1,0,30,1,16,16,1]
                }, //0
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_quick15_nor.png",
                    "_text":qsTr("快洗15"),
                    "_parm":[1,0,0,1,1,0,0]
                }, //1
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_quick30_nor.png",
                    "_text":qsTr("快洗30"),
                    "_parm":[1,0,12,1,4,0,0]
                }, //2
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_jackets_nor.png",
                    "_text":qsTr("羽绒服"),
                    "_parm":[1,0,0,0,0,0,2]
                }, //3
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_wool_nor.png",
                    "_text":qsTr("羊毛衫"),
                    "_parm":[1,0,0,2,5,0,0]
                }, //4
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_large_nor.png",
                    "_text":qsTr("大件"),
                    "_parm":[2,0,20,2,10,0,0]
                }, //5
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_enzyme_nor.png",
                    "_text":qsTr("活性酶"),
                    "_parm":[0,0,0,0,0,0,0]
                }, //6
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_rd_nor.png",
                    "_text":qsTr("漂洗脱水"),
                    "_parm":[0,0,0,1,2,0,0]
                }, //7
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_singlede_nor.png",
                    "_text":qsTr("单脱水"),
                    "_parm":[0,0,0,0,2,0,0]
                }, //8
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_self-cleaning_nor.png",
                    "_text":qsTr("桶自洁"),
                    "_parm":[1,0,0,0,0,0,0]
                }, //9
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_energy_nor.png",
                    "_text":qsTr("节能"),
                    "_parm":[0,0,0,0,0,0,0]
                }, //10
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_soak_nor.png",
                    "_text":qsTr("浸泡洗"),
                    "_parm":[2,0,10,1,10,0,0]
                }, //11
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_smart_nor.png",
                    "_text":qsTr("智能洗"),
                    "_parm":[0,0,0,0,0,0,0]
                }, //12
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_kid_nor.png",
                    "_text":qsTr("婴儿服"),
                    "_parm":[1,60,5,2,10,10,0]
                }, //13
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_shirt_nor.png",
                    "_text":qsTr("衬衫"),
                    "_parm":[1,0,15,0,0,0,2]
                }, //14
                {
                    "_icon":"qrc:/images/wvga/smart/smart_icon_cal_nor.png",
                    "_text":qsTr("棉麻"),
                    "_parm":[2,0,15,2,20,0,1]
                }, //15
                ]

            Rectangle{
                id:modex
                width: modesel.iconrad*2
                height: modesel.iconrad*2
                radius: modesel.iconrad
                color: "#55555555"
//                opacity: 0.5
                x: modesel.width/2+modesel.moderad*Math.sin(modesel.iconang*index)-modesel.iconrad
                y: modesel.height/2-modesel.moderad*Math.cos(modesel.iconang*index)-modesel.iconrad

                Rectangle{
                    id:mode0
                    width: modesel.iconrad*2
                    height: modesel.iconrad*2
                    radius: modesel.iconrad
                    color: "#02b9db"
                    opacity: 0.5
//                    x: modesel.width/2+modesel.moderad*Math.sin(modesel.iconang*index)-modesel.iconrad
//                    y: modesel.height/2-modesel.moderad*Math.cos(modesel.iconang*index)-modesel.iconrad
                }

                Image {
                    id: icon0
                    source: modelData._icon
                    width: mode0.width/3
                    height: mode0.height/3
                    anchors{
                        top: mode0.top
                        margins:icon0.height/2
                        horizontalCenter:mode0.horizontalCenter
                    }
                }
                Text {
                    id: text0
                    anchors{
                        top: icon0.bottom
//                        margins:5
                        horizontalCenter: icon0.horizontalCenter
                    }
                    text: modelData._text
                    horizontalAlignment: Text.AlignHCenter
                    color: "#dcdde4";
                    font.family: "Microsoft YaHei";
                    font.pixelSize: 8;
                    wrapMode: Text.Wrap;
                }

                states:[
                    State {
                        name: "OFF"
    //                    PropertyChanges {
    //                        target: object

    //                    }
                    },
                    State {
                        name: "ON"
    //                    PropertyChanges {
    //                        target: object

    //                    }
                    }
                ]

                transitions: [
                    Transition {
                        from: "ON"
                        to: "*"
                        ParallelAnimation{
                            NumberAnimation{
                                target: mode0
                                properties: "opacity"
                                to: 0.5
                                duration: 300
                                easing {
                                    type: Easing.OutElastic
                                    amplitude: 1.0
                                    period: 0.5
                                }
                            }
                            NumberAnimation{
                                target: mode0
                                properties: "scale"
                                to: 1.0
                                duration: 300
                                easing {
                                    type: Easing.OutElastic
                                    amplitude: 1.0
                                    period: 0.5
                                }
                            }
                        }
                    },
                    Transition {
                        from: "*"
                        to: "ON"
                        ParallelAnimation{
                            NumberAnimation{
                                target: mode0
                                properties: "opacity"
                                to: 1.0
                                duration: 300
                                easing {
                                    type: Easing.OutElastic
                                    amplitude: 1.0
                                    period: 0.5
                                }
                            }
                            NumberAnimation{
                                target: mode0
                                properties: "scale"
                                to: 1.5
                                duration: 300
                                easing {
                                    type: Easing.OutElastic
                                    amplitude: 1.0
                                    period: 0.5
                                }
                            }
                        }
                    }

                ]

            }
        }
        Item {
                id: container;
                width: 256;
                height: width;
                anchors.centerIn: parent;

                property real centerX : (width / 2);
                property real centerY : (height / 2);

                Image{
                    anchors.fill: parent;
                    source: "qrc:/images/wvga/smart/smart_icon_knob_nor.png"
                }

                Rectangle{
                    transformOrigin: Item.Center;
                    id: rect;
                    color: "transparent";
                    radius: (width / 2);
                    antialiasing: true;
                    anchors.fill: parent;

                    Rectangle {
                        id: handle;
                        color: "#02b9db";
                        width: 6;
                        height: 15;
                        radius: (width/2);
                        antialiasing: true;
                        anchors {
                            top: parent.top;
                            margins: height;
                            horizontalCenter: parent.horizontalCenter;
                        }
                    }
                    MouseArea{
                        anchors.fill: parent;
                        onPositionChanged:  {
                            var rdeg = 0;
                            var point =  mapToItem (container, mouse.x, mouse.y);
                            var diffX = (point.x - container.centerX);
                            var diffY = -1 * (point.y - container.centerY);
                            if(diffX===0){
                                if(diffY<0){
                                    rdeg = 180
                                }
                                else{
                                    rdeg = 0
                                }
                            }
                            else
                            {
                                var rad = Math.atan (diffY / diffX);
                                var deg = (rad * 180 / Math.PI);
                                if (diffX > 0 && diffY >= 0) {
                                    rdeg  = 90 - Math.abs (deg);
                                }
                                else if (diffX > 0 && diffY < 0) {
                                    rdeg  = 90 + Math.abs (deg);
                                }
                                else if (diffX < 0 && diffY >= 0) {
                                    rdeg  = 270 + Math.abs (deg);
                                }
                                else if (diffX < 0 && diffY < 0) {
                                    rdeg  = 270 - Math.abs (deg);
                                }
                            }

                            var tmp = Math.round (Math.abs(rdeg-11)/ 22.5)
                            if((tmp>=modes.count)||(tmp<0)){
                                tmp = 0
                            }

                            mode = tmp
                            rect.rotation = mode*22.5

//                            console.log("rect.rotation="+rect.rotation)
                        }
                    }
                }
//                Text {
//                    text: "%1 secs".arg (Math.round (Math.abs(rect.rotation-11)/ 22.5));
//                    font {
//                        pixelSize: 20;
//                        bold: true;
//                    }
//                    anchors.centerIn: parent;
//                }
            }
    }

    // Washing
    Rectangle{
        id: washing
        anchors.top: parent.top
        anchors.topMargin: adaptive_height/15
        width:adaptive_width
        height:adaptive_height/1.26
//        width: 800
//        height:378
        color: "transparent"
        opacity: 0
        visible: false

        property int waterlevel: 0
        property int progress: 0
        property alias step: progressnumber.text
        property alias txt: progresstxt.text

//        onProgressChanged: {
//            console.log("current progress: "+ progress)
//        }

        onVisibleChanged: {
            console.log("washing is visible? "+washing.visible);
            if(visible === true){
                currenttime = get_total_time()
                washing.progress = 0;
                washing.waterlevel = 0;
                washing.step = 0;
                washing.txt = "加水"
                counter.restart()
            }
            else
            {
                counter.stop()
            }
        }

        Rectangle{
            id: washprogress
            width: 402
            height: 16
            radius: 8
            color:"#2002b9db"
            anchors{
                top: washing.top
                topMargin: 24
                horizontalCenter: washing.horizontalCenter
            }

            Rectangle{
                id:currentwashprogress
                anchors.left: washprogress.left
                anchors.leftMargin: 1
                anchors.verticalCenter: washprogress.verticalCenter
                height: 14
                radius: height/2
                width: washing.progress*4+1

                property color col: "#02b9db"
//                color:"#02b9db"
                gradient: Gradient{
                    GradientStop{position: 0.0; color: Qt.tint(currentwashprogress.col, "#4002b9db")}
                    GradientStop{position: 1.0; color: "#02b9db"}
                }
            }

            Rectangle{
                id:washpointer
                y: -10
                x: (washing.progress*4)-18
                Image {
                    id: circle
                    width: 36
                    height: 36
                    source: "qrc:/images/wvga/smart/smart_gif_progress_00000.png"
                }
                Text {
                    id: progressnumber
                    anchors.centerIn: circle
                    text: qsTr("1")
                    color: "white"
                }
                Text {
                    id: progresstxt
                    anchors.top: circle.bottom
                    anchors.bottomMargin: 15
                    anchors.horizontalCenter: circle.horizontalCenter
                    color: "white"
                    font.bold: true
                    text: qsTr("加水")
                }
            }
        }
        Text {
            id: progressstart
            text: qsTr("开始")
            color: "white"
            anchors.right: washprogress.left
            anchors.rightMargin: washprogress.height
            anchors.verticalCenter: washprogress.verticalCenter
        }
        Text {
            id: progressend
            text: qsTr("完成")
            color: "white"
            anchors.left: washprogress.right
            anchors.leftMargin: washprogress.height
            anchors.verticalCenter: washprogress.verticalCenter
        }
        Text {
            id: countdown
            text: qsTr("00:00:00")
            anchors{
                top: washing.top
                topMargin: 64
                horizontalCenter: washing.horizontalCenter
            }
            font{
                bold: true
                family:"DS-Digital"
                pixelSize: 48
            }
            color: "white"
        }

        Text {
            id: counttitle
            text: qsTr("剩余时间:")
            anchors{
                right: countdown.left
                rightMargin: adaptive_width/20
                verticalCenter: countdown.verticalCenter
            }
            color: "white"
        }

        Image {
            id: icondoor
            width: 30
            height: 30
            anchors{
                left: countdown.right
                leftMargin: adaptive_width/20
                verticalCenter: countdown.verticalCenter
            }
            source: "qrc:/images/wvga/smart/smart_icon_lock_close_nor.png"
        }
        Rectangle{
            id: rect1
            width: 240
            height: 240
            radius: width/2
            anchors{
                top: washing.top
                topMargin: 120
                horizontalCenter: washing.horizontalCenter
            }
            gradient: Gradient {
                GradientStop { position: 0.0; color: "black" }
                GradientStop { position: 0.33; color: "grey" }
                GradientStop { position: 1.0; color: "white" }
            }
        }
        Rectangle{
            id: rect2
            width: 240
            height: width
            radius: width/2
            color: "transparent"
            anchors{
                top: washing.top
                topMargin: 120
                horizontalCenter: washing.horizontalCenter
            }

            //! [source]
            ShaderEffectSource {
                id: theSource
                sourceItem: sourceimg
            }

            Image {
                id: sourceimg
                anchors{
                    bottom: rect2.bottom
                    bottomMargin: 20
                    horizontalCenter: rect2.horizontalCenter
                }

                source: "qrc:/images/wvga/smart/water.png"
                width: Math.min(rect2.width*washing.waterlevel/100+90, 200)
                height: Math.min((200*washing.waterlevel*2/300)+20, 150)
            }
            ShaderEffect {
                id:sourceimgshade
                anchors{
                    bottom: rect2.bottom
                    bottomMargin: 20
                    horizontalCenter: rect2.horizontalCenter
                }
                width: sourceimg.width
                height: sourceimg.height
                property variant source: theSource
                property real amplitude: 0.04 * 1//wobbleSlider.value
                property real frequency: 20
                property real time: 0
                NumberAnimation on time { loops: Animation.Infinite; from: 0; to: Math.PI * 2; duration: 600 }
                //! [fragment]
                fragmentShader: "qrc:/shader/wobble.frag"
                //! [fragment]
//                Slider {
//                    id: wobbleSlider
//                    anchors.left: parent.left
//                    anchors.right: parent.right
//                    anchors.bottom: parent.bottom
//                    height: 20
//                }
            }
        }
        Rectangle{
            id: rect3
            width: 240
            height: 240
            radius: width/2
            color: "transparent"
            anchors{
                top: washing.top
                topMargin: 120
                horizontalCenter: washing.horizontalCenter
            }
            Image {
                id: door
                width: 256
                height: 256
                source: "qrc:/images/wvga/smart/door.png"
                anchors.centerIn: parent
            }
        }
        Image {
            id: rect4
            anchors{
                top: rect3.top
                topMargin: 90
                left: rect3.left
                leftMargin: 65
            }
            width: 20
            height: 80
            source: "qrc:/images/wvga/smart/lighting.png"
        }

        Timer{
            id:counter
            interval: 1000;running: false;repeat: true
            onTriggered: {  // display countdown
                currenttime=currenttime-1
            }
        }
    }

    StateGroup{
        id:stateGrp

        states: [
            State {
                name: "MODE"
                PropertyChanges {
                    target: modesel;
                    opacity:1
                    visible:true
                }
                PropertyChanges {
                    target: washing
                    opacity:0
                    visible:false
                }
                PropertyChanges {
                    target: btnStart
                    source:"qrc:/images/wvga/smart/smart_btn_suspend_nor.png"
                }
            },
            State {
                name: "WASH"
                PropertyChanges {
                    target: modesel;
                    opacity:0
                    visible:false
                }
                PropertyChanges {
                    target: washing
                    opacity:1
                    visible:true
                }
                PropertyChanges {
                    target: btnStart
                    source:"qrc:/images/wvga/smart/smart_btn_start_nor.png"
                }
            }
        ]
    }
}
