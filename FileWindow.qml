import QtQuick 2.1
import QtQuick.Window 2.2

import Qt.labs.folderlistmodel 2.1
SystemWindow {
    id: fileWindow
    title: "file"
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: mainWnd.width
    height: mainWnd.height
    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("文件浏览器")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            fileWindow.close()
        }
    }

    TitleRightBar{
        anchors{
            top: parent.top
            right: parent.right
            rightMargin: 10
        }
    }
    FileBrowser {
        id: imageFileBrowser
        folder:"file:///"
        anchors.fill: parent
        width: adaptive_width
        height: adaptive_height/*/1.16*/
        anchors{
            top: parent.top
            topMargin: 50
        }
//        Component.onCompleted: fileSelected.connect(content.openImage)
    }
//    MouseArea {
//        anchors.fill: parent
//        onClicked: imageFileBrowser.show()
//    }
    Component.onCompleted:imageFileBrowser.show()
}
