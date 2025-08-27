/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024

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

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

import QtQuick
import MyFunction.module 1.0
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts

SystemWindow {
    id: root
    width: def.win_width
    height: def.win_height
    property string iconCode_back: "\uf053"             //返回图标

    Define {
        id: def
    }

    //左上角返回按钮
    MyIconButton {
        id: backButton
        icon_code: iconCode_back
        button_text: qsTr("返回")
        button_color: "white"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        onClicked: root.close()
    }
}

