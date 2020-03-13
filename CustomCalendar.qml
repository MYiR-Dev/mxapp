import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
Rectangle {
    id:mx_calendar
    Calendar{
            id: m_calendar
            //anchors.centerIn: parent
            frameVisible: false
            navigationBarVisible: true
            weekNumbersVisible: false
            minimumDate: new Date(2018, 0, 1);
            maximumDate: new Date(2025, 0, 1);
            anchors{
                fill: parent
            }
            onClicked:
            {
                //m_calendar.visible = false;
            }

            style: CalendarStyle {
                gridVisible: false
                background: Image {//日历背景
                    id: bg
                    anchors.fill: parent
                    source: "./image/dataRect.png"
                }

                dayOfWeekDelegate://周的显示
                    Rectangle{
                        id: rec1
                        color: "transparent"
                        height: 20

                        Text {
                            id: weekTxt
                            font.pixelSize: 15
                            text:Qt.locale().dayName(styleData.dayOfWeek, control.dayOfWeekFormat)//转换为自己想要的周的内容的表达
                            anchors.centerIn: rec1
                            color: styleData.selected?"green":"gray"
                        }
                }

                navigationBar:

                    Rectangle {//导航控制栏，控制日期上下选择等
                        color: "transparent"
                        height: 40


//                        ToolButton {//按钮:显示上一个月
//                            id: previousMonth
//                            width: parent.height
//                            height: width-20
//                            anchors.verticalCenter: parent.verticalCenter
//                            anchors.left: parent.left
//                            anchors.leftMargin: 40
//                            iconSource: "./image/back_icon_p.png"
//                            onClicked: control.showPreviousMonth()
//                        }
                        RowLayout{
                            id:row_layout
                            width:100
                            height:30
                            anchors{

                                left:    parent.left
                                leftMargin: 10

                            }
                            CustomCombox{
                                id:combox_year
                                delegate_width:60
                                modeldata: ["1月", "2月", "3月","4月", "5月", "6月","7月", "8月", "9月","10月",
                                            "11月", "12月"]
                            }
                            CustomCombox{
                                id:combox_moth
                                delegate_width:60
                                modeldata: ["1日", "2日", "3日","4日", "5日", "6日","7日", "8日", "9日","10日",
                                            "11日", "12日", "13日","14日", "15日", "16日","17日", "18日", "19日","20日",
                                            "21日", "22日", "23日","24日", "25日", "26日","27日", "28日", "29日","30日"]
                            }
                        }

//                        Label {//显示年月
//                            id: dateText
//                            text: styleData.title
//                            font.pixelSize: 24
//                            font.bold: true
//                            horizontalAlignment: Text.AlignHCenter
//                            verticalAlignment: Text.AlignVCenter
//                            fontSizeMode: Text.Fit
//                            anchors.verticalCenter: parent.verticalCenter
//                            anchors.left: previousMonth.right
//                            anchors.leftMargin: 2
//                            anchors.right: nextMonth.left
//                            anchors.rightMargin: 2
//                            color: "white"
//                        }

//                        ToolButton {//按钮:显示下一个月
//                            id: nextMonth
//                            width: 60
//                            height: 53
//                            anchors.verticalCenter: parent.verticalCenter
//                            anchors.right: parent.right
//                            anchors.rightMargin: 40
//                            iconSource: "./image/back_icon_p.png"
//                            onClicked: control.showNextMonth()

//                            style: ButtonStyle {
//                                    background: Item {
//                                        implicitWidth: 25
//                                        implicitHeight: 25
//                                    }
//                                }
//                        }

                    }

                dayDelegate://显示日期
                    Rectangle{
                    color: "transparent"
                    Image
                    {
                        id: day_bg
                        height: 28
                        width: 28
                        anchors.centerIn: parent
    //                                        anchors.centerIn: parent
                        source: styleData.selected ? "images/wvga/system/current-dat-bg.png" : ""
                    }

                    Label {
                        id: m_label
                        text: styleData.date.getDate()
                        font.pixelSize: 15
                        anchors.centerIn: parent
                        color: styleData.selected ? "yellow" :  (styleData.visibleMonth && styleData.valid ? "lightblue" : "grey");
                           }
                    }
             }
        }

}
