import QtQuick 2.0

Rectangle {
    id: root

// public
    property bool checked: false

    signal clicked(bool checked);  // onClicked:{root.checked = checked;  print('onClicked', checked)}

// private
    width: 70;  height: 22 // default size
    border.width: 0.05 * root.height
    radius:       0.5  * root.height
    color:        checked? 'green': "white" // background
    opacity:      enabled  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state

    Text {
        text:  checked?    qsTr("已打开"): qsTr("已关闭")
        font.family: "Microsoft YaHei"
        color: checked? 'white': 'black'
        x:    (checked? 0: pill.width) + (parent.width - pill.width - width) / 2
        font.pixelSize: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle { // pill
        id: pill

        x: checked? root.width - pill.width: 0 // binding must not be broken with imperative x = ...
        width: root.height;  height: width // square
        border.width: parent.border.width
        radius:       parent.radius
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        drag {
            target:   pill
            axis:     Drag.XAxis
            maximumX: root.width - pill.width
            minimumX: 0
        }

        onReleased: { // releasing at the end of drag
            if( checked  &&  pill.x < root.width - pill.width)  root.clicked(false) // right to left
            if(!checked  &&  pill.x)                            root.clicked(true ) // left  to right
        }

        onClicked: root.clicked(!checked) // emit
    }
}
