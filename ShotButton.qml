import QtQuick 2.2
import QtQuick.Controls 2.2

DelayButton {
    id: root
    delay: 3000
    width: 50
    height: 50

    onProgressChanged: canvas.requestPaint()

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20

    background: Rectangle {
        id: backgroundRec
        width: root.width
        height: width
        radius: width
        color: "white"
        anchors.centerIn: parent

        Rectangle {
            width: root.width - 6
            height: width
            radius: width/2
            color: "black"
            anchors.centerIn: parent

            Rectangle {
                width: root.width - 12
                height: width
                radius: width/2
                color: "white"
                anchors.centerIn: parent
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#6de25d"
                ctx.lineWidth = 4
                ctx.beginPath()
                var startAngle = -Math.PI/2
//                var endAngle = startAngle + ((down) ? root.progress : 0) * Math.PI * 2
                var endAngle = startAngle + root.progress * Math.PI * 2
                ctx.arc(width / 2, height / 2, width / 2 - ctx.lineWidth / 2 - 3, startAngle, endAngle)
                ctx.stroke()
            }
        }
    }
}
