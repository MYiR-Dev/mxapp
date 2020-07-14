import QtQuick 2.0
import MyFunction.module 1.0
import QtQuick.Window 2.2
Item {
    id: def

    property int win_width: Screen.desktopAvailableWidth
    property int win_height: Screen.desktopAvailableHeight
    MyFunction {id: myFunction}
    property int iconSize: 25

    //FontAwesome字体图标代码
    property string iconCode_play: "\uf04c"             //播放
    property string iconCode_pause: "\uf04b"            //暂停
    property string iconCode_stop: "\uf04d"             //停止
    property string iconCode_step_backward: "\uf04a"    //快退
    property string iconCode_step_forward: "\uf04e"     //快进
    property string iconCode_forward: "\uf051"          //下一曲
    property string iconCode_backward: "\uf048"         //上一曲
    property string iconCode_folder: "\uf07c"           //打开文件图标
    property string iconCode_back: "\uf053"             //返回图标
    property string iconCode_volume_mute: "\uf026"      //静音图标
    property string iconCode_volume_up: "\uf028"        //音量增大
    property string iconCode_volume_down: "\uf027"      //音量减小
    property string iconCode_album: "\uf03e"            //所有图片
    property string iconCode_camera: "\uf030"           //相机
    property string iconCode_left: "\uf104"             //上一张
    property string iconCode_right: "\uf105"            //下一张
    property string iconCode_trash: "\uf014"            //删除标志

    property string iconCode_file_folder: "\uf07b"
    property string iconCode_file_audio: "\uf1c7"
    property string iconCode_file_image: "\uf1c5"
    property string iconCode_file_file: "\uf15b"
    property string iconCode_file_video: "\uf1c8"

    property string iconCode_file_archive: "\uf1c6"
    property string iconCode_file_code: "\uf1c9"
    property string iconCode_file_excel: "\uf1c3"
    property string iconCode_file_pdf: "\uf1c1"
    property string iconCode_file_powerpoint: "\uf1c4"
    property string iconCode_file_sound: "\uf1c7"
    property string iconCode_file_text: "\uf15c"

    property int fontSize: 16

    property url url_music_audio_wave: "qrc:/images/wvga/multimedia/img_audio_wave.png"
    property url url_music_background: "qrc:/images/wvga/multimedia/img_music_background.png"
    property url url_music_record: "qrc:/images/wvga/multimedia/img_record.png"
    property url url_music_fixdot: "qrc:/images/wvga/multimedia/img_fixdot.png"
    property url url_music_stylus: "qrc:/images/wvga/multimedia/img_stylus.png"
    property url url_video_background: "qrc:/images/wvga/multimedia/img_music_background.png"

    property url url_icon_camera: "qrc:/icon/icon_camera.png"
    property url url_icon_music: "qrc:/icon/icon_music.png"
    property url url_icon_video: "qrc:/icon/icon_video.png"
    property url url_icon_album: "qrc:/icon/icon_album.png"

    //相机图片保存路径

    property string captureSaveHead: "myir_"
    //相对路径
    //默认构建目录：./%{CurrentBuild:Name}
    property string captureSavePath: myFunction.getPath() + "/Capture/"
    property string audioDefaultLocation: "file://" + myFunction.getPath() + "/Music/"
    property string videoDefaultLocation: "file://" + myFunction.getPath() + "/Video/"
    property string imageDefaultLocation: "file://" + captureSavePath

/*
    //绝对路径
    property string captureSavePath: "F:/MYIR/MultimediaPlayer/Capture/"
    property string audioDefaultLocation: "file:///F:/MYIR/MultimediaPlayer/Music/"
    property string videoDefaultLocation: "file:///F:/MYIR/MultimediaPlayer/Video/"
    property string imageDefaultLocation: "file:///" + captureSavePath;
*/
    //媒体文件类型过滤
    property var audioNameFilters: ["*.mp3", "*.ape", "*.acc", "*.ogg", "*.flac"]
    property var videoNameFilters: ["*.mp4", "*.mkv", "*.avi", "*.wmv", "*.rmvb", "*.mov"]
    property var imageNameFilters: ["*.jpg", "*.png", "*.bmp", "*.jpeg"]

    property url url_img_preview: "qrc:/img/img_preview.jpg"
    property url url_img_black_transparent: "qrc:/images/wvga/multimedia/img_black_transparent.png"

    property string source_url: "qrc:/images/wvga/multimedia/img_preview.jpg"

    //图库和预览界面参数
    property int slidLength: 150        //图库预览左右滑动有效长度
    property int albumNumber: 9         //图库一行显示的照片个数
    property int albumMargins: 20       //图库图片左右间距大小

    //毫秒->分钟秒
    function msToMMSS(ms)
    {
        var utilDate = new Date();
        utilDate.setTime(ms);
        return Qt.formatTime(utilDate, "mm:ss");
    }

    //毫秒转换->小时分钟秒钟
    function msToHHMMSS(ms)
    {
        var hour = Math.floor((ms / 1000) / 3600);
        if(hour <= 9)
            hour = "0" + hour;

        var min = Math.floor((ms / 1000) % 3600 / 60);
        if(min <= 9)
            min = "0" + min;

        var sec = Math.floor((ms / 1000) % 3600 % 60);
        if(sec <= 9)
            sec = "0" + sec;

        return hour + ":" + min + ":" + sec;
    }

    //获取影音名称

    function getFileName()
    {
        var url = source_url;
        var arr = [];
        arr = url.split("/");
        var name = arr[arr.length-1];
        return name;
    }

    //时间字符串20200323_21_56_29_926
    function getCurrentTime(){
        var time = Qt.formatDateTime(new Date(), "yyyyMMdd_hh_mm_ss_zzz");
//        console.log(time)
        return time;
    }

    //根据文件名获取文件后缀
    function getFileSuffix(fileName)
    {
        var suffix = fileName.substring(fileName.lastIndexOf(".") + 1);
        return suffix;
    }

    //根据文件后缀显示对应的图标
    function getFileIconCode(fileName)
    {
        var iconCode;
        //获取文件后缀
        var suffix = getFileSuffix(fileName)
        switch(suffix)
        {

        //image file
        case "jpg":
        case "jpeg":
        case "bmp":
        case "png":
            iconCode = iconCode_file_image;
            break;

        //audio file
        case "mp3":
        case "ape":
        case "aac":
        case "ogg":
        case "flac":
            iconCode = iconCode_file_audio;
            break;

        //video file
        case "mp4":
        case "mkv":
        case "avi":
        case "wmv":
        case "rmvb":
            iconCode = iconCode_file_video;
            break;
        //other file
        case "pdf": iconCode = iconCode_file_pdf;
            break;
        case "rar":
        case "zip":
            iconCode = iconCode_file_archive;
            break;
        case "txt":
        case "md":
            iconCode = iconCode_file_text;
            break;
        default:
            iconCode = iconCode_file_file;
            break;
        }
        return iconCode;
    }
}
