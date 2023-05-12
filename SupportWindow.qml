import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
Popup {
    id:supportpop
    padding: 0
    margins: 0
    modal: false
    focus: true
    closePolicy: Popup.NoAutoClose
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: mainWnd.width
    height: mainWnd.height

//    FontLoader { id: bahnschriftFont; source: "qrc:/fonts/Bahnschrift.ttf" }

    background:Rectangle{
        anchors.fill:parent
        color: "black"
        opacity: 0.3
    }

//    anchors.centerIn: parent

    function show(){
        open()
    }

    function showNormal(){
        open()
    }

    function requestActivate()
    {
        forceActiveFocus()
    }

    onClosed: {
        console.log("supportpop closed")
    }

    onOpened:{
        console.log("supportpop opend")
        interval.restart()
    }

    MouseArea{
        anchors.fill: parent;
        onPressed:{
             mouse.accepted = true
        }
    }

    Rectangle{
        id: poprect
        width: adaptive_width/1.11/*720*/
        height: adaptive_height/1.2/*400*/
        scale: 0.95
        anchors.centerIn: parent
        color: "transparent"
         Image{
                width: adaptive_width/1.11
                height: adaptive_height/1.2
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: "images/wvga/home/background-dark.png"
//                opacity: 0.9
        }
         Rectangle{
             id:supporttitle
             width: adaptive_width/1.11
             height: adaptive_height/12
             anchors.top: poprect.top
             anchors.topMargin: adaptive_height/16
             color: "transparent"

             Image {
                 id: myirline
                 width: adaptive_width/1.33
                 height: adaptive_height/480
                 anchors.centerIn: supporttitle
                 source: "qrc:/images/wvga/home/myir_line.png"
             }
             Text {
                 id: supporttext
                 text: qsTr("米尔支持")
                 horizontalAlignment: Text.AlignHCenter
                 color: "#dcdde4";
                 font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                 font.pixelSize: 24;
                 font.bold: true
                 wrapMode: Text.Wrap;
                 anchors.centerIn: supporttitle
             }
         }
         Rectangle{
             id:supportlogo
             width: adaptive_width/1.11/*720*/
             height: adaptive_height/12/*40*/
             anchors.top: poprect.top
             anchors.topMargin: adaptive_height/8/*60*/
             color: "transparent"
            Image{
                id:back2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/images/wvga/back2.png"

                ParallelAnimation{
                    id:back2ani
                    NumberAnimation{
                        target: back2
                        properties: "opacity"
                        from:0.2
                        to:1.0
                        duration: 2000
                    }
                    NumberAnimation{
                        target: back2
                        properties: "scale"
                        from:0.8
                        to:1.2
                        duration: 2000
                    }
                }
                Timer{
                    id:interval
                    interval:1000;running:true;repeat: true
                    onTriggered: {
                        if(back2ani.running === false){
                            back2ani.restart()
                        }

                    }
                }
            }

            Image {
                     width: 172
                     height: 35
                     anchors.left: back2.right
                     anchors.leftMargin: 15
                     anchors.verticalCenter: parent.verticalCenter
                     source:"qrc:/images/LOGO.png"
           }

          MouseArea{
                    anchors.fill: parent;
                    onClicked:{
                         supportpop.close()
                    }
          }
        }

         GridLayout {
             id: supportgrid
             anchors.top: supportlogo.bottom
             anchors.topMargin: 5
             width: adaptive_width/1.11
             height: adaptive_height/1.6
             columns: 3
             rows: 3
             columnSpacing: 6
             rowSpacing: 6

             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 color: "transparent"
                 Image {
                     id: img1
                     width: 38
                     height:38
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     source: "qrc:/images/wvga/home/myir_phone.png"
                 }
                 Text {
                     id:txt11
                     anchors.left: img1.right
//                     anchors.leftMargin: 10
                     anchors.top: parent.top
//                     anchors.topMargin: 10
                     anchors.margins: adaptive_height/48
                     text: qsTr("电话")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt12
                     anchors.left: img1.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt11.bottom
                     text: qsTr("0755-25622735")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt13
                     visible: false
                     anchors.left: img1.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt12.bottom
                     text: qsTr("18926526796")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }

             } // 1
             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 color: "transparent"
                 Image {
                     id: img2
                     width: 38
                     height:38
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     source: "qrc:/images/wvga/home/myir_fax.png"
                 }
                 Text {
                     id:txt21
                     anchors.left: img2.right
//                     anchors.leftMargin: 10
                     anchors.top: parent.top
//                     anchors.topMargin: 10
                     anchors.margins: adaptive_height/48
                     text: qsTr("传真")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt22
                     anchors.left: img2.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt21.bottom
                     text: qsTr("0755-25532724")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt23
                     visible: false
                     anchors.left: img2.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt22.bottom
                     text: qsTr("18926526796")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }

             }//2
             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 Layout.rowSpan: 3
                 color: "transparent"

                 Image{
                     id:img3
                     anchors.centerIn: parent
                     width: parent.width/2
                     height: parent.width/2
                     source: "qrc:/images/wvga/home/myir_qrcode.png"
                 }
                 Text {
                     id:txt31
                     anchors.bottom: img3.top
                     anchors.bottomMargin: 20
                     anchors.horizontalCenter: parent.horizontalCenter
                     text: qsTr("深圳米尔电子有限公司")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt33
//                     visible: false
                     anchors.horizontalCenter: parent.horizontalCenter
                     anchors.margins: adaptive_height/48
                     anchors.top: img3.bottom
                     text: qsTr("www.myir-tech.com")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
             }//3
             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 color: "transparent"
                 Image {
                     id: img4
                     width: 38
                     height:38
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     source: "qrc:/images/wvga/home/myir_sales_mail.png"
                 }
                 Text {
                     id:txt41
                     anchors.left: img4.right
//                     anchors.leftMargin: 10
                     anchors.top: parent.top
//                     anchors.topMargin: 10
                     anchors.margins: adaptive_height/48
                     text: qsTr("邮箱")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt42
                     anchors.left: img4.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt41.bottom
                     text: qsTr("sales.cn@myirtech.com")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt43
                     anchors.left: img4.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt42.bottom
                     text: qsTr("project@myirtech.com")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }

             }//4
             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 color: "transparent"
                 Image {
                     id: img5
                     width: 38
                     height:38
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     source: "qrc:/images/wvga/home/myir_support_mail.png"
                 }
                 Text {
                     id:txt51
                     anchors.left: img5.right
//                     anchors.leftMargin: 10
                     anchors.top: parent.top
//                     anchors.topMargin: 10
                     anchors.margins: adaptive_height/48
                     text: qsTr("技术支持邮箱")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt52
                     anchors.left: img5.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt51.bottom
                     text: qsTr("support.cn@myirtech.com")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt53
                     visible: false
                     anchors.left: img5.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt52.bottom
                     text: qsTr("18926526796")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }

             }//5
             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 color: "transparent"
                 Image {
                     id: img6
                     width: 38
                     height:38
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     source: "qrc:/images/wvga/home/myir_sales_mail.png"
                 }
                 Text {
                     id:txt61
                     anchors.left: img6.right
//                     anchors.leftMargin: 10
                     anchors.top: parent.top
//                     anchors.topMargin: 10
                     anchors.margins: adaptive_height/48
                     text: qsTr("地址")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt62
                     anchors.left: img6.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt61.bottom
                     text: (adaptive_height<=480)?qsTr("深圳市龙岗区坂田街道发达路云里<br>智能园2栋6楼04室"):qsTr("深圳市龙岗区坂田街道发达路云里智能园2栋6楼04室")
//                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode:Text.Wrap;
                 }
                 Text {
                     id:txt63
                     visible: false
                     anchors.left: img6.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt62.bottom
                     text: qsTr("www.myir-tech.com")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }

             }//6
             Rectangle{
                 Layout.fillHeight: true
                 Layout.fillWidth: true
                 color: "transparent"
                 Image {
                     id: img7
                     width: 38
                     height:38
                     anchors.left: parent.left
                     anchors.leftMargin: 10
                     anchors.verticalCenter: parent.verticalCenter
                     source: "qrc:/images/wvga/home/myir_support_phone.png"
                 }
                 Text {
                     id:txt71
                     anchors.left: img7.right
//                     anchors.leftMargin: 10
                     anchors.top: parent.top
//                     anchors.topMargin: 10
                     anchors.margins: adaptive_height/48
                     text: qsTr("技术支持电话")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 20;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt72
                     anchors.left: img7.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt71.bottom
                     text: qsTr("027-59621648")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }
                 Text {
                     id:txt73
                     visible: false
                     anchors.left: img7.right
                     anchors.margins: adaptive_height/48
                     anchors.top: txt72.bottom
                     text: qsTr("18926526796")
                     horizontalAlignment: Text.AlignHCenter
                     color: "#dcdde4";
                     font.family: "Microsoft YaHei";//bahnschriftFont.name;//
                     font.pixelSize: 12;
                     font.bold: true
                     wrapMode: Text.Wrap;
                 }

             }
         }
    }
}
