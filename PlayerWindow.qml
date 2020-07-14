import QtQuick 2.0
import QtMultimedia 5.9
import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import mvideooutput 1.0

SystemWindow {
    id: root
    width: def.win_width
    height: def.win_height
//    title: qsTr("视频")
//    flags: Qt.Dialog        //Dialog,没有最大最小化按钮

//    //第一次打开时才会重新加载
//    function show()
//    {
//        open()
//    }

//    property bool showFlag: false
//    onAboutToHide: showFlag = false
    onVisibleChanged: {
        if(showFlag == false)
        {
            showFlag = true;
//            console.log("视频窗口被激活")
            setVideoPath(def.videoDefaultLocation)
        }
    }

    Define {
        id: def
        source_url: video.source
    }
//    //最底层背景图片
//    Image {
//        id: backgroundImage
//        anchors.fill: parent
//        width: parent.width
//        height: parent.height
//        source: def.url_video_background
//        fillMode: Image.PreserveAspectFit
//        clip: true
//    }

    //视频输出到背景
    MVideoOutput {
        anchors.fill: parent        //充满背景
        source: video
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
//            fileDialog.open()
            fileBrowser.nameFilter = def.videoNameFilters
            fileBrowser.defaultLocation = def.videoDefaultLocation

            fileBrowser.showNormal()
        }
    }

    PlayerControlBar {
        id: player
        visible: true
        width: def.win_width
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
            video.seek(slider_value)
            videoPlay()
        }
    }

    //鼠标进入现实，鼠标退出隐藏的效果实现
    /*
    MouseArea {
        width: player.width
        height: player.height
        anchors.bottom: parent.bottom
        propagateComposedEvents: true
        hoverEnabled: true
        onEntered: player.visible = true
        onExited: player.visible = false
    }
    */
    function videoPlay()
    {
        player.playing = true;
        video.play();
    }
    function videoPause()
    {
        player.playing = false;
        video.pause();
    }
    function videoStop()
    {
        videoSwitchFlag = true;
        player.playing = false;
        player.media_postion = 0;
        video.stop();
        videoSwitchFlag = false;
    }
    function videoStepForward()
    {
        video.seek(video.position+10000)
    }
    function videoStepBackward()
    {
        video.seek(video.position-10000)
    }
    function videoBackward()
    {
        videoSwitchFlag = true;
        videoStop();
        videoIndex -= 1;
        if(videoIndex < 0)
            videoIndex = getVideoCount()-1;//-1->4

        video.source = getVideoURL(videoIndex)
        console.log("上一曲:" + (videoIndex+1) + "/"  + getVideoCount() + ":" + video.source);
        videoPlay();
        videoSwitchFlag = false;
    }
    function videoForward()
    {
        videoSwitchFlag = true;
        videoStop();
        videoIndex += 1;
        if(videoIndex == getVideoCount())    //0-4, 5
            videoIndex = 0;  //4->0
        video.source = getVideoURL(videoIndex)
        console.log("下一曲:" + (videoIndex+1) + "/"  + getVideoCount() + ":" + video.source);
        videoPlay();
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
        visible: player.playing ? false : true
    }
    //视频区域单击暂停播放切换
    MouseArea {
        enabled: video.hasVideo && (getVideoCount() > 0)
        anchors.top: backButton.bottom
        anchors.bottom: player.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 50
        onClicked: player.playing ? videoPause() : videoPlay();
    }

    //视频播放器
    MediaPlayer {
        id: video
        volume: player.media_volume
        onPositionChanged: player.media_postion = video.position
        onPlaybackStateChanged: //1:playing, 2:pause, 0:stop
        {
            if(video.playbackState == MediaPlayer.StoppedState ) //播放完成自动停止
            {
                if(videoSwitchFlag == false)
                {
                    console.log("video stop")
                    videoForward();     //自动播放下一个
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

//        onStatusChanged: console.log("status:", folderModel.status);

        onFolderChanged: {
            if(getVideoCount() == 0) {
                console.log("所选文件夹无视频文件:" + folderModel.folder)
                videoIndex = 0;
            }
            else {
                console.log("共发现" + getVideoCount() + "个视频文件")
                videoSwitchFlag = true;
                videoIndex = 0;
                video.source = getVideoURL(videoIndex)
                videoSwitchFlag = false;
            }
        }
    }

    //文件选择对话框，调用系统自带的窗口
    /*
    FileDialog {
        id: fileDialog
        title: "请选择一个视频文件夹"
        selectFolder: true  //只能选择文件夹
        onRejected: {
            if(video.hasVideo)
                videoPlay()
        }
        //设置folderModel的文件夹为当前选定的文件夹
        onAccepted: {
            videoIndex = 0;
            setVideoPath(fileUrl + "/")
        }
    }*/
    //自定义文件浏览器
    FileList{
        id: fileBrowser
        backButtonText: root.title
        onRejected: {
            if(video.hasVideo)
                videoPlay()
        }
        onAccepted: {
            videoSwitchFlag = true;
            videoIndex = fileBrowser.fileIndex
            console.log(videoIndex)
            video.source = getVideoURL(videoIndex)
            setVideoPath(fileUrl + "/");
            console.log("设置视频文件夹为:", fileUrl + "/");
            videoSwitchFlag = false
        }
    }

    function setVideoPath(path)
    {
        folderModel.folder = path;
    }
    function getVideoURL(idx)
    {
        var path = "file://";
        var filepath = folderModel.get(idx, "filePath")
//        if (filepath[1] === ':') // Windows drive logic, see QUrl::fromLocalFile()
//            path += '/';
        path += filepath;

        console.log(path)
        return path;
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
