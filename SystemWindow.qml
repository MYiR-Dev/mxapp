import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
Popup {
    id: systemWindow
    padding: 0
    margins: 0
    modal: false
    focus: true
    closePolicy: Popup.NoAutoClose
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
    opacity: 0
    visible: false

    property bool isdump: false
    property bool showFlag: false

    property string title: qsTr("BaseWindow")

    Image{
        anchors.fill: parent
        source: "images/wvga/home/background-dark.png"
    }

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
        running: true
        NumberAnimation { target: systemWindow; property: "opacity"; to: 1.0; duration: 200}
        NumberAnimation { target: systemWindow; property: "x"; to: -640; duration: 200}
        NumberAnimation { target: systemWindow; property: "y"; to: -360; duration: 200}
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

    onAboutToHide: {
//        close.accepted = false;
        console.log("closing window")
        showFlag = false
        winoutani.start()
    }

    onAboutToShow: {
        wininani.start();
    }

//    onActiveChanged: {
//        if(isdump){console.log("onActiveChanged")}
//    }
//    onActiveFocusControlChanged: {
//        if(isdump){console.log("onActiveFocusControlChanged")}
//    }
//    onActiveFocusItemChanged: {
//        if(isdump){console.log("onActiveFocusItemChanged")}
//    }
//    onAfterAnimating: {
//        if(isdump){console.log("onAfterAnimating")}
//    }
//    onAfterRendering: {
//        if(isdump){console.log("onAfterRendering")}
//    }
//    onAfterSynchronizing: {
//        if(isdump){console.log("onAfterSynchronizing")}
//    }
//    onBackgroundChanged: {
//        if(isdump){console.log("onBackgroundChanged")}
//    }
//    onBeforeRendering: {
//        if(isdump){console.log("onBeforeRendering")}
//    }
//    onBeforeSynchronizing: {
//        if(isdump){console.log("onBeforeSynchronizing")}
//    }
//    onClosing: {

//    }
//    onColorChanged: {
//        if(isdump){console.log("onColorChanged")}
//    }
//    onContentDataChanged: {
//        console.log("onContentDataChanged")
//    }
//    onContentItemChanged: {
//        console.log("onContentItemChanged")
//    }
//    onContentOrientationChanged: {
//        if(isdump){console.log("onContentOrientationChanged")}
//    }
//    onDataChanged: {
//        console.log("onDataChanged")
//    }
//    onDestroyed: {
//        console.log("onDestroyed")
//    }
//    onFlagsChanged: {
//        console.log("onFlagsChanged")
//    }
//    onFocusObjectChanged: {
//        if(isdump){console.log("onFocusObjectChanged")}
//    }
//    onFontChanged: {
//        if(isdump){console.log("onFontChanged")}
//    }
//    onFooterChanged: {
//        if(isdump){console.log("onFooterChanged")}
//    }
//    onFrameSwapped: {
//        if(isdump){console.log("onFrameSwapped")}
//    }
//    onHeaderChanged: {
//        if(isdump){console.log("onHeaderChanged")}
//    }
//    onHeightChanged: {
//        if(isdump){console.log("onHeightChanged")}
//    }
//    onLocaleChanged: {
//        if(isdump){console.log("onLocaleChanged")}
//    }
//    onMaximumHeightChanged: {
//        if(isdump){console.log("onMaximumHeightChanged")}
//    }
//    onMaximumWidthChanged: {
//        if(isdump){console.log("onMaximumWidthChanged")}
//    }
//    onMenuBarChanged: {
//        if(isdump){console.log("onMenuBarChanged")}
//    }
//    onMinimumHeightChanged: {
//        if(isdump){console.log("onMinimumHeightChanged")}
//    }
//    onMinimumWidthChanged: {
//        if(isdump){console.log("onMinimumWidthChanged")}
//    }
//    onModalityChanged: {
//        if(isdump){console.log("onModalityChanged")}
//    }
//    onObjectNameChanged: {
//        if(isdump){console.log("onObjectNameChanged")}
//    }
//    onOpacityChanged: {
//        if(isdump){console.log("onOpacityChanged")}
//    }
//    onOpenglContextCreated: {
//        if(isdump){console.log("onOpenglContextCreated")}
//    }
////    onOverlayChanged: {
////        console.log("onOverlayChanged")
////    }
//    onPaletteChanged: {
//        if(isdump){console.log("onPaletteChanged")}
//    }
//    onSceneGraphAboutToStop: {
//        if(isdump){console.log("onSceneGraphAboutToStop")}
//    }
//    onSceneGraphError: {
//        if(isdump){console.log("onSceneGraphError")}
//    }
//    onSceneGraphInitialized: {
//        if(isdump){console.log("onSceneGraphInitialized")}
//    }
//    onSceneGraphInvalidated: {
//        if(isdump){console.log("onSceneGraphInvalidated")}
//    }
//    onScreenChanged: {
//        if(isdump){console.log("onScreenChanged")}
//    }
//    onTitleChanged: {
//        if(isdump){console.log("onTitleChanged")}
//    }
//    onVisibilityChanged: {
//        if(isdump){console.log("onVisibilityChanged: visible= "+ systemWindow.visible +" visibility=" +systemWindow.visibility)}
//    }
    onVisibleChanged: {
        if(isdump){console.log("onVisibleChanged: visible= "+ systemWindow.visible +" visibility=" +systemWindow.visibility)}
    }
    onWidthChanged: {
        if(isdump){console.log("onWidthChanged")}
    }
//    onWindowChanged: {
//        console.log("onWindowChanged")
//    }
//    onWindowStateChanged: {
//        if(isdump){console.log("onWindowStateChanged")}
//    }
//    onWindowTitleChanged: {
//        if(isdump){console.log("onWindowTitleChanged")}
//    }
    onXChanged: {
        if(isdump){console.log("onXChanged")}
    }
    onYChanged: {
        if(isdump){console.log("onYChanged")}
    }
}
