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

Item {
    width: parent.width
    height: parent.height

    BusyIndicator{
        id:busyIndicator
        anchors.centerIn: parent;
        running: true;
    }
    Label{
        anchors.top: busyIndicator.bottom;
        anchors.horizontalCenter: parent.horizontalCenter;
        text: qsTr("开发中......");
        font.family: "Microsoft YaHei";
        font.pointSize: 18;
        color: "#828385";
        verticalAlignment:Label.AlignVCenter;
        horizontalAlignment: Label.AlignHCenter;
    }
}
