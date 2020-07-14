import QtQuick 2.0
import QtQuick.Window 2.2
import QtMultimedia 5.9
import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
SystemWindow {
    id: root
    width: def.win_width
    height: def.win_height
////    flags: Qt.Dialog        //Dialog,没有最大最小化按钮
////    title: qsTr("音乐")

//    //打开音乐窗口时，设置音乐文件夹为默认文件夹
//    property bool showFlag: false
//    function show()
//    {
//        open()
//    }
//    onAboutToHide: showFlag = false
    onVisibleChanged: {
        if(showFlag == false)
        {
            showFlag = true;
//            console.log("音乐窗口被激活")
            setMusicPath(def.audioDefaultLocation)
        }
    }

    Define {
        id: def
        source_url: music.source
    }

//    //最底层背景图片
//    Image {
//        id: img_background
//        anchors.fill: parent
//        width: parent.width
//        height: parent.height
//        source: def.url_music_background
//        fillMode: Image.PreserveAspectFit
//        clip: true
//    }

    //上层音乐波形图片
    Image {
        id: waveImage
        anchors.fill: parent
        anchors.centerIn: parent
        source: def.url_music_audio_wave
        fillMode: Image.PreserveAspectFit
        clip: true
    }

    //上层唱片图片
    Image {
        id: recordImage
        width: 200
        height: 200
        anchors.centerIn: parent
        source: def.url_music_record
        fillMode: Image.PreserveAspectFit
        clip: true
    }
    //唱片动画旋转动画效果0-360,
    //stop,pause,start,resume,
    RotationAnimation {
        id: recordAnimation     //唱片动画
        target: recordImage     //唱片图片
        from: 0
        to: 360
        direction: RotationAnimation.Clockwise
        duration: 3000
        loops: Animation.Infinite
    }
    //唱针顶点，固定的
    Image {
        id: fixdotImage
        x: 416
        width: 200
        height: 200
        anchors.top: recordImage.top
        anchors.topMargin: -72
        anchors.right: recordImage.right
        anchors.rightMargin: -116
        source: def.url_music_fixdot
        fillMode: Image.PreserveAspectFit
        clip: true
    }
    //CD唱针，带角度动画
    Rectangle {
        id: stylusRectangle
        x: 416
        width: stylusImage.width
        height: stylusImage.height
        color: "transparent"
        //与唱针右上对齐
        anchors.top: recordImage.top
        anchors.topMargin: -72
        anchors.right: recordImage.right
        anchors.rightMargin: -116

        transform: Rotation {
            id: stylusRoation
            origin.x: 90
            origin.y: 70
            angle: -10
            Behavior on angle {
                NumberAnimation {   //数值变化需要300ms
                    duration: 300
                }
            }
        }

        Image {
            id: stylusImage
            width: 200
            height: 200
            anchors.fill: parent
            source: def.url_music_stylus      //唱针图片
            fillMode: Image.PreserveAspectFit
            clip: true
        }
    }

    //左上角返回按钮
    MyIconButton {
        id: backButton
        icon_code: def.iconCode_back
        button_text: music.hasAudio ? def.getFileName() : "返回"
        //        button_text: music.metaData.title
        button_color: "white"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 10
        onClicked: {
            musicStop()
            root.close()
        }
    }
    //右上角选择音乐文件夹按钮
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
            if(music.hasAudio)
                musicPause()    //先暂停播放
//            fileDialog.open()
//            fileBrowser.
            fileBrowser.nameFilter = def.audioNameFilters
            fileBrowser.defaultLocation = def.audioDefaultLocation

            fileBrowser.showNormal()
        }
    }

    //底部播放控制+进度
    PlayerControlBar {
        id: player
        visible: true
        width: def.win_width

        enabled: music.hasAudio & (folderModel.count!=0)
        anchors.bottom: parent.bottom
        media_duration: music.duration

        onClicked_play:musicPlay()
        onClicked_pause: musicPause()
        onClicked_stop: musicStop()
        onClicked_step_backward: musicStepBackward()
        onClicked_step_forward: musicStepForward()
        onClicked_backward: musicBackward()
        onClicked_forward: musicForward()

        onMoved_slider:
        {
            music.seek(slider_value)
            musicPlay()
        }
    }

    //播放：唱针旋转到唱片位置，启动唱片旋转动画
    function musicPlay()
    {
        player.playing = true;
        stylusRoation.angle = 35;
        music.play();

        if(recordAnimation.running == false)
            recordAnimation.start()
        else
            recordAnimation.resume();
    }
    //暂停：唱针移开，唱片停止旋转
    function musicPause()
    {
        player.playing = false;
        music.pause();
        stylusRoation.angle = -10;

        if(recordAnimation.running)
            recordAnimation.pause()
    }
    //停止：唱针移开，唱片停止旋转，并复位
    function musicStop()
    {
        musicSwitchFlag = true;
        player.playing = false;
        player.media_postion = 0;
        music.stop();
        stylusRoation.angle = -10;
        recordImage.rotation = 0;   //唱片角度复位
        recordAnimation.stop();
        musicSwitchFlag = false;
    }
    //快进: 10s
    function musicStepForward()
    {
        music.seek(music.position+10000)
    }
    //快退: 10s
    function musicStepBackward()
    {
        music.seek(music.position-10000)
    }
    //上一曲: 索引递减，列表循环播放
    function musicBackward()
    {
        musicSwitchFlag = true;
        musicStop();
        musicIndex -= 1;
        if(musicIndex < 0)
            musicIndex = getMusicCount()-1//-1->4

        music.source = getMusicURL(musicIndex)
        console.log("上一曲:" + (musicIndex+1) + "/"  + getMusicCount() + ":" + music.source);
        musicPlay();
        musicSwitchFlag = false;
    }
    //下一曲: 索引递增，列表循环播放
    function musicForward()
    {
        musicSwitchFlag = true;
        musicStop();
        musicIndex += 1;
        if(musicIndex == getMusicCount())    //0-4, 5
            musicIndex = 0;  //4->0
        music.source = getMusicURL(musicIndex)
        console.log("下一曲:" + (musicIndex+1) + "/"  + getMusicCount() + ":" + music.source);
        musicPlay();
        musicSwitchFlag = false;
    }

    Audio {
        id: music
        volume: player.media_volume
        playlist: playlist

        onPositionChanged: player.media_postion = music.position
        onPlaybackStateChanged: //1:playing, 2:pause, 0:stop
        {
            //播放结束切换到下一曲
            if(music.playbackState == Audio.StoppedState)
            {
                if(musicSwitchFlag == false)
                {
                    console.log("music stop")
                    musicForward();
                }
            }
        }
    }

    //用于保存文件夹内的音频文件
    FolderListModel {
        id: folderModel
        objectName: "folderModel"
        showDirs: false
        nameFilters: def.audioNameFilters
        sortField: FolderListModel.Name
//        onStatusChanged: console.log("status:", folderModel.status);
        onFolderChanged: {
            if(getMusicCount() == 0) {
                console.log("所选文件夹内无音乐文件" + getMusicFolder())
                musicIndex = 0;
            }
            else {
                console.log("共发现" + getMusicCount() + "个音乐文件")
                musicSwitchFlag = true;
                musicIndex = 0;

                music.source = getMusicURL(musicIndex)
                musicSwitchFlag = false;
            }
        }
    }

    //文件夹选择，调用系统默认文件选择对话框
    /*
    FileDialog {
        id: fileDialog
        title: "请选择一个音乐文件夹"
        selectFolder: true  //只能选择文件夹
        onRejected: {
            if(music.hasAudio)
                musicPlay()
        }
        //设置folderModel的文件夹为当前选定的文件夹
        onAccepted: {
            musicIndex = 0;
            setMusicPath(fileUrl + "/");
        }
    }*/

    //自定义文件浏览器
    FileList {
        id: fileBrowser
        backButtonText: root.title
        onRejected: {
            if(music.hasAudio)
                musicPlay()
        }
        onAccepted: {
            musicSwitchFlag = true;
            musicIndex = fileBrowser.fileIndex
//            console.log(musicIndex)
            music.source = getMusicURL(musicIndex)
            setMusicPath(fileUrl + "/");
            console.log("设置音乐文件夹为:", fileUrl + "/");
            musicSwitchFlag = false
        }
    }

    function setMusicPath(path)
    {
        folderModel.folder = path;
    }
    function getMusicURL(idx)
    {
        var path = "file://";
        var filepath = folderModel.get(idx, "filePath")
//        if (filepath[1] === ':') // Windows drive logic, see QUrl::fromLocalFile()
//            path += '/';
        path += filepath;

        console.log(path)
        return path;
    }
    function getMusicFolder()
    {
        return folderModel.folder
    }
    function getMusicCount()
    {
        return folderModel.count
    }


    property int musicIndex: 0
    property bool musicSwitchFlag: false
}
