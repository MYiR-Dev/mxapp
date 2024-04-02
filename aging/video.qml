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
import QtMultimedia 5.9
import mvideooutput 1.0
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.2
import QtQuick.Layouts 1.3

Rectangle{
    anchors.fill: parent
    color: "green"
	
    Settings
    {
        id: settings
        property var videosrc: "file:///usr/share/myir/Video/ST2297_visionv34.mp4"
    }


    //视频输出到背景
    MVideoOutput {
        width: parent.width
        height: parent.height
        source: video
    }

    //视频播放器
    MediaPlayer {
        id: video
        autoLoad: true
        autoPlay: true
        source: "file:///usr/share/myir/Video/ST2297_visionv34.mp4"
        onPlaybackStateChanged: //1:playing, 2:pause, 0:stop
        {
            if( video.playbackState === MediaPlayer.StoppedState ) //播放完成自动停止
            {
                console.log("video stop")
                video.stop()
				video.source=""
                video.source="file:///usr/share/myir/Video/ST2297_visionv34.mp4"
				video.play()
            }
        }
    }
}
