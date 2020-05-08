import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
Rectangle {

    width: delegate_width
    height: delegate_height
    color:"transparent"
    property var modeldata: ["1", "2", "3","4", "5", "6","7", "8", "9","10", "11", "12",
                       "13", "14", "15","16", "17", "18","19", "20", "21","22", "23", "24"]
    property var verticalAlig:""
    property var combox_bg:"images/wvga/system/day-rec.png"
    property int delegate_width:47
    property int delegate_height:28
    property alias combox_control:control
    ComboBox {
        id: control
        model: modeldata
        width:delegate_width
        font.family: "Microsoft YaHei"
        delegate: ItemDelegate {
            width: control.width

            contentItem: Text {
                text: modelData
                color: "white"
                font: control.font

                elide: Text.ElideRight
//                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                border.color: "transparent"
                color:control.pressed? "#059EC9":"transparent"
//                radius: 2
            }

            highlighted:  control.highlightedIndex == index


        }

        indicator: Canvas {
            id: canvas
            x: control.width - width - control.rightPadding
            y: control.topPadding + (control.availableHeight - height) / 2
            width: 8
            height: 4
            contextType: "2d"

            Connections {
                target: control
                onPressedChanged: canvas.requestPaint()
            }

            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fillStyle = control.pressed ? "white" : "white";
                context.fill();
            }
        }

        contentItem: Text {
//                                leftPadding: 0
//                                rightPadding: control.indicator.width + control.spacing

            text: control.displayText
            font: control.font
            color: control.pressed ? "white" : "white"
            verticalAlignment: Text.AlignVCenter
            anchors{
                centerIn: parent
            }
        }

        background: Rectangle {
            implicitWidth: delegate_width
            implicitHeight: delegate_height
//                                border.color: control.pressed ? "#17a81a" : "#21be2b"
//                                border.width: control.visualFocus ? 2 : 1
            color:"transparent"
            Image {
                anchors.fill: parent
                source: combox_bg
            }
            radius: 2
        }

        popup: Popup {
            y: control.height-1
            width: control.width
            implicitHeight: listview.contentHeight
            padding: 1

            contentItem: ListView {
                id: listview
                clip: true
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex
                highlight: Rectangle { color: "#059EC9" }
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
//                border.color: "#059EC9"
                color: "#003245"
                radius: 2
            }
        }
    }

}
