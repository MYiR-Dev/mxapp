import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.12
ApplicationWindow {
    id: mainWnd
    visible: true
    width: 800
    height: 480
    title: qsTr("Hello World")

    background: Image{
            source: "images/wvga/home/background-dark.png"
        }

    function  chooseWnd(str){
        console.log(str)
        if(str === "HOME"){
            stateGrp.state = "HOME"
        }
        if(str === "MENU"){
            stateGrp.state = "MENU"
        }
    }

    TitleBar {
        id:tBar
        width:800
        height:32
    }

//    HomeButton{
//        id: test
//        width: 30
//        height: 30
//        label.visible: false
////        glowColor: "red"
//        glowRadius: 20
//        anchors.top:tBar.bottom

//    }

    HomeWindow{
        id:homeWnd
        anchors.top: tBar.bottom
        visible: true
        width: 800
        height: 480-tBar.height
    }

    MenuWindow{
        id:menuWnd
        anchors.top: tBar.bottom
        visible: false
        width: 800
        height: 480-tBar.height
    }

    StateGroup{
        id:stateGrp
        states:[
            State {
                name: "HOME"
                PropertyChanges {
                    target: homeWnd
                    opacity:1
                    visible:true
                }
                PropertyChanges {
                    target: menuWnd
                    opacity:0
                    visible:false
                }
            },
            State {
                name: "MENU"
                PropertyChanges {
                    target: homeWnd
                    opacity:0
                    visible:false
                }
                PropertyChanges {
                    target: menuWnd
                    opacity:1
                    visible:true
                }
            }
        ]
    }
    Loader{
        id:playerWnd;
        anchors.centerIn: parent;
        source: "PlayerWindow.qml";
    }
    Loader{
        id:scopeWnd;
        anchors.centerIn: parent;
        source: "ScopeWindow.qml";
    }
    Loader{
        id:ticketWnd;
        anchors.centerIn: parent;
        source: "TicketWindow.qml";
    }
    Loader{
        id:cameraWnd;
        anchors.centerIn: parent;
        source: "CameraWindow.qml";
    }
    Loader{
        id:infoWnd;
        anchors.centerIn: parent;
        source: "InfoWindow.qml";
    }
    Loader{
        id:settingsWnd;
        anchors.centerIn: parent;
        source: "SettingsWindow.qml";
    }
    Loader{
        id:musicWnd;
        anchors.centerIn: parent;
        source: "MusicWindow.qml";
    }
    Loader{
        id:pictureWnd;
        anchors.centerIn: parent;
        source: "PictureWindow.qml";
    }
    Loader{
        id:washWnd;
        anchors.centerIn: parent;
        source: "WashWindow.qml";
    }
    Loader{
        id:fileWnd;
        anchors.centerIn: parent;
        source: "FileWindow.qml";
    }
    Loader{
        id:browserWnd;
        anchors.centerIn: parent;
        source: "BrowserWindow.qml";
    }
    Loader{
        id:supportWnd;
        anchors.centerIn: parent;
        source: "SupportWindow.qml";
    }
}
