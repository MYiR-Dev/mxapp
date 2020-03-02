import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {

    visible: true

    width: 800
    height: 480
    title: qsTr("Hello QCustomPlot in QML")

//    Item {
//        id: mainView
//        anchors.fill: parent
//        PlotView {
//        }
//    }
    Image {
        id: rocket
        fillMode: Image.TileHorizontally
        smooth: true
        source: 'images/wvga/ecg/ecg_pic_bg.jpg'
    }
    Rectangle{
        x:0
        y:33
        opacity: 0.3
        width: 573
        height: 451
        SwipeView {
            id: swipeView

            anchors.fill: parent
            currentIndex: tabBar.currentIndex
            interactive: false

            PlotView {

            }

            Page {
//                Label {
//                    text: qsTr("This is implementation of http://www.qcustomplot.com/index.php/support/forum/172\n" +
//                               "Adding random data on 500 ms tick to plot")
//                    anchors.centerIn: parent
//                }
            }
        }

     }


//    footer: TabBar {
//        id: tabBar
//        currentIndex: swipeView.currentIndex
//        TabButton {
//            text: qsTr("Plot")
//        }
//        TabButton {
//            text: qsTr("Info")
//        }
//    }
}
