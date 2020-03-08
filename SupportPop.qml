import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Popup {
    id:supportpop

    // 标题栏高度
    property int titleBarHeight: 35
    // 标题
    property string title: ""
    // 最小宽度
    property int minWidth: 200
    // 最小高度
    property int minHeight: 0
    // 最大宽度
    property int maxWidth: parent.width
    // 最大高度
    property int maxHeight: parent.height
    // 是否可拉伸
    property bool stretchable: true
    // 记录当前坐标
//    property point nowPoint: Qt.point(popup.x, popup.y)
    // 记录父组件的大小
    property size nowParentSize: Qt.size(parent.width, parent.height)
    // 位置变化信号
    signal pointChanged(point p)
    // 大小变化信号
    signal sizeChanged(size z)

    padding: 0
    margins: 0
    modal: false
    focus: true
    closePolicy: Popup.NoAutoClose
    width: 800
    height: 480
    // 标题区域
    Rectangle {
        id: titleBox
        anchors.margins: 0
        width: parent.width
        height: titleBarHeight

        // 标题
        Text {
            anchors.centerIn: parent
            text: title
        }
        // 标题栏拖拽
        MouseArea {
            property point clickPoint: "0,0"
            anchors.fill: parent
            anchors.left: parent.left
            acceptedButtons: Qt.LeftButton
            onPressed: {
                // 按下
                clickPoint  = Qt.point(mouse.x, mouse.y)
                // 将当前弹窗置于顶层
                popup.z = (new Date()).getTime()
            }
            onPositionChanged: {
                // 按下位置变化
                var offset = Qt.point(mouse.x - clickPoint.x, mouse.y - clickPoint.y)
                setDlgPoint(offset.x, offset.y)
            }
            onReleased: {
                // 释放
                emit: pointChanged(Qt.point(popup.x, popup.y))
            }
        }
        // 关闭按钮
        RoundButton {
            id: closeBtn
            width: parent.height
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.margins: 5
            padding: 5
            text: "×"
            onClicked: { supportpop.close() }
        }
    }
    // 分割线
    Rectangle {
        width: parent.width
        height: 1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: titleBox.height
        color: "#EEEEEE"
    }
}

