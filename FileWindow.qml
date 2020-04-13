import QtQuick 2.1


import Qt.labs.folderlistmodel 2.1
SystemWindow {
    id: fileWindow
    title: "file"

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: "文件浏览器"
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            fileWindow.close()
//            info_timer.stop()
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
        width: 800
        height: 430
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
