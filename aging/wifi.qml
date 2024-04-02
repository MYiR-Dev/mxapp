/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024 XuMR <2801739946@qq.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
***********************************************************************/

import QtQuick 2.7
import QtQuick.Controls 2.1
import Qt.labs.settings 1.1
import mprocess 1.0

Rectangle{
        id: frame
        anchors.top: parent.top
        anchors.left: parent.left
        border.color: "#d7cfcf"
        height: parent.height
        width: parent.width
        color: "black"

        property alias mptext: textEdit.text
        function startProcess(shell, command){
            process1.setShell(shell);
            process1.setCommand(command);
            process1.start();
        }

        function dispProcess1(){
//               textEdit.clear();
//            console.log("onReadyReadStandardOutput dispProcess1");
            textEdit.append(process1.readAllStandardOutput());
//            mptext = process1.readAllStandardOutput();
//            console.log(mptext);
        }

        Settings{
            id: settings
            property var wlancommand: "ping -I wlan0 www.baidu.com"
        }

        Flickable {
            id: flickReceive
            anchors.fill: parent
            clip: true
            anchors.margins: 5

            onWidthChanged: {
                console.log("width of Flickable is %d", width);
                textEdit.font.pixelSize = width/40;
            }

//            function ensureVisible(r)
//            {
//                if (contentX >= r.x)
//                    contentX = r.x;
//                else if (contentX+width <= r.x+r.width)
//                    contentX = r.x+r.width-width;
//                if (contentY >= r.y)
//                    contentY = r.y;
//                else if (contentY+height <= r.y+r.height)
//                    contentY = r.y+r.height-height;
//            }

//                TextEdit {
//                    id: editReceive
//                    color: "green"
//                    width: flickReceive.width
//                    focus: false
//                    wrapMode: TextEdit.Wrap
//                    font.pixelSize: 8

//                    onCursorRectangleChanged: flickReceive.ensureVisible(cursorRectangle)
//                }
            TextEdit {
                          id: textEdit
                          color: "yellow"
                          text: "bash"
                          font.pixelSize: 12
                          height: contentHeight
                          width: frame.width - vbar.width
                          y: -vbar.position * textEdit.height
                          wrapMode: TextEdit.Wrap
                          selectByKeyboard: true
                          selectByMouse: true

                          onTextChanged: {
                              if(textEdit.lineCount > 30){
                                  textEdit.clear();
                              }
                          }

                          MouseArea{
                              anchors.fill: parent
                              onWheel: {
                                  if (wheel.angleDelta.y > 0) {
                                      vbar.decrease();
                                  }
                                  else {
                                      vbar.increase();
                                  }
                              }
                              onClicked: {
                                  //textEdit.forceActiveFocus();
                                  console.log("textEdit be clicked!")
                              }
                          }
                      }

                      ScrollBar {
                          id: vbar
                          hoverEnabled: true
                          active: hovered || pressed
                          orientation: Qt.Vertical
                          size: frame.height / textEdit.height
                          width: 10
                          anchors.top: parent.top
                          anchors.right: parent.right
                          anchors.bottom: parent.bottom
                      }

        }

    QmlProcess{
        id: process1
        shell: "bash"
        command: "ping www.baidu.com"

        onStarted: {
            console.log("process1 started");
        }

        onReadyReadStandardOutput:{
            dispProcess1();
        }
        onReadyReadStandardError:{
            console.log("onReadyReadStandardErr");
            mptext = process1.readAllStandardError();
            console.log(mptext);

        }
    }


    Component.onCompleted: {
        var cmd = settings.value("wlancommand", "ping www.baidu.com")
        console.log("startProcess in wifi.qml: ", cmd);
//            if(visible === true){
            startProcess("bash", cmd);
//            }
//            else
//            {
//                startProcess("bash", "killall top");
//            }
    }

}
