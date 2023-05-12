import QtQuick 2.0
import CustomPlot 1.0

Item {
    id: plotForm
//    opacity: 0.2

    CustomPlotItem {

        id: customPlot
        anchors.fill: parent
        Component.onCompleted: initCustomPlot()
    }
}
