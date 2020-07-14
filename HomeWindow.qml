import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
//import QtGraphicalEffects 1.0
//import QtQml.Models 2.1

//#02b9db home界面小图片背景色

Rectangle {
    id:root
    color: "#00000000"

//    FontLoader { id: fixedFont; name: "Courier" }
//    FontLoader { id: localFont; source: "fonts/DIGITAL/DS-DIGIB.TTF" }
//    FontLoader { id: webFont; source: "http://www.princexml.com/fonts/steffmann/Starburst.ttf" }
    function fitWidth(text){
           return  fontMetrics.advanceWidth(text);
       }

    function addModelData(catalogue,cimage,cname,application,aimage,aqml,acolor){
        var index = findIndex(catalogue)
        console.log("addModeData:"+catalogue)
        if(index === -1){
            viewModel.append({"catalogue":catalogue,"cimage":cimage,"cname":QT_TR_NOOP(cname),"level":0,
                                 "subNode":[{"application":application,"aimage":aimage,"acolor":acolor,"aqml":aqml,"level":1,"subNode":[]}]})
        }
        else{
            viewModel.get(index).subNode.append({"application":application,"aimage":aimage,"acolor":acolor,"aqml":aqml,"level":1,"subNode":[]})
        }

    }

    function findIndex(name){
        for(var i = 0 ; i < viewModel.count ; ++i){
            if(viewModel.get(i).catalogue === name){
                return i
            }
        }
        return -1
    }

    FontMetrics {
        id: fontMetrics
        font.family: "Microsoft YaHei"
        font.pixelSize: 20
    }
    property int family_font_size: 30
    property int app_font_size: 20
    Connections {
        target: translator
        onLanguageChanged: {
            console.log(lang)
            if (lang === "English")
            {
                family_font_size = 25
                app_font_size = 15
            }
            else
            {
                family_font_size = 30
                app_font_size = 20
            }

        }
    }

        //个性推荐的顶部，使用pathView
        Rectangle{
            id:pathViewRect;
            width: Screen.desktopAvailableWidth/1.3;
            height: Screen.desktopAvailableHeight/1.2;
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top;
            anchors.topMargin: 20
            color: "transparent";

            ListModel{
                id:viewModel;
                ListElement{
                    catalogue:"multimedia"
                    cimage:"qrc:/images/fhd/home/homepage_media_nor.png"
                    cname: qsTr("多媒体")
                    subNode: [
                        ListElement {
                            aimage: "qrc:/images/wvga/home/media_icon_camera_nor.png"
                            application: qsTr("摄像头")
                            aqml: "CameraWindow.qml"
                            acolor: "#02b9db"
                        },
                        ListElement {
                            aimage:"qrc:/images/wvga/home/media_icon_video_nor.png"
                            application: qsTr("播放器")
                            aqml:"PlayerWindow.qml"
                            acolor:"#02b9db"
                        },
                        ListElement {
                            aimage:"qrc:/images/wvga/home/icon_music.png"
                            application: qsTr("音乐")
                            aqml:"MusicWindow.qml"
                            acolor:"#02b9db"
                        },
                        ListElement {
                            aimage:"qrc:/images/wvga/home/media_icon_img_nor.png"
                            application: qsTr("图片")
                            aqml:"PictureWindow.qml"
                            acolor:"#02b9db"
                        }
                    ]
                }
                ListElement{
                    catalogue:"system"
                    cimage:"qrc:/images/fhd/home/homepage_system_nor.png"
                    cname: qsTr("系统")
                    subNode: [
                        ListElement {
                            aimage: "qrc:/images/wvga/home/system_icon_info_nor.png"
                            application: qsTr("系统信息")
                            aqml: "InfoWindow.qml"
                            acolor: "#02b9db"
                        },
                        ListElement {
                            aimage:"qrc:/images/wvga/home/system_icon_set_nor.png"
                            application: qsTr("系统设置")
                            aqml:"SettingsWindow.qml"
                            acolor:"#02b9db"
                        },
                        ListElement {
                            aimage:"qrc:/images/wvga/home/media_icon_doc.png"
                            application: qsTr("文件管理器")
                            aqml:"FileWindow.qml"
                            acolor:"#02b9db"
                        }
                    ]
                }
				ListElement{
                    catalogue:"machine"
                    cimage:"qrc:/images/fhd/home/homepage_machine_nor.png"
                    cname: qsTr("智能家电")
                    subNode: [
                        ListElement {
                            aimage: "qrc:/images/wvga/home/smart_icon_washing_nor.png"
                            application: qsTr("洗衣机")
                            aqml: "WashWindow.qml"
                            acolor: "#02b9db"
                        }
                    ]
                }
				ListElement{
                    catalogue:"health"
                    cimage:"qrc:/images/fhd/home/homepage_medical_nor.png"
                    cname: qsTr("卫生医疗")
                    subNode: [
                        ListElement {
                            aimage: "qrc:/images/wvga/home/medical_icon_heart_nor.png"
                            application: qsTr("心电仪")
                            aqml: "ScopeWindow.qml"
                            acolor: "#02b9db"
                        }
                    ]
                }
				ListElement{
                    catalogue:"public"
                    cimage:"qrc:/images/fhd/home/homepage_public_nor.png"
                    cname: qsTr("公共服务")
                    subNode: [
                        ListElement {
                            aimage: "qrc:/images/wvga/home/public_icon_ticket_nor.png"
                            application: qsTr("取票机")
                            aqml: "TicketWindow.qml"
                            acolor: "#02b9db"
                        }
                    ]
                }				

            }

            Component{
                id:viewDelegate;
                Item{
                    id:wrapper;
                    property real iangle: PathView.iconAngle;
                    width: parent.width/2.5;
                    height: parent.height-20;
                    anchors.top: parent.top;
                    anchors.topMargin: 10;
                    z:PathView.zOrder;
                    scale: PathView.itemScale;
                    antialiasing: true
                    Image {
                        id:image;
                        width: Screen.desktopAvailableWidth/4.4;
                        height: Screen.desktopAvailableHeight/1.74;
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: cimage;

                        transform: Rotation{
                            origin.x:image.width/2.0
                            origin.y:image.height/2.0
                            axis{x:0;y:1;z:0}
                            angle:wrapper.iangle
                        }
                    }


                    ShaderEffect {
                        anchors.top: image.bottom
                        width: image.width
                        height: image.height/3;
                        anchors.left: image.left
                        property variant source: image;
                        property size sourceSize: Qt.size(0.5 / image.width, 0.5 / image.height);
                        fragmentShader:
                                "varying highp vec2 qt_TexCoord0;
                                uniform lowp sampler2D source;
                                uniform lowp vec2 sourceSize;
                                uniform lowp float qt_Opacity;
                                void main() {

                                    lowp vec2 tc = qt_TexCoord0 * vec2(1, -1) + vec2(0, 1);
                                    lowp vec4 col = 0.25 * (texture2D(source, tc + sourceSize) + texture2D(source, tc- sourceSize)
                                    + texture2D(source, tc + sourceSize * vec2(1, -1))
                                    + texture2D(source, tc + sourceSize * vec2(-1, 1)));
                                    gl_FragColor = col * qt_Opacity * (1.0 - qt_TexCoord0.y) * 0.2;
                                }"
                    }
                    Text{
                        width: parent.width;
                        height: 40;
                        anchors.bottom: image.bottom;
                        anchors.horizontalCenter: image.horizontalCenter
                        anchors.bottomMargin: Screen.desktopAvailableHeight/24/*15*/;
                        text: cname;
                        horizontalAlignment: Text.AlignHCenter
                        color: "#dcdde4";
                        font.family: "Microsoft YaHei";
                        font.pixelSize: family_font_size;
                        wrapMode: Text.Wrap;
                    }
                    MouseArea{
                        anchors.fill: parent;
                        hoverEnabled: true;
                        cursorShape: Qt.PointingHandCursor;

                        onClicked: {
                            if(index!==pathView.currentIndex)
                            {
                                pathView.currentIndex=index;
                                pageIndicator.currentIndex=index;
                            }
                            else
                            {
                                //打开链接
                            }
                        }
                    }
                }

            }

            PathView{
                id:pathView;
                anchors.fill: parent;
                interactive: true;
                currentIndex: pageIndicator.currentIndex;
                pathItemCount: 5;
                preferredHighlightBegin: 0.5;
                preferredHighlightEnd: 0.5;
                highlightRangeMode: PathView.StrictlyEnforceRange;

                delegate: viewDelegate;
                model: viewModel;

                path:Path{
                    startX:50;
                    startY:0;

                    PathAttribute{name:"zOrder";value:0}
                    PathAttribute{name:"itemScale";value:0.55}
                    PathAttribute{name:"iconAngle";value:-40}
                    PathLine{
                        x:pathView.width/4;
                        y:0;
                    }

                    PathAttribute{name:"zOrder";value:5}
                    PathAttribute{name:"itemScale";value:0.70}
                    PathAttribute{name:"iconAngle";value:-20}
                    PathLine{
                        x:pathView.width/2;
                        y:0;
                    }

                    PathAttribute{name:"zOrder";value:10}
                    PathAttribute{name:"itemScale";value:1}
                    PathAttribute{name:"iconAngle";value:0}
                    PathLine{
                        x:pathView.width*0.75;
                        y:0;
                    }

                    PathAttribute{name:"zOrder";value:5}
                    PathAttribute{name:"itemScale";value:0.70}
                    PathAttribute{name:"iconAngle";value:20}
                    PathLine{
                        x:pathView.width-50;
                        y:0;

                    }

                    PathAttribute{name:"zOrder";value:0}
                    PathAttribute{name:"itemScale";value:0.55}
                    PathAttribute{name:"iconAngle";value:40}

                }
            }

            Image{
                id: pointer
                source: "qrc:/images/wvga/home/icon_arrow_.png"
                anchors{
                    bottom:pathViewRect.bottom
                    horizontalCenter: pathViewRect.horizontalCenter
                    bottomMargin: Screen.desktopAvailableHeight/6.4
                }
            }
            Rectangle{
                id: subMenu
                width: Screen.desktopAvailableWidth
                height: Screen.desktopAvailableHeight/8.7
//                radius: 20
                color: Qt.rgba(0,0xff,0xff,0.1)
                anchors{
                    bottom:pathViewRect.bottom
                    horizontalCenter: pathViewRect.horizontalCenter
                    bottomMargin: 20
                }

                RowLayout{
                    id: subMenuRow
                    width: Screen.desktopAvailableWidth
                    height: Screen.desktopAvailableHeight/8.7
                    property bool isClickable: true

//                    anchors{
//                        fill:parent
//                        top: pointer.bottom
//                        horizontalCenter: subMenu.horizontalCenter
//                    }

                    Repeater{
//                        anchors{
//                            horizontalCenter: subMenu.horizontalCenter
//                        }
                        model:{
                            var index = findIndex("multimedia")
                            console.log("index="+index)
                            console.log("currentIndex="+pathView.currentIndex)
                            if(pathView.currentIndex>0)
                            {
                                index = pathView.currentIndex;
                            }
                            console.log("index="+index)
                            viewModel.get(index/*pathView.currentIndex*/).subNode
                        }
                        Rectangle{
                            id:rootrect
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth:128
                            Layout.preferredHeight:48
                            color: Qt.rgba(0,0,0,0)

                            Rectangle{
                                id: appRect
                                implicitWidth: {
                                    var wid = fitWidth(tt.text)+55
                                    console.log("wid:"+wid)
                                    Math.min(wid,160)
                                }
                                implicitHeight: 42
                                radius: 10
                                color: model.acolor
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }

                                Image{
                                    id: appicon
                                    width: 24
                                    height: 24
                                    source: model.aimage
                                    anchors{
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                        leftMargin: 10
                                    }
                                }

                                Text{
                                    id:tt
                                    text: model.application
                                    color: "#dcdde4";
                                    font.family: "Microsoft YaHei";
                                    font.pixelSize: app_font_size;
//                                    wrapMode: Text.Wrap;
                                    anchors{
                                        verticalCenter: parent.verticalCenter
                                        left: appicon.right
                                        leftMargin: 10
                                        right: parent.right
                                        rightMargin: 10
                                    }

                                }

                                MouseArea{
                                    id: homeMA
                                    anchors.fill: parent;
                                    hoverEnabled: true;
                                    cursorShape: Qt.PointingHandCursor;

                                    onClicked: {
                                        console.log("clicked:"+model.aqml + " " + subMenuRow.isClickable)

// 第一种方式加载
//                                        timer.start()
//                                        if(subMenuRow.isClickable === true){
//                                            var componet = Qt.createComponent(model.aqml);
//                                            if(componet.status === Component.Ready) {
//                                                var obj = componet.createObject(mainWnd)
//                                            }
//                                            obj.show()

//                                            isClickable.isSubShow = false;
//                                        }

// 第二种方式加载
                                        if(model.aqml === "PlayerWindow.qml"){
//                                            playerWnd.forceActiveFocus()
//                                            playerWnd.z=4;
                                            mainloader.source = "PlayerWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "CameraWindow.qml"){
//                                            cameraWnd.forceActiveFocus()
//                                            cameraWnd.z=4;
                                            mainloader.source = "CameraWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "PictureWindow.qml"){
//                                            pictureWnd.forceActiveFocus()
//                                            pictureWnd.z=4;
                                            mainloader.source = "PictureWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "TicketWindow.qml"){
//                                            ticketWnd.forceActiveFocus()
//                                            ticketWnd.z=4;
                                            mainloader.source = "TicketWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "ScopeWindow.qml"){
//                                            scopeWnd.forceActiveFocus()
//                                            scopeWnd.z=4;
                                            mainloader.source = "ScopeWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "FileWindow.qml"){
//                                            fileWnd.forceActiveFocus()
//                                            fileWnd.z=4;
                                            mainloader.source = "FileWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "WashWindow.qml"){
//                                            washWnd.forceActiveFocus()
//                                            washWnd.z=4;
                                            mainloader.source = "WashWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "InfoWindow.qml"){
//                                            infoWnd.forceActiveFocus()
//                                            infoWnd.z=4;
                                            mainloader.source = "InfoWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }else if(model.aqml === "SettingsWindow.qml"){
//                                            settingsWnd.forceActiveFocus()
//                                            settingsWnd.z=4;
                                            mainloader.source = "SettingsWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
////                                            settingsWnd.source="SettingsWindow.qml"
//                                            settingsWnd.item.show()
//                                            settingsWnd.item.requestActivate()
                                        }else if(model.aqml === "MusicWindow.qml"){
//                                            settingsWnd.forceActiveFocus()
//                                            settingsWnd.z=4;
                                            mainloader.source = "MusicWindow.qml"
                                            mainloader.item.show()
                                            mainloader.item.requestActivate()
                                        }/*else if(model.aqml === "BrowserWindow.qml"){
//                                              browserWnd.forceActiveFocus()
//                                              browserWnd.z=4;
                                              browserWnd.item.show()
                                              browserWnd.item.requestActivate()
                                        }*/
                                    }

                                    Timer{
                                        id:timer
                                        interval:1000;running:false;repeat: false
                                        onTriggered: {
                                            subMenuRow.isClickable = true;
                                            console.log("timer isClickable: " + subMenuRow.isClickable)
                                        }
                                    }
                                }
                            }
                        }

                    }

                }
            }

            PageIndicator{
                id:pageIndicator;
                visible: false
                interactive: true;
                count:pathView.count;
                currentIndex: pathView.currentIndex;
                height: 7;
                anchors.bottom: parent.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                delegate: Rectangle{
                    implicitWidth: 20;
                    implicitHeight: 2;
                    color: "#7F8082";
                    opacity: index === pageIndicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }

                }

                onCurrentIndexChanged: {
//                    timer.running=false;
//                    timer.running=true;
                    console.log("currentIndexChanged:"+ currentIndex)
                }
            }

//            //Timer
//            Timer{
//                id:timer;
//                interval: 7500;
//                repeat: true;
//                running: false;
//                onTriggered: {
//                    pageIndicator.currentIndex=(pageIndicator.currentIndex+1)%(pathView.count);
//                }
//            }

//            Component.onCompleted: {
//                timer.running=true;
//            }
        }


    HomeButton {
        text: qsTr("toMENU")
        label.visible: false
        source:"images/wvga/home/home.png"
//        width: 30
//        height: 30
        glowRadius: 20
//        z: 2

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: height * 0.5
            }

        onClicked: {
               mainWnd.chooseWnd("MENU")
        }

//    Component.onCompleted: {
////1
//        addModelData(
//                    "multimedia",
//                    "qrc:/images/fhd/home/homepage_media_nor.png",
//                    qsTr("多媒体"),qsTr("摄像头"),
//                    "qrc:/images/wvga/home/media_icon_camera_nor.png",
//                    "CameraWindow.qml",
//                    "#02b9db"
//                    )
////2
//        addModelData(
//                    "multimedia",
//                    "qrc:/images/fhd/home/homepage_media_nor.png",
//                    qsTr("多媒体"),qsTr("播放器"),
//                    "qrc:/images/wvga/home/media_icon_video_nor.png",
//                    "PlayerWindow.qml",
//                    "#02b9db"
//                    )
//        //3
//        addModelData(
//                    "system",
//                    "qrc:/images/fhd/home/homepage_system_nor.png",
//                    qsTr("系统"),
//                    qsTr("系统信息"),
//                    "qrc:/images/wvga/home/system_icon_info_nor.png",
//                    "InfoWindow.qml",
//                    "#02b9db"
//                    )
//        //4
//        addModelData(
//                    "system",
//                    "qrc:/images/fhd/home/homepage_system_nor.png",
//                    qsTr("系统"),
//                    qsTr("系统设置"),
//                    "qrc:/images/wvga/home/system_icon_set_nor.png",
//                    "SettingsWindow.qml",
//                    "#02b9db"
//                    )
//        //5
//        addModelData(
//                    "machine",
//                    "qrc:/images/fhd/home/homepage_machine_nor.png",
//                    qsTr("智能家电"),
//                    qsTr("洗衣机"),
//                    "qrc:/images/wvga/home/smart_icon_washing_nor.png",
//                    "WashWindow.qml",
//                    "#02b9db"
//                    )
//        //6
//        addModelData(
//                    "health",
//                    "qrc:/images/fhd/home/homepage_medical_nor.png",
//                    qsTr("卫生医疗"),
//                    qsTr("心电仪"),
//                    "qrc:/images/wvga/home/medical_icon_heart_nor.png",
//                    "ScopeWindow.qml",
//                    "#02b9db"
//                    )
//        //7
//        addModelData(
//                    "public",
//                    "qrc:/images/fhd/home/homepage_public_nor.png",
//                    qsTr("公共服务"),
//                    qsTr("取票机"),
//                    "qrc:/images/wvga/home/public_icon_ticket_nor.png",
//                    "TicketWindow.qml",
//                    "#02b9db"
//                    )
//        //8
//        addModelData(
//                    "system",
//                    "qrc:/images/fhd/home/homepage_system_nor.png",
//                    qsTr("系统"),
//                    qsTr("文件管理器"),
//                    "qrc:/images/wvga/home/media_icon_doc.png",
//                    "FileWindow.qml",
//                    "#02b9db"
//                    )
//        //9
//        addModelData(
//                    "multimedia",
//                    "qrc:/images/fhd/home/homepage_media_nor.png",
//                    qsTr("多媒体"),
//                    qsTr("Music"),
//                    "qrc:/images/wvga/home/icon_music.png",
//                    "MusicWindow.qml",
//                    "#02b9db"
//                    )
//        //10
//        addModelData(
//                    "multimedia",
//                    "qrc:/images/fhd/home/homepage_media_nor.png",
//                    qsTr("多媒体"),
//                    qsTr("图片"),
//                    "qrc:/images/wvga/home/media_icon_img_nor.png",
//                    "PictureWindow.qml",
//                    "#02b9db"
//                    )
////        addModelData(
////                    "browser",
////                    "qrc:/images/wvga/home/homepage_media_nor.png",
////                    qsTr("网络应用"),
////                    qsTr("浏览器"),
////                    "qrc:/images/wvga/home/media_icon_img_nor.png",
////                    "BrowserWindow.qml",
////                    "#02b9db"
////                    )
//    }
    }
}
