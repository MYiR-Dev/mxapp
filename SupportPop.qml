import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Popup {
    id: supportpopup

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
    property point nowPoint: Qt.point(popup.x, popup.y)
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
//    Material.elevation: 3

    Component.onCompleted: {
        // 忽略标题栏高度
        height = height + titleBox.height + 1
        // 关联父组件大小变化
//        parent.heightChanged.connect(onParentSizeChangerd)
//        parent.widthChanged.connect(onParentSizeChangerd)
        // 检验父类窗口
//        onParentSizeChangerd()
    }

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
            onClicked: { supportpopup.close() }
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
//    //窗口拉伸
//    CustomMouseArea{
//        id:left;
//        type: 3;
//        height: parent.height
//        anchors.left: parent.left
//        anchors.leftMargin: 0
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id:right;
//        type: 4;
//        height: parent.height
//        anchors.right: parent.right
//        anchors.rightMargin: 0
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id:top;
//        type: 1;
//        width: parent.width
//        anchors.left: parent.left
//        anchors.leftMargin: 0
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id:bottom;
//        type: 2;
//        width: parent.width
//        anchors.left: parent.left
//        anchors.leftMargin: 0
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id:topLeft;
//        type: 5;
//        anchors.left: parent.left
//        anchors.leftMargin: 0
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id:topRight;
//        type: 6;
//        anchors.right: parent.right
//        anchors.rightMargin: 0
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id: bottomLeft
//        anchors.left:parent.left
//        anchors.leftMargin: 0
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 0
//        parentObj: popup;
//        type: 7
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }
//    CustomMouseArea{
//        id:bottomRight;
//        type: 8;
//        anchors.right: parent.right
//        anchors.rightMargin: 0
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 0
//        parentObj: popup;
//        minHeight: popup.minHeight + titleBox.height + 1
//        minWidth: popup.minWidth
//        maxHeight: popup.maxHeight + titleBox.height + 1
//        maxWidth: popup.maxWidth
//        visible: stretchable

//        onReleased: {
//            emit: pointChanged(Qt.point(popup.x, popup.y))
//            emit: sizeChanged(Qt.size(popup.width, popup.height))
//        }
//    }

//    // 拖拽窗口
//    function setDlgPoint(dlgX ,dlgY)
//    {
//        //设置窗口拖拽不能超过父窗口
//        if(popup.x + dlgX < 0)
//        {
//            popup.x = 0
//        }
//        else if(popup.x + dlgX > popup.parent.width - popup.width)
//        {
//            popup.x = popup.parent.width - popup.width
//        }
//        else
//        {
//            popup.x = popup.x + dlgX
//        }
//        if(popup.y + dlgY < 0)
//        {
//            popup.y = 0
//        }
//        else if(popup.y + dlgY > popup.parent.height - popup.height)
//        {
//            popup.y = popup.parent.height - popup.height
//        }
//        else
//        {
//            popup.y = popup.y + dlgY
//        }
//        nowPoint  = Qt.point(popup.x, popup.y)
//    }

    /**
     * @Title: onParentSizeChangerd方法
     * @Description: 监听父组件大小变化
     * @author XueLong xuelongqy@foxmail.com
     * @date 2018-04-09 10:31:20
     * @update_author
     * @update_time
     * @version V1.0
    */
//    function onParentSizeChangerd() {
//        // 不能大于父组件
//        if (parent.height < popup.height) {
//            popup.height = parent.height
//        }
//        if (parent.width < popup.width) {
//            popup.width = parent.width
//        }
//        // 以父组件一般为基准,坐标超过及基于后半位置调整
//        if (popup.width / 2 + nowPoint.x > nowParentSize.width / 2) {
//            nowPoint.x = nowPoint.x + parent.width - nowParentSize.width
//        }
//        if (nowPoint.y > nowParentSize.height / 2) {
//            nowPoint.y = nowPoint.y + parent.height - nowParentSize.height
//        }
//        popup.x = nowPoint.x
//        popup.y = nowPoint.y
//        nowParentSize = Qt.size(parent.width, parent.height)
//        // 发送位置和大小改变信号
//        emit: pointChanged(nowPoint)
//        emit: sizeChanged(Qt.size(popup.width, popup.height))
//    }
}

//import QtQuick 2.11
//import QtQuick.Controls 2.2
//import QtQuick.Controls.Material 2.4
//import QtQuick.Layouts 1.11

//Page {
//    id:root
//    width: 500
//    height: 800
//    Material.background: "white"

//    ListView{
//        id:listView
//        anchors.fill: parent
//        anchors.top: parent.top
//        anchors.topMargin:20
//        spacing: 20
//        Material.background: "white"
//        model: ListModel{
//            id:listModel
//        }
//        delegate: list_delegate
//    }

//    Component.onCompleted: {
//        addModelData("class A","2018.2.1","aaa","13kb")
//        addModelData("class B","2018.2.4","ddd","43kb")
//        addModelData("class A","2018.2.2","bbb","23kb")
//        addModelData("class A","2018.2.3","ccc","33kb")
//        addModelData("class B","2018.2.5","eee","53kb")
//        addModelData("class C","2018.2.6","fff","675kb")
//        addModelData("class C","2018.2.7","ggg","45kb")
//    }

//    Component{
//        id:list_delegate

//        Column{
//            id:objColumn

//            Component.onCompleted: {
//                for(var i = 1; i < objColumn.children.length - 1; ++i) {
//                    objColumn.children[i].visible = false
//                }
//            }

//            MouseArea{
//                width:listView.width
//                height: objItem.implicitHeight
//                enabled: objColumn.children.length > 2
//                onClicked: {
//                    console.log("onClicked..")
//                    var flag = false;
//                    for(var i = 1; i < parent.children.length - 1; ++i) {
//                        console.log("onClicked..i=",i)
//                        flag = parent.children[i].visible;
//                        parent.children[i].visible = !parent.children[i].visible
//                    }
//                    console.log("onClicked..flag = ",flag)
//                    if(!flag){
//                        iconAin.from = 0
//                        iconAin.to = 90
//                        iconAin.start()
//                    }
//                    else{
//                        iconAin.from = 90
//                        iconAin.to = 0
//                        iconAin.start()
//                    }
//                }
//                Row{
//                    id:objItem
//                    spacing: 10
//                    leftPadding: 20

//                    Image {
//                        id: icon
//                        width: 10
//                        height: 20
//                        source: "icon_retract.png"
//                        anchors.verticalCenter: parent.verticalCenter
//                        RotationAnimation{
//                            id:iconAin
//                            target: icon
//                            duration: 100
//                        }
//                    }
//                    Label{
//                        id:meeting_name
//                        text: meetingName
//                        font.pixelSize: fontSizeMedium
//                        anchors.verticalCenter: parent.verticalCenter
//                    }
//                    Label{
//                        text: date
//                        font.pixelSize: fontSizeMedium
//                        color:"grey"
//                        anchors.verticalCenter: parent.verticalCenter

//                    }
//                }
//            }
//            Repeater {
//               model: subNode

//               delegate: Rectangle{
//                   width: 500
//                   height: 120
//                   Rectangle {
//                       id: fileicon
//                       width: 80
//                       height: 80
//                       color:index%2?"red":"yellow"
//                       anchors{
//                           left: parent.left
//                           leftMargin: 20
//                           verticalCenter: parent.verticalCenter
//                       }
//                   }
//                   Column{
//                       anchors{
//                           left: fileicon.right
//                           leftMargin: 20
//                           top: parent.top
//                           topMargin:20
//                       }
//                       topPadding: 10
//                       spacing: 10

//                       Label{
//                           text: model.fileName
//                           font.pixelSize: fontSizeMedium
//                       }
//                       Label{
//                           text: model.size
//                           font.pixelSize: fontSizeMedium
//                           color: "grey"
//                       }
//                   }

//                   RoundButton{
//                       id:download
//                       width: 90
//                       height: 40
//                       highlighted: true
//                       radius: height/2.
//                       text: qsTr("View")
//                       anchors{
//                           right: parent.right
//                           rightMargin: 30
//                           verticalCenter: parent.verticalCenter
//                       }
//                   }
//               }
//            }
//        }
//    }


//    function addModelData(meetingName,date,fileName,size){
//        var index = findIndex(meetingName)
//        if(index === -1){
//            listModel.append({"meetingName":meetingName,"date":date,"level":0,
//                                 "subNode":[{"fileName":fileName,"size":size,"level":1,"subNode":[]}]})
//        }
//        else{
//            listModel.get(index).subNode.append({"fileName":fileName,"size":size,"level":1,"subNode":[]})
//        }

//    }

//    function findIndex(name){
//        for(var i = 0 ; i < listModel.count ; ++i){
//            if(listModel.get(i).meetingName === name){
//                return i
//            }
//        }
//        return -1
//    }
//}
