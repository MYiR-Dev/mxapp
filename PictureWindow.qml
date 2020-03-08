import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2

SystemWindow {
    id: pictureWindow
    title: "picture"


    // Button to open the main application window
    Button {
        text: qsTr("picture window")
        width: 180
        height: 50
        anchors.centerIn: parent
        onClicked: {
            pictureWindow.close() // invoke signal
        }
    }

    Rectangle {
        id: rect
        width: 100; height: 100
        color: "red"

        PropertyAnimation on x { to: 100

        }
//        onXChanaged: {

//        }
        PropertyAnimation {target: rect; to: 100
//            onYChanged:{

//            }
        }
    }


    Rectangle {
        width: 75; height: 75; radius: width
        id: ball
        color: "salmon"

        Behavior on x {
            NumberAnimation {
                id: bouncebehavior
                easing {
                    type: Easing.OutElastic
                    amplitude: 1.0
                    period: 0.5
                }
            }
        }
        Behavior on y {
            animation: bouncebehavior
        }
        Behavior {
            ColorAnimation { target: ball; duration: 3000 }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                y=10
                x=10
        }
        }

    }

    Rectangle {
        id: banner
        anchors.top: ball.bottom
        width: 150; height: 100; border.color: "black"

        Column {
            anchors.centerIn: parent
            Text {
                id: code
                text: "Code less."
                opacity: 0.01
            }
            Text {
                id: create
                text: "Create more."
                opacity: 0.01
            }
            Text {
                id: deploy
                text: "Deploy everywhere."
                opacity: 0.01
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: playbanner.start()
        }

        SequentialAnimation {
            id: playbanner
            running: false
            NumberAnimation { target: code; property: "opacity"; to: 1.0; duration: 200}
            NumberAnimation { target: create; property: "opacity"; to: 1.0; duration: 200}
            NumberAnimation { target: deploy; property: "opacity"; to: 1.0; duration: 200}
        }
    }
}
