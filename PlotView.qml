import QtQuick 2.0
import CustomPlot 1.0

Item {
    id: plotForm
//    opacity: 0.2
    Image {
        id: rocket
        fillMode: Image.TileHorizontally
        smooth: true
        source: 'images/wvga/ecg/display_bg.png'
    }
    Text {
        id: text
        text: qsTr("Plot form")
    }

    CustomPlotItem {

        id: customPlot
        anchors.fill: parent

        Component.onCompleted: initCustomPlot()
    }
}
