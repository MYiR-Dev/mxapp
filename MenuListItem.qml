import QtQuick 2.7
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

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

            onClicked: {
                // load new window
                console.log(qurl)
                var obj = Qt.createComponent(qurl).createObject(mainWnd)
//                        obj.z = 4;
                obj.show()
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
