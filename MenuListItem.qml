import QtQuick 2.7
import QtQuick.Controls 2.1
//import QtGraphicalEffects 1.0

Rectangle {
    id:root
    property string imageSource;    //图片url
    property string text1;                  //鼠标hover是弹出的text
    property string text2;              //底部的text
    property string num;                  //次数
    property string qurl;                  // 加载的新qml Component
    width: 150;
    height: 170;
    color: "transparent";

    Image {
        id: image;
        width: 120;
        height: 120;
        source: imageSource;
        z:1;

        //顶部hover弹出区域
        Rectangle{
            id:text1Rect;
            width: parent.width;
            height: 120;
            radius: 20
            color: "black";
            opacity: 0.7;
            visible: false;
            z:2;

            Label{
                width: parent.width;
                height: parent.height;
                padding: 5;
                text: text1;
                color: "#ffffff";
                font.family: "Microsoft YaHei";
                font.pixelSize: 12;
                wrapMode: Text.Wrap;
//                verticalAlignment: Text.AlignVCenter
            }
        }

//        //顶部非hover区域
//        Rectangle{
//            id:numRect;
//            width: parent.width;
//            height: 20;
////            opacity: 0.7;
//            opacity: 0.0;
//            color: "transparent";
//            z:2;

//            //颜色渐变
//            LinearGradient{
//                anchors.fill: parent;
//                start: Qt.point(0, 0);
//                end: Qt.point(parent.width, 0);
//                gradient: Gradient {
//                    GradientStop { position: 0.0; color: "transparent" }
//                    GradientStop { position: 0.7; color: "gray" }
//                    GradientStop { position: 1.0; color: "black" }
//                }
//            }

//            Label{
//                anchors.right: numLab.left;
//                width: 30;
//                height: parent.height;
//                text: "\uf82b";
//                color: "white";
//                font.pixelSize: 16;
//                font.family:icomoonFont.name;
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter;
//            }

//            Label{
//                id:numLab;
//                anchors.right: parent.right;
//                width: 40;
//                height: parent.height;
//                padding: 5;
//                text: (parseInt(num)>=100000)?parseInt(parseInt(num)/10000)+qsTr("万"):num;
//                color:"#ffffff"
//                font.family: "Microsoft YaHei";
//                font.pixelSize: 12;
//                verticalAlignment:Label.AlignVCenter;
//                horizontalAlignment: Label.AlignRight;

//                Component.onCompleted: {
//                    switch(text.length)
//                    {
//                    case 3:
//                        width=25;
//                        break;
//                    case 4:
//                        width=32;
//                        break;
//                    case 5:
//                        width=40;
//                        break;
//                    default:
//                        width=50;
//                        break;
//                    }
//                }
//            }
//        }

//        //图像底部play按钮
//        Label{
//            id:playLab;
//            width: 30;
//            height: 30;
//            anchors.bottom: parent.bottom;
//            anchors.right: parent.right;
//            text: "\ued03";
//            color: "#e6e9ec"
//            font.pixelSize: 24;
//            font.family:icomoonFont.name;
//            verticalAlignment: Text.AlignVCenter
//            horizontalAlignment: Text.AlignHCenter;
//            visible: false;

//            MouseArea{
//                anchors.fill: parent;
//                hoverEnabled: true;
//                cursorShape: Qt.PointingHandCursor;

//                onEntered: {

//                }

//                onExited: {

//                }

//                onClicked: {

//                }
//            }
//        }

        MouseArea{
            id: homeMA
            anchors.fill: parent;
            hoverEnabled: true;
            cursorShape: Qt.PointingHandCursor;

            onEntered: {
                text1Rect.visible=true;
//                numRect.visible=false;
//                playLab.visible=true;
            }

            onPressed: {
                text1Rect.visible=true;
//                numRect.visible=false;
            }

            onExited: {
                text1Rect.visible=false;
//                numRect.visible=true;
//                playLab.visible=false;
            }
            property bool isClickable: true

            onClicked: {
                console.log("clicked:"+qurl + " " + isClickable)
//                timer.start()
//                if(isClickable === true){
//                    var componet = Qt.createComponent(qurl);
//                    if(componet.status === Component.Ready) {
//                        var obj = componet.createObject(mainWnd)
//                    }
//                    obj.show()

//                    isClickable = false;
//                }

// 第二种方式加载
                  if(qurl === "PlayerWindow.qml"){
//                      playerWnd.forceActiveFocus()
//                      playerWnd.z=4;
                        mainloader.source = "PlayerWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "CameraWindow.qml"){
//                      cameraWnd.forceActiveFocus()
//                      cameraWnd.z=4;
                        mainloader.source = "CameraWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                  }else if(qurl === "MusicWindow.qml"){
//                      cameraWnd.forceActiveFocus()
//                      cameraWnd.z=4;
                        mainloader.source = "MusicWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "PictureWindow.qml"){
//                      pictureWnd.forceActiveFocus()
//                      pictureWnd.z=4;
                        mainloader.source = "PictureWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "TicketWindow.qml"){
//                      ticketWnd.forceActiveFocus()
//                      ticketWnd.z=4;
                        mainloader.source = "TicketWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "ScopeWindow.qml"){
//                      scopeWnd.forceActiveFocus()
//                      scopeWnd.z=4;
                        mainloader.source = "ScopeWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "FileWindow.qml"){
//                      fileWnd.forceActiveFocus()
//                      fileWnd.z=4;
                        mainloader.source = "FileWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "WashWindow.qml"){
//                      washWnd.forceActiveFocus()
//                      washWnd.z=4;
                        mainloader.source = "WashWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "InfoWindow.qml"){
//                      infoWnd.forceActiveFocus()
//                      infoWnd.z=4;
                        mainloader.source = "InfoWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                   }else if(qurl === "SettingsWindow.qml"){
//                      settingsWnd.forceActiveFocus()
//                      settingsWnd.z=4;
                        mainloader.source = "SettingsWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
//                        settingsWnd.item.show()
//                        settingsWnd.item.requestActivate()
                   }
                  else if(qurl === "BrowserWindow.qml"){
//                      browserWnd.forceActiveFocus()
//                      browserWnd.z=4;
                        mainloader.source = "BrowserWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                 }
                  else if(qurl === "SupportWindow.qml"){
                        mainloader.source = "SupportWindow.qml"
                        mainloader.item.show()
                        mainloader.item.requestActivate()
                 }
            }


            Timer{
                id:timer
                interval:1000;running:false;repeat: false
                onTriggered: {
                    homeMA.isClickable = true;
                    console.log("timer isClickable: " + homeMA.isClickable)
                }
            }
        }
    }

    Text{
        width: parent.width;
        height: 35;
        anchors.top: image.bottom;
        anchors.horizontalCenter: image.horizontalCenter
        anchors.topMargin: 5;
        text: text2;
        horizontalAlignment: Text.AlignHCenter
        color: "#dcdde4";
        font.family: "Microsoft YaHei";
        font.pixelSize: 20;
        wrapMode: Text.Wrap;
    }
}
