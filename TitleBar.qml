import QtQuick 2.0

Item {
    id:root
    anchors{
        top: parent.top
        left: parent.left
    }

    TitleLeftBar{
        id: leftBar
        titleIcon: "images/LOGO.png"
        titleIconWidth: 172
        titleIconHeight: 35
        titleNameSize: 20
        titleName: "Make Your Ideal Real!"

        onLeftBarClicked: {
            supportWnd.item.open()
        }

    }

    TitleRightBar{
        anchors{
            top: parent.top
            right: parent.right
//            topMargin: 10
//            rightMargin: 10
        }
    }

//    SupportPop {
//        id:popupFrame1
//    }
}
