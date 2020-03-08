import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.1

ApplicationWindow {
    id: systemWindow
    width:800
    height:480
    opacity: 0
    title: qsTr("SystemWindow")

    property bool isdump: false

    background: Image{
            source: "images/wvga/home/background-dark.png"
        }

//    Loader{
//        id:loader;
//        anchors.centerIn: parent;
//        source: "Loading.qml";
//    }
//    // Button to open the main application window
//    Button {
//        text: qsTr("main window")
//        width: 180
//        height: 50
//        anchors.centerIn: parent
//        onClicked: {
//            systemWindow.signalExit() // invoke signal
//            systemWindow.close()
//        }
//    }


    ParallelAnimation{
        id: winoutani
        running: false
        NumberAnimation { target: systemWindow; property: "opacity"; to: 0; duration: 600}
//        NumberAnimation { target: systemWindow; property: "x"; to: 0;  duration: 100}
//        NumberAnimation { target: systemWindow; property: "y"; to: 0;  duration: 100}
        onRunningChanged: {
            console.log("x:" + x +"y:"+y);
            console.log(systemWindow+" is running:" + running)
        }
        onStopped: {
            close.accepted = true;
            systemWindow.close()
        }
    }

    ParallelAnimation {
        id: wininani
        running: false
        NumberAnimation { target: systemWindow; property: "opacity"; to: 1.0; duration: 200}
//        NumberAnimation { target: systemWindow; property: "x"; from: 0;  duration: 100
//            onStopped: {
//                systemWindow.show()
//            }
//        }
//        NumberAnimation { target: tickWnd; property: "height"; from: 0; to: 480; duration: 200}
        onRunningChanged: {
            console.log("x:" + x);
            console.log("y:"+y);
        }
        onStopped: {
//            tickWnd.close()
            console.log(systemWindow+"opened")
        }
    }

//    PropertyAnimation {
//        id: windowAni
//        target: systemWindow
//        properties: "opacity"
//        from: 0; to: 1.0; duration:500
//        running: true
//        onRunningChanged: {
////            if(windowAni.running){
//                console.log("running:" + running)
////            }
//            }
//        onStopped: {
//            systemWindow.show()
//        }
//    }

    Component.onCompleted: {
//        loader.source = ""
        console.log("onCompleted")
//        wininani.start();
    }

    onClosing: {
//        close.accepted = false;
        console.log("closing window")
        winoutani.start()
    }

    onActiveChanged: {
        if(isdump){console.log("onActiveChanged")}
    }
    onActiveFocusControlChanged: {
        if(isdump){console.log("onActiveFocusControlChanged")}
    }
    onActiveFocusItemChanged: {
        if(isdump){console.log("onActiveFocusItemChanged")}
    }
    onAfterAnimating: {
        if(isdump){console.log("onAfterAnimating")}
    }
    onAfterRendering: {
        if(isdump){console.log("onAfterRendering")}
    }
    onAfterSynchronizing: {
        if(isdump){console.log("onAfterSynchronizing")}
    }
    onBackgroundChanged: {
        if(isdump){console.log("onBackgroundChanged")}
    }
    onBeforeRendering: {
        if(isdump){console.log("onBeforeRendering")}
    }
    onBeforeSynchronizing: {
        if(isdump){console.log("onBeforeSynchronizing")}
    }
//    onClosing: {

//    }
    onColorChanged: {
        if(isdump){console.log("onColorChanged")}
    }
//    onContentDataChanged: {
//        console.log("onContentDataChanged")
//    }
//    onContentItemChanged: {
//        console.log("onContentItemChanged")
//    }
    onContentOrientationChanged: {
        if(isdump){console.log("onContentOrientationChanged")}
    }
//    onDataChanged: {
//        console.log("onDataChanged")
//    }
//    onDestroyed: {
//        console.log("onDestroyed")
//    }
//    onFlagsChanged: {
//        console.log("onFlagsChanged")
//    }
    onFocusObjectChanged: {
        if(isdump){console.log("onFocusObjectChanged")}
    }
    onFontChanged: {
        if(isdump){console.log("onFontChanged")}
    }
    onFooterChanged: {
        if(isdump){console.log("onFooterChanged")}
    }
    onFrameSwapped: {
        if(isdump){console.log("onFrameSwapped")}
    }
    onHeaderChanged: {
        if(isdump){console.log("onHeaderChanged")}
    }
    onHeightChanged: {
        if(isdump){console.log("onHeightChanged")}
    }
    onLocaleChanged: {
        if(isdump){console.log("onLocaleChanged")}
    }
    onMaximumHeightChanged: {
        if(isdump){console.log("onMaximumHeightChanged")}
    }
    onMaximumWidthChanged: {
        if(isdump){console.log("onMaximumWidthChanged")}
    }
    onMenuBarChanged: {
        if(isdump){console.log("onMenuBarChanged")}
    }
    onMinimumHeightChanged: {
        if(isdump){console.log("onMinimumHeightChanged")}
    }
    onMinimumWidthChanged: {
        if(isdump){console.log("onMinimumWidthChanged")}
    }
    onModalityChanged: {
        if(isdump){console.log("onModalityChanged")}
    }
    onObjectNameChanged: {
        if(isdump){console.log("onObjectNameChanged")}
    }
    onOpacityChanged: {
        if(isdump){console.log("onOpacityChanged")}
    }
    onOpenglContextCreated: {
        if(isdump){console.log("onOpenglContextCreated")}
    }
//    onOverlayChanged: {
//        console.log("onOverlayChanged")
//    }
    onPaletteChanged: {
        if(isdump){console.log("onPaletteChanged")}
    }
    onSceneGraphAboutToStop: {
        if(isdump){console.log("onSceneGraphAboutToStop")}
    }
    onSceneGraphError: {
        if(isdump){console.log("onSceneGraphError")}
    }
    onSceneGraphInitialized: {
        if(isdump){console.log("onSceneGraphInitialized")}
    }
    onSceneGraphInvalidated: {
        if(isdump){console.log("onSceneGraphInvalidated")}
    }
    onScreenChanged: {
        if(isdump){console.log("onScreenChanged")}
    }
    onTitleChanged: {
        if(isdump){console.log("onTitleChanged")}
    }
    onVisibilityChanged: {
        if(isdump){console.log("onVisibilityChanged: visible= "+ systemWindow.visible +" visibility=" +systemWindow.visibility)}
    }
    onVisibleChanged: {
        if(isdump){console.log("onVisibleChanged: visible= "+ systemWindow.visible +" visibility=" +systemWindow.visibility)}
        if(systemWindow.visible){
            wininani.start();
        }
    }
    onWidthChanged: {
        if(isdump){console.log("onWidthChanged")}
    }
//    onWindowChanged: {
//        console.log("onWindowChanged")
//    }
    onWindowStateChanged: {
        if(isdump){console.log("onWindowStateChanged")}
    }
    onWindowTitleChanged: {
        if(isdump){console.log("onWindowTitleChanged")}
    }
    onXChanged: {
        if(isdump){console.log("onXChanged")}
    }
    onYChanged: {
        if(isdump){console.log("onYChanged")}
    }
}
