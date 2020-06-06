import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
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
            mainloader.source = "SupportWindow.qml"
//            mainloader.item.show()
//            mainloader.item.requestActivate()
            mainloader.item.open()
        }

    }

    property bool checked: false
    property string language_icon:"\uf1ab"
    Rectangle{
        id:languageBt
        width: 85
        height: 25
        radius: 10
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 100
        color:"#02b9db"
        Text {
            id: icon
            font.family: "FontAwesome"
            font.pixelSize: 12
            text: language_icon //图标
            color: "white"
            opacity: 1.0        //不透明
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
//            anchors.centerIn: root
        }
        Text {
            id : textEnglish
            text: checked? qsTr("中文"): qsTr("English")
            color: "white"
            font.pointSize: 12
            font.family:"Microsoft YaHei"
            anchors.left: icon.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Screen.desktopAvailableWidth/96
        }

        MouseArea{
            anchors.fill: parent

            onClicked: {
                checked = !checked
                console.log(checked)
                if(checked)
                   translator.loadLanguage("English");
                else
                   translator.loadLanguage("Chinese");
            }
        }
//        style: buttonStyle
    }
    TitleRightBar{
        id:rightBar
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
