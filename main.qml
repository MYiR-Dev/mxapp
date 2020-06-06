import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import GetSystemInfoAPI 1.0
ApplicationWindow {
    id: mainWnd
    visible: true
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
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
        width:Screen.desktopAvailableWidth
        height:Screen.desktopAvailableHeight/14
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
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight-tBar.height
    }

    MenuWindow{
        id:menuWnd
        anchors.top: tBar.bottom
        visible: false
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight-tBar.height
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
        id:mainloader;
        anchors.centerIn: parent;

    }
//    Loader{
//        id:settingsWnd;
//        anchors.centerIn: parent;
//        source: "SettingsWindow.qml";

//    }
//    Connections {
//         target: settingsWnd.item
//         onMessage:{
//             settingsWnd.setSource("")
//             settingsWnd.setSource("SettingsWindow.qml")

//         }
//     }
}
