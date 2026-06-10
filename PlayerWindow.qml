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

import QtQuick 2.0
import QtMultimedia
import Qt.labs.folderlistmodel 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
SystemWindow {
    id: root
    width: parent.width
    height: parent.height
    // 窗口生命周期 — 管理播放启停
    Connections {
        target: root
        function onAboutToShow() {
            if (getVideoCount() > 0) {
                video.source = getVideoURL(videoIndex)
            } else {
                setVideoPath(def.videoDefaultLocation)
            }
        }
        function onAboutToHide() {
            videoStop()
        }
    }

    // 视频渲染层 (声明在 UI 控件之前, z-order 最低)
    VideoOutput {
        id: videoOutput
        anchors.top: backButton.bottom
        anchors.topMargin: 10
        anchors.bottom: player.top
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        fillMode: VideoOutput.PreserveAspectFit
    }

    Define {
        id: def
        source_url: video.source
    }

    //左上角返回按钮显示视频名称
    MyIconButton {
        id: backButton
        icon_code: def.iconCode_back
        button_text: video.hasVideo ? def.getFileName() : "返回"
        button_color: "white"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        onClicked: {
            videoStop()
            root.close()
        }
    }

    //右上角选择视频文件夹按钮
    MyIconButton {
        id: openButton
        icon_code: def.iconCode_folder
        button_text: qsTr("打开文件")
        button_color: "white"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        onClicked:
        {
            if(video.hasVideo)
                videoPause()
            fileBrowser.nameFilter = def.videoNameFilters
            fileBrowser.defaultLocation = def.videoDefaultLocation
            fileBrowser.showNormal()
        }
    }

    PlayerControlBar {
        id: player
        visible: true
        width: parent.width
        enabled: video.hasVideo & (folderModel.count!=0)
        anchors.bottom: parent.bottom
        media_duration: video.duration
        onClicked_play:videoPlay()
        onClicked_pause: videoPause()
        onClicked_stop: videoStop()
        onClicked_step_backward: videoStepBackward()
        onClicked_step_forward: videoStepForward()
        onClicked_backward: videoBackward()
        onClicked_forward: videoForward()
        hourFlag: true      //时间标签带小时
        onMoved_slider:
        {
            video.setPosition(slider_value)
            videoPlay()
        }
    }

    function videoPlay()
    {
        player.playing = true;
        video.play()
    }
    function videoPause()
    {
        player.playing = false;
        video.pause();
    }
    function videoStop()
    {
        player.playing = false;
        player.media_postion = 0;
        video.stop();
    }
    function videoStepForward()
    {
        video.setPosition(video.position+10000)
    }
    function videoStepBackward()
    {
        video.setPosition(video.position-10000)
    }
    function videoBackward()
    {
        videoSwitchFlag = true;
        videoIndex -= 1;
        if(videoIndex < 0)
            videoIndex = getVideoCount()-1;
        videoStop();
        video.source = ""
        video.source = getVideoURL(videoIndex)
        console.log("上一曲:" + (videoIndex+1) + "/"  + getVideoCount() + ":" + video.source);
        videoSwitchFlag = false;
    }
    function videoForward()
    {
        videoSwitchFlag = true;
        videoIndex += 1;
        if(videoIndex >= getVideoCount())
            videoIndex = 0;
        videoStop();
        video.source = ""
        video.source = getVideoURL(videoIndex)
        console.log("下一曲:" + (videoIndex+1) + "/"  + getVideoCount() + ":" + video.source);
        videoSwitchFlag = false;
    }

    //暂停时，视频中央显示的大按钮
    MyToolButton {
        id: btn_play2
        enabled: video.hasVideo & (folderModel.count!=0)
        icon_code: def.iconCode_pause
        icon_size: 40
        icon_color: "#ffffff"
        color: "lightslategray"
        clr_exited: "darkgray"
        clr_entered: "teal"
        width: 80
        height: 80
        anchors.centerIn: parent
        onClicked: videoPlay()
        visible: video.playbackState !== MediaPlayer.PlayingState
    }
    //视频区域单击暂停播放切换
    MouseArea {
        enabled: video.hasVideo && (getVideoCount() > 0)
        anchors.top: backButton.bottom
        anchors.bottom: player.top
        anchors.left: parent.left
        anchors.right: parent.right
        onClicked: video.playbackState === MediaPlayer.PlayingState ? videoPause() : videoPlay();
    }

    //视频播放器
    MediaPlayer {
        id: video
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            volume: player.media_volume
        }
        onPositionChanged: player.media_postion = video.position
        onPlaybackStateChanged:
        {
            // 同步 UI 播放状态
            if(video.playbackState === MediaPlayer.PlayingState) {
                player.playing = true;
            } else {
                player.playing = false;
            }

            // 播放完毕自动跳转下一个 (加载但不播放)
            if(video.playbackState === MediaPlayer.StoppedState) {
                if(videoSwitchFlag === false) {
                    if(video.error === MediaPlayer.NoError && video.position > 0) {
                        console.log("video stop, auto-advance to next")
                        videoForward();
                    } else if(video.error !== MediaPlayer.NoError) {
                        console.log("video playback failed, error:", video.error,
                                    "position:", video.position, video.errorString)
                    }
                }
            }
        }
    }

    FolderListModel {
        id: folderModel
        objectName: "folderModel"
        showDirs: false
        nameFilters: def.videoNameFilters
        sortField: FolderListModel.Name
        onFolderChanged: {
            if(getVideoCount() === 0) {
                console.log("所选文件夹无视频文件:" + folderModel.folder)
                videoIndex = 0;
            }
            else {
                console.log("共发现" + getVideoCount() + "个视频文件")
                videoSwitchFlag = true;
                // 先加载后更新index
                video.source = getVideoURL(videoIndex)
                videoIndex = 0;
                videoSwitchFlag = false;
            }
        }
    }

    //自定义文件浏览器
    FileList{
        id: fileBrowser
        backButtonText: root.title
        onRejected: {
            // 取消文件选择，不自动恢复播放
        }
        onAccepted: {
            videoSwitchFlag = true;
            videoIndex = fileBrowser.fileIndex
            console.log("FileList index:"+videoIndex)
            video.source = ""
            video.source = getVideoURL(videoIndex)
            setVideoPath(fileUrl + "/");
            console.log("folder:", fileUrl + "/");
            videoSwitchFlag = false
        }
    }

    function setVideoPath(path)
    {
        console.log(path)
        folderModel.folder = path
    }
    function getVideoURL(idx)
    {
        return folderModel.get(idx, "fileUrl")
    }
    function getVideoFolder()
    {
        return folderModel.folder
    }
    function getVideoCount()
    {
        return folderModel.count
    }

    property int videoIndex: 0
    property bool videoSwitchFlag: false
}
