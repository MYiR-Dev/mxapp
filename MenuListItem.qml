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
            }
        }

        MouseArea{
            id: homeMA
            anchors.fill: parent;
            hoverEnabled: true;
            cursorShape: Qt.PointingHandCursor;

            onEntered: {
                text1Rect.visible=true;
            }

            onPressed: {
                text1Rect.visible=true;
            }

            onExited: {
                text1Rect.visible=false;
            }
            property bool isClickable: true

            onClicked: {
                console.log("clicked:"+qurl + " " + isClickable)

                // 第二种方式加载
                if(qurl === "PlayerWindow.qml"){
                    mainloader.source = "PlayerWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "CameraWindow.qml"){
                    mainloader.source = "CameraWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "MusicWindow.qml"){
                    mainloader.source = "MusicWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "PictureWindow.qml"){
                    mainloader.source = "PictureWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "TicketWindow.qml"){
                    mainloader.source = "TicketWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "ScopeWindow.qml"){
                    mainloader.source = "ScopeWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "FileWindow.qml"){
                    mainloader.source = "FileWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "WashWindow.qml"){
                    mainloader.source = "WashWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "InfoWindow.qml"){
                    mainloader.source = "InfoWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }else if(qurl === "SettingsWindow.qml"){
                    mainloader.source = "SettingsWindow.qml"
                    mainloader.item.show()
                    mainloader.item.requestActivate()
                }
                else if(qurl === "BrowserWindow.qml"){
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
