import Qt.labs.settings 1.0
import QtQml 2.2
import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Controls.Private 1.0 as QQCPrivate
import QtQuick.Controls.Styles 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
import QtWebKit 3.0
import GetSystemInfoAPI 1.0
import QtQuick.VirtualKeyboard 2.2
import QtQuick.VirtualKeyboard.Settings 2.2
SystemWindow {
    id: browserWindow
    title: "browser"
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: adaptive_width
    height: adaptive_height
    TitleLeftBar{
        id: leftBar
        titleIcon: "images/wvga/back_icon_nor.png"
        titleName: qsTr("浏览器")
        titleNameSize: 20
        titleIconWidth:120
        titleIconHeight: 30
        onLeftBarClicked: {
            browserWindow.close()
//            info_timer.stop()
        }

    }
    GetSystemInfo{
        id:getSyetemInfo

    }
    TitleRightBar{
        anchors{
            top: parent.top
            right: parent.right
            rightMargin: 10
        }
    }
    Rectangle{
        anchors{
            top: parent.top
            topMargin: 55
        }
        focus: true
        color:"#F5F5F5"
        width:adaptive_width
        height:adaptive_height/1.14
        property alias currentWebView: webView

        visible: true
        InputPanel {
            id: inputPanel
            x: adaptive_width/8
            y: adaptive_height/1.06
            z:99
            anchors.left: parent.left
            anchors.right: parent.right
            states: State {
                name: "visible"
                when: inputPanel.active
                PropertyChanges {
                    target: inputPanel
                    y: adaptive_height/1.06 - inputPanel.height
                }
            }
            transitions: Transition {
                id: inputPanelTransition
                from: ""
                to: "visible"
                reversible: true
                enabled: !VirtualKeyboardSettings.fullScreenMode
                ParallelAnimation {
                    NumberAnimation {
                        properties: "y"
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            Binding {
                target: InputContext
                property: "animating"
                value: inputPanelTransition.running
            }
                AutoScroller {}
        }
        Rectangle{
            id:dddd
            color:"#D3D3D3"
            width:adaptive_width
            height:28
            anchors{

                top: parent.top
                topMargin: 5
            }

            Label{
                id:addressLable
                width:35
                height:25

                  anchors{
                      left: parent.left
                      leftMargin: 5
                      top: parent.top
                      topMargin: 5
                  }
                  font.pixelSize: 12
                  text: qsTr("地址:")
                  font.family: "Microsoft YaHei"
//                  font.bold: true
            }
            TextField {
                id: addressInput
                width:adaptive_width/1.25
                height:25
                anchors{
                    left: addressLable.right
                    leftMargin: 5
                    top: parent.top
                    topMargin: 1
                }
                style: TextFieldStyle {
                    padding {
                        left: 26;
                    }
                }
                focus: true
                Layout.fillWidth: true
                text: webView && webView.url
                font.family: "Microsoft YaHei"
                onAccepted: {
                    webView.url = getSyetemInfo.fromUserInput(text)
                }
            }
            Rectangle{
                id:goButton
                anchors{
                    left: addressInput.right
                    leftMargin: 5
                    top: parent.top
                    topMargin: 1
                }
                width:adaptive_width/16
                height:25
                color:"#C0C0C0"
                focus: true
                Text{

                    text: qsTr("开始")
                    font.pixelSize: 12;
                    font.family: "Microsoft YaHei"
//                    font.bold: true
//                    color: "white"
                    anchors{
                        centerIn: parent
                    }
                }
                MouseArea{
                    anchors.fill: parent;
                    focus: true
                    onClicked: {
                        addressInput.focus= false
                        goButton.opacity = 0.5
                        webView.url = getSyetemInfo.fromUserInput(addressInput.text)
//                        webView.load;
                    }
                    onExited:{
                       goButton.opacity = 1.0
                    }
                    onPressed: {

                       goButton.opacity = 0.5
                    }
                }
            }
            Rectangle{
                id:refreshButton
                anchors{
                    left: goButton.right
                    leftMargin: 5
                    top: parent.top
                    topMargin: 1
                }

                width:adaptive_width/16
                height:25
                color:"#C0C0C0"
                Text{

                    text: qsTr("刷新")
                    font.pixelSize: 12;
                    font.family: "Microsoft YaHei"
//                    font.bold: true
//                    color: "white"
                    anchors{
                        centerIn: parent
                    }
                }
                MouseArea{
                    anchors.fill: parent;
                    focus: true
                    onClicked: {
                        addressInput.focus= false
                        refreshButton.opacity = 0.5
                        webView && webView.loading ? webView.stop() : webView.reload()
                    }
                    onExited:{
                       refreshButton.opacity = 1.0
                    }
                    onPressed: {

                       refreshButton.opacity = 0.5
                    }
                }
            }


        }
        ScrollView {
            width: adaptive_width
            height: adaptive_height
            anchors{
                top: dddd.bottom
                topMargin: 35
                fill: parent
            }
            WebView {
                id: webView
                url: "http://www.myir-tech.com/"
                onNavigationRequested: {
                    // detect URL scheme prefix, most likely an external link
                    var schemaRE = /^\w+:/;
                    if (schemaRE.test(request.url)) {
                        request.action = WebView.AcceptRequest;

                    } else {
                        request.action = WebView.IgnoreRequest;

//                         delegate request.url here
                    }
                }


            }

        }




    }
}
