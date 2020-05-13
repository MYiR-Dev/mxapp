import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.VirtualKeyboard 2.1
import QtQuick.Window 2.2
SystemWindow {
    id: tickWnd
//    visible: true
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height


//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }

    property int title_font_size: 24
    Component.onCompleted:  {
        console.log(translator.get_current_language())
        if (translator.get_current_language() === "English")
            title_font_size = 18
        else
            title_font_size = 24

        console.log(title_font_size)
    }
    function doOp(op){
        console.log("OP:"+op)
        if (op.toString().length===1) {
            display.text = display.text + op.toString();
        }
        else if(op==="backspace"){
            display.text = display.text.toString().slice(0, -1)
            if (display.text.length == 0) {
                display.text = ""
            }
        }
        else if(op==="clear"){
            input.remove(0,input.displayText.length);
        }
        else if(op==="ok"){
             doCheck(display.text)
        }
    }
    function doCheck(check){
        console.log("accept string: "+ check);
        if(check === "MYIR2020"){
            ticketpop.issuccess = true;
        }
        else
        {
          ticketpop.issuccess = false;
        }

        ticketpop.open()
    }

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("取票机")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            tickWnd.close()
        }

    }

    TitleRightBar{
        anchors{
            top: parent.top
            right: parent.right
            rightMargin: 10
        }
    }

    Rectangle{
        id: method1
        anchors{
            top: parent.top
            topMargin: 50
        }
        width: adaptive_width/2.01
        height: adaptive_height/1.11
//        width: 398
//        height: 430
//        border.color: "#02b9db"
//        border.width: 1
        color: Qt.rgba(0,0,0,0)
        radius: 6

        Rectangle{
            id: m1l
//            width: adaptive_width/2.01
//            height: adaptive_height/15
            width: 398
            height: 32
            anchors{
                top:parent.top
                topMargin: 5
            }
            color: 'transparent'
            RowLayout {
                id: layout1
                anchors.fill: parent
                spacing: 6

                Rectangle {
                    color: 'transparent'
//                    Layout.fillWidth: true
                    Layout.minimumWidth: 100
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: parent.height
                    Layout.alignment: Qt.AlignHCenter
                    Image{
                        id:m1icon
                        anchors{
                            verticalCenter: parent.verticalCenter
                        }
                        source: "images/wvga/public/number.png"
                    }
//                    Text {
//                        anchors.left: m2icon.right
//                        anchors.leftMargin: 10
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        text: parent.width + 'x' + parent.height
//                    }
                                Text {
                                    id: m1t
                                    anchors{
                                        top:parent.top
                    //                    topMargin: 5
                                        left: m1icon.right
                                        leftMargin: 10
                                    }

                                    text: qsTr("取票码取票")
                                    horizontalAlignment: Text.AlignHCenter
                                    color: "#dcdde4";
                                    font.family: "Microsoft YaHei";
                                    font.pixelSize: title_font_size;
                                    wrapMode: Text.Wrap;
                                }
                }
            }
        }

        Rectangle {
//            width: adaptive_width/2.10
//            height: adaptive_height/1.26
            width: 380
            height: 380
            radius: 5
            color: "#00000000"
            anchors{
                top: m1l.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            Item{
                id: display
                width: 300
                height: 32
                anchors{
                    horizontalCenter: parent.horizontalCenter
                }
                property alias text: input.text
                property alias color: iconArea.color
                property alias placeHoldText: placeHold.text

                Rectangle{
                    anchors.fill: parent
                    radius: 6
                    opacity: 0.2
                }

                Rectangle{ // you can change to Image
                    id: iconArea
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5
                    width: 12
                    height: 12
                    radius: 2
                    Image{
                        source: "images/wvga/public/number.png"
                    }
                }

                TextInput{
                    id: input
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: iconArea.right
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: 20
                    color: "white"
                    clip: true
                    focus: false
                    readOnly:true
                    activeFocusOnPress:false

                    Text {
                        id: placeHold
                        font: input.font
                        color: "white"
                        text: {
                            if(input.displayText.length>0){
                                " "
                            }
                            else
                            {
                                qsTr("请输入取票码！")
                            }
                            }
//                        opacity: !input.activeFocus
                        opacity: input.displayText.length>0? 1.0:0.3
                        Behavior on opacity{
                            NumberAnimation{ duration: 300 }
                        }
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }
            }

            Rectangle{
                id: hh
//                anchors.fill: parent
                anchors.top:display.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: display.horizontalCenter
                width: 300
                height: 280
                color: "transparent"


            GridLayout {
                id: grid
                anchors.fill: parent
                columns: 8
                rows: 6
                columnSpacing: 6
                rowSpacing: 6

                Repeater{
                    model:["0","1","2","3","4","5","6","7",
                    "8","9","A","B","C","D","E","F",
                    "G","H","I","J","K","L","M",
                    "N","O","P","Q","R","S","T","U",
                    "V","W","X","Y","Z","\u2190",
                        qsTr("清除输入"),
                        qsTr("确认取票")
                    ]
                    Rectangle {
                        id:nbutton
                        signal clicked
                        property string operation: {
                            if(index===36){
                                "backspace"
                            }
                            else if(index===37){
                                "clear"
                            }
                            else if(index===38){
                                "ok"
                            }
                            else{
                                buttontxt.text
                            }
                        }
                        BorderImage {
                            id: bg
                            anchors.fill: parent
                            source: {
                                if(index > 35){
                                    "images/wvga/public/ok_bg.png"
                                }
                                else{
                                    "images/wvga/public/numbg.png"
                                }
                            }
                            anchors.centerIn: parent
                            border{
                                top:5;
                                bottom: 5;
                                left: 5;
                                right: 5;
                            }
                            horizontalTileMode: BorderImage.Stretch
                            verticalTileMode: BorderImage.Stretch

                        }
                        Layout.columnSpan:{
                            if(index===36){
                                4
                            }
                            else if(index>36){
                                8
                            }
                        }

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        radius: 10;
                        color: "transparent"

                        Text{
                            id:buttontxt
                            text:modelData
                            color: {
                                if(index >35){
                                "white"
                                }
                                else
                                {
                                 "blue"
                                }
                                }
                            font.pixelSize: 20
                            font.family: "Microsoft YaHei";
                            anchors.centerIn: parent
                        }

                        MouseArea{
                            id:buttonMA
                            anchors.fill: parent
                            onClicked: {
                                doOp(operation);
                                nbutton.clicked()
                            }
                        }

                        states: [
                            State {
                                name: "pressed";when:buttonMA.pressed===true
                                PropertyChanges {
                                    target: bg; source:"images/wvga/public/num_bg_dn.png"

                                }
                            }
                        ]

                    }

                }
        }

            GridLayout{

            }

            }
        }
    }
    Canvas {

    id: canvas
    anchors.fill: parent
    property real start_x: adaptive_width/2
    property real start_y: adaptive_height/6.85
    property real end_x: adaptive_width/2
    property real end_y: adaptive_height/1.04
    property bool dashed: true
    property real dash_length: 10
    property real dash_space: 8
    property real line_width: 2
    property real stipple_length: (dash_length + dash_space) > 0 ? (dash_length + dash_space) : 16
    property color draw_color: "grey"

    onPaint: {
        // Get the drawing context
        var ctx = canvas.getContext('2d')
        // set line color
        ctx.strokeStyle = draw_color;
        ctx.lineWidth = line_width;
        ctx.beginPath();

        if (!dashed)
        {
            ctx.moveTo(start_x,start_y);
            ctx.lineTo(end_x,end_y);
        }
        else
        {
            var dashLen = stipple_length;
            var dX = end_x - start_x;
            var dY = end_y - start_y;
            var dashes = Math.floor(Math.sqrt(dX * dX + dY * dY) / dashLen);
            if (dashes == 0)
            {
                dashes = 1;
            }
            var dash_to_length = dash_length/dashLen
            var space_to_length = 1 - dash_to_length
            var dashX = dX / dashes;
            var dashY = dY / dashes;
            var x1 = start_x;
            var y1 = start_y;

            ctx.moveTo(x1,y1);

            var q = 0;
            while (q++ < dashes) {
                x1 += dashX*dash_to_length;
                y1 += dashY*dash_to_length;
                ctx.lineTo(x1, y1);
                x1 += dashX*space_to_length;
                y1 += dashY*space_to_length;
                ctx.moveTo(x1, y1);

            }

        }

        ctx.stroke();

    }
    }

//    Rectangle{
//        id: line
//        anchors{
//            top: parent.top
//            topMargin: 55
//            left: method1.right
//        }
//        width: 2
//        height: 420
//        color: "#02b9db"
//        radius: 1
//    }

    Rectangle{
        id: method2
        anchors{
            top: parent.top
            topMargin: 50
            left: method1.right
            leftMargin: 2
        }
        width: adaptive_width/2.01
        height: adaptive_height/1.11
//        width: 398
//        height: 430
//        border.color: "#02b9dbf2"
//        border.width: 1
        color: Qt.rgba(0,0,0,0)
        radius: 6

        Rectangle{
            id: m2l
//            width: adaptive_width/2.01
//            height: adaptive_height/15
            width: 398
            height: 32
            anchors{
                top:parent.top
                topMargin: 5
            }
            color: 'transparent'
            RowLayout {
                id: layout2
                anchors.fill: parent
                spacing: 6

                Rectangle {
                    color: 'transparent'
//                    Layout.fillWidth: true
                    Layout.minimumWidth: 100
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: parent.height
                    Layout.alignment: Qt.AlignHCenter
                    Image{
                        id:m2icon
                        anchors{
                            verticalCenter: parent.verticalCenter
                        }
                        source: "images/wvga/public/scanner.png"
                    }
//                    Text {
//                        anchors.left: m2icon.right
//                        anchors.leftMargin: 10
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        text: parent.width + 'x' + parent.height
//                    }
                                Text {
                                    id: m2t
                                    anchors{
                                        top:parent.top
                    //                    topMargin: 5
                                        left: m2icon.right
                                        leftMargin: 10
                                    }

                                    text: qsTr("扫码取票")
                                    horizontalAlignment: Text.AlignHCenter
                                    color: "#dcdde4";
                                    font.family: "Microsoft YaHei";
                                    font.pixelSize: title_font_size;
                                    wrapMode: Text.Wrap;
                                }
                }
            }
        }
        Rectangle{
            opacity: 0
//            width: adaptive_width/2.01
//            height: adaptive_height/15
            width: 398
            height: 32
            visible: false

            anchors{
                top:m2l.bottom
                topMargin: 10
            }
            color: 'transparent'
            Item{
                id: display2
                width: 380
                height: 32
                anchors{
                    horizontalCenter: parent.horizontalCenter
                }

                property alias text: input2.text
                property alias color: iconArea2.color
//                property alias placeHoldText: placeHold2.text

                Rectangle{
                    anchors.fill: parent
                    radius: 6
                    opacity: 0.2
                }

                Rectangle{ // you can change to Image
                    id: iconArea2
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5
                    width: 12
                    height: 12
                    radius: 2
                    Image{
                        source: "images/wvga/public/scanner.png"
                    }
                }
//                FocusScope{
                TextInput{
                    id: input2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: iconArea2.right
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: 24
                    color: "white"
                    clip: true
                    focus: true
//                    inputMethodComposing: false
//                    readOnly:true
//                    activeFocusOnPress:false

                    Component.onCompleted: {
//                        input2.selectAll();
                        input2.remove(0,input2.displayText.length);
                        input2.forceActiveFocus();
//                        InputMethod.hide()
//                        InputContext.priv.hideInputPanel()
                    }

                    onAccepted: {
                        doCheck(input2.displayText);
                        input2.remove(0,input2.displayText.length);
                    }

                    Text {
                        id: placeHold2
                        font: input2.font
                        color: "white"
                        text: {
                            if(input2.displayText.length>0){
                                " "
                            }
                            else
                            {
                                qsTr("请将条码置于机器下方扫码处")
                            }
                            }
//                        opacity: !input.activeFocus
                        opacity: input2.displayText.length>0? 1.0:0.3
                        Behavior on opacity{
                            NumberAnimation{ duration: 300 }
                        }
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }
//                }
              }
        }

        Rectangle{
            width: adaptive_width/2.01
            height: adaptive_height/1.17
//            width: 398
//            height: 408
            color: 'transparent'
            anchors{
                top: m2l.bottom
                topMargin: 64
//                left: parent.left
//                leftMargin: 100
            }
            Image{
                anchors{
                    horizontalCenter: parent.horizontalCenter
                }

            width: 204
            height: 297

            source: "images/wvga/public/BANNER.png"
        }
       }
    }

    Popup{
        id:ticketpop
        padding: 0
        margins: 0
        modal: false
        focus: true
        closePolicy: Popup.NoAutoClose
        width: adaptive_width
        height: adaptive_height

        background:Rectangle{
            anchors.fill:parent
            color: "black"
            opacity: 0.3
        }

//        anchors.centerIn: parent

        property alias count: counter.text
        property alias txt: txtstatus.text
//        property alias img: imgstatus.source
        property bool  issuccess: false

        onClosed: {
            console.log("ticketpop closed")
            imgticket.visible=false;
            countdown.stop()
            input.remove(0,input.displayText.length);
        }

        onOpened:{
            console.log("ticketpop opend")
            if(issuccess === false){
                count = "10"
                txt = qsTr("出票失败")
                imgticket.visible = false;
            }
            else
            {
                count = "15"
                txt=qsTr("出票成功")
                imgticket.visible = true;
            }
            countdown.restart();
        }

        MouseArea{
            anchors.fill: parent;
            onPressed:{
                 mouse.accepted = true
            }
        }

        Rectangle{
            id: poprect
            width: 300
            height: 200
            anchors.centerIn: parent
            color: "transparent"
             BorderImage{
                    anchors.fill: parent
                    source: "images/wvga/public/pop_bg.png"
                    border{
                        top:15;
                        bottom: 15;
                        left: 15;
                        right: 15;
                    }
            }

             Text{
                 id: counter
                 anchors.top: parent.top
                 anchors.topMargin: 10
                 anchors.horizontalCenter: parent.horizontalCenter
                 text: "10"
                 color: "white"
                 font{
                     family: "DS-Digital"
                     pointSize: 20
                 }

             }

             Image {
                 id: closeicon
                 source: "images/wvga/public/public_icon_close_nor.png"
                 width: 26
                 height: 26
                 anchors{
                     right: poprect.right
                     rightMargin: 10
                     top:poprect.top
                     topMargin: 10
                 }
                 MouseArea{
                     id:closeMA
                     anchors.fill: parent
                     onClicked: {
                         ticketpop.close()
                     }
                     onPressed: {
                         closeicon.source="images/wvga/public/public_icon_close_hover.png"
                     }
                     onReleased: {
                         closeicon.source="images/wvga/public/public_icon_close_nor.png"
                     }
                 }
             }

             Rectangle{
                 id: rectstatus
                 width: 120
                 height: 120
                 color: "transparent"
                 anchors.top: closeicon.bottom
//                 anchors.topMargin: 50
                 anchors.horizontalCenter: parent.horizontalCenter
                 Image {
                     id: imgstatus
                     anchors.fill: parent
                     source: {
                         if(ticketpop.issuccess === false){
                            "qrc:/images/wvga/public/public_pic_fail.png"
                         }
                         else
                         {
                            "qrc:/images/wvga/public/ticket_box.png"
                         }
                     }
                 }

                 Image {
                     id: imgticket
                     source: "qrc:/images/wvga/public/ticket.png"
                     opacity: 1.0
                     width: 50
                     height: 70
                     visible: ticketpop.issuccess
                     anchors{
                         top: rectstatus.top
                         topMargin:0
                         horizontalCenter: imgstatus.horizontalCenter
                     }
                     onVisibleChanged: {
                         console.log("imgtick is visible? "+ visible);
                         if(visible === true){
                             ticketani.start()
                         }
                         else
                         {
                             ticketani.stop()
                         }
                     }
                     ParallelAnimation{
                         id: ticketani
                         alwaysRunToEnd: true
                         loops: 10

                            NumberAnimation {
                             target: imgticket
                             properties: "opacity"
                             alwaysRunToEnd: true
                             from:0
                             to: 1.0
                             duration: 2000
                             easing.type: Easing.InOutQuad
                             onRunningChanged: {
                                 console.log("imgticket running:"+ running + " "+ y)
                             }
                            }
                            NumberAnimation{
                                target: imgticket.anchors
                                properties: "topMargin"
                                alwaysRunToEnd: true
                                from:0
                                to:  adaptive_height/12
                                duration: 2000
                                easing.type: Easing.InOutQuad
                            }
                     }
                 }
                 Image{
                     id: topbox
                     width: 120
                     height: 49
                     anchors{
                         top: rectstatus.top
                         topMargin:0
                         horizontalCenter: imgstatus.horizontalCenter
                     }
                     source: "qrc:/images/wvga/public/top_box.png"
                     visible: ticketpop.issuccess
                 }

//                 states:[
//                     State {
//                         name: "failed"
//                         PropertyChanges {
//                             target:imgticket; opacity:0

//                         }
//                     }
//                 ]
            }
             Text {
                 id: txtstatus
                 anchors.top: rectstatus.bottom
//                 anchors.topMargin: 10
                 anchors.horizontalCenter: rectstatus.horizontalCenter
                 font.pixelSize: 24
                 color: ticketpop.issuccess? "green":"red"
//                 text: qsTr("出票失败")
             }

             Timer{
                 id:countdown
                 interval:1000;running:true;repeat: true

                 onTriggered: {
                     var count = Number(counter.text.valueOf())
                     if(count === 0){
                         countdown.stop()
                         ticketpop.close()
                     }

                    counter.text= count - 1
                 }
             }
        }
    }
}
