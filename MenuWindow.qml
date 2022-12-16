import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
Rectangle {
    id:root
//    width: 800
//    height: 480-tBar.height
//    color: "green"
    color: "#00000000"
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    SwipeView{
        id:menuSwpView
        width: adaptive_width
        height: adaptive_height/1.2

//        Loader{
//            id:page1
//            anchors.fill: parent
//            source: "qrc:/page1.qml"
//        }

//        Loader{
//            id:page2
//            anchors.fill: parent
//            source: "qrc:/page2.qml"
//        }

        Page{
            width: adaptive_width
            height: adaptive_height/1.2
            background: Rectangle {
                anchors.fill: parent
                      opacity: 0
                      color: "#00000000"
                  }
            Rectangle{
                id: recttop
                width: adaptive_width
                height: adaptive_height/24
                color: "transparent"

//                MenuListItem {
//                                            imageSource:"images/wvga/home/cam.png"
//                                            text1: "_text";
//                                            num: "1"
//                                        }
            }


                ListModel{
                    id: menuListModel1
                    ListElement {
                        _imageSource: "images/wvga/home/player.png"
                        _text1: qsTr("视频播放器")
                        _text2: qsTr("播放器")
                        _num: "1"
                        _qurl: "PlayerWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/music.png"
                        _text1: qsTr("音乐播放器")
                        _text2: qsTr("音乐")
                        _num: "1"
                        _qurl: "MusicWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/camera.png"
                        _text1: qsTr("拍照和预览")
                        _text2: qsTr("摄像头")
                        _num: "1"
                        _qurl: "CameraWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/picture.png"
                        _text1: qsTr("图片浏览")
                        _text2: qsTr("图片")
                        _num: "1"
                        _qurl: "PictureWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/ticket.png"
                        _text1: qsTr("取票机演示")
                        _text2: qsTr("取票机")
                        _num: "1"
                        _qurl: "TicketWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/scope.png"
                        _text1: qsTr("心电仪演示")
                        _text2: qsTr("心电仪")
                        _num: "1"
                        _qurl: "ScopeWindow.qml"
                    }

                }

                Grid{
                    id: menuListGrid1
                    anchors.top: recttop.bottom
                    anchors.topMargin: adaptive_height/24/*20*/
                    columns: 3
                    rows:2
//                    topPadding: 30
                    columnSpacing: adaptive_width/8.33/*96;*/
                    rowSpacing: adaptive_height/19.2 /*25*/
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater{
                        model: menuListModel1
                        delegate: MenuListItem {
                            imageSource: _imageSource;
                            text1: _text1;
                            text2: _text2;
                            num: _num;
                            qurl: _qurl;
                        }
                    }
                }
        }

        Page{
            width: adaptive_width
            height: adaptive_height/1.2
            background: Rectangle {
                anchors.fill: parent
                      opacity: 0
                      color: "#00000000"
                  }
            Rectangle{
                id: recttop2
                width: adaptive_width
                height: adaptive_height/24
                color: "transparent"

//                MenuListItem {
//                                            imageSource:"images/wvga/home/cam.png"
//                                            text1: "_text";
//                                            num: "1"
//                                        }
            }


                ListModel{
                    id: menuListModel2
                    ListElement {
                        _imageSource: "images/wvga/home/wash.png"
                        _text1: qsTr("智能洗衣机演示")
                        _text2: qsTr("洗衣机")
                        _num: "1"
                        _qurl: "WashWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/information.png"
                        _text1: qsTr("系统信息")
                        _text2: qsTr("系统信息")
                        _num: "1"
                        _qurl: "InfoWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/settings.png"
                        _text1: qsTr("")
                        _text2: qsTr("系统设置")
                        _num: "1"
                        _qurl: "SettingsWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/filemanager.png"
                        _text1: qsTr("")
                        _text2: qsTr("文件管理")
                        _num: "1"
                        _qurl: "FileWindow.qml"
                    }
//                    ListElement {
//                        _imageSource: "images/wvga/home/browser.png"
//                        _text1: qsTr("浏览器演示")
//                        _text2: qsTr("浏览器")
//                        _num: "1"
//                        _qurl: "BrowserWindow.qml"
//                    }
                    ListElement {
                        _imageSource: "images/wvga/home/contact.png"
                        _text1: qsTr("联系我们")
                        _text2: qsTr("联系我们")
                        _num: "1"
                        _qurl: "SupportWindow.qml"
                    }
//                    ListElement {
//                        _imageSource: "images/wvga/home/cam.png"
//                        _text: "2.45"
//                        _num:"1"

//                    }
//                    ListElement {
//                        _imageSource: "images/wvga/home/cam.png"
//                        _text: "2.45"
//                        _num:"1"

//                    }
                }

                Grid{
                    id: menuListGrid2
                    anchors.top: recttop2.bottom
                    anchors.topMargin: adaptive_height/24/*20*/
                    columns: 3
                    rows:2
//                    topPadding: 30
                    columnSpacing: adaptive_width/8.33/*96;*/
                    rowSpacing: adaptive_height/19.2 /*25*/
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater{
                        model: menuListModel2
                        delegate: MenuListItem {
                            imageSource: _imageSource;
                            text1: _text1;
                            text2: _text2;
                            num: _num;
                            qurl: _qurl;
                        }
                    }
                }
        }


    }
    PageIndicator{
        id: control
        count:menuSwpView.count
        currentIndex: menuSwpView.currentIndex
        anchors{
            bottom: menuSwpView.bottom
            horizontalCenter: parent.horizontalCenter
        }
        delegate: Rectangle {
                  implicitWidth: 8
                  implicitHeight: 8

                  radius: width / 2
                  color: "#eeeeee"

                  opacity: index === control.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

                  Behavior on opacity {
                      NumberAnimation {
                          duration: 200
                      }
                  }
              }
    }


//    HomeButton{
//        anchors.margins: 20
//        width: 128
//        height: 128
//        text: qsTr("系统信息")
//    }


    HomeButton {
        text: qsTr("toMENU")
        label.visible: false
        source:"images/wvga/home/menu.png"
//        width: 30
//        height: 30
        glowRadius: 20
//        z: 2

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: height * 0.5
            }

        onClicked: {
               mainWnd.chooseWnd("HOME")
        }
    }

}
