QT += qml quick core gui printsupport testlib quickcontrols2 multimedia multimediawidgets
QT += core-private network gui-private multimedia-private
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
CONFIG += c++11
CONFIG += qcamera-v4l2

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS
# QMAKE_CXXFLAGS += -mavx2

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    Charge104.cpp \
    ChargeManage.cpp \
    ClearCache.cpp \
    abstractcamera.cpp \
    camera_qthread.cpp \
    cameraimageprovider.cpp \
    iec104_class.cpp \
    logmsg.cpp \
        main.cpp \
    multicamera.cpp \
    multimedia/controls/qmediaavailabilitycontrol.cpp \
    multimedia/controls/qmetadatareadercontrol.cpp \
    multimedia/controls/qvideorenderercontrol.cpp \
    multimedia/qmediabindableinterface.cpp \
    multimedia/qmediacontrol.cpp \
    multimedia/qmediametadata.cpp \
    multimedia/qmediaobject.cpp \
    multimedia/qmediaresourcepolicyplugin_p.cpp \
    multimedia/qmediaresourceset_p.cpp \
    multimedia/qmediaservice.cpp \
    multimedia/qmediatimerange.cpp \
    multimedia/qmultimedia.cpp \
    multimedia/qmultimediautils.cpp \
    multimedia/video/mvideoframe.cpp \
    multimedia/video/qabstractvideobuffer.cpp \
    multimedia/video/qabstractvideofilter.cpp \
    multimedia/video/qabstractvideosurface.cpp \
    multimedia/video/qimagevideobuffer.cpp \
    multimedia/video/qmemoryvideobuffer.cpp \
    multimedia/video/qvideoframeconversionhelper.cpp \
    multimedia/video/qvideoframeconversionhelper_avx2.cpp \
    multimedia/video/qvideoframeconversionhelper_sse2.cpp \
    multimedia/video/qvideoframeconversionhelper_ssse3.cpp \
    multimedia/video/qvideosurfaceformat.cpp \
    qcustomplot.cpp \
    qiec104.cpp \
    qmlplot.cpp \
    common.cpp \
    myfunction.cpp \
    qmlprocess.cpp \
    translator.cpp \
    mvideooutput.cpp \
    videowidgetsurface.cpp \
    yuyv_qthread.cpp

RESOURCES += qml.qrc
CONFIG += disable-desktop
static {
    QT += svg
    QTPLUGIN += qtvirtualkeyboardplugin
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    Charge104.h \
    ChargeManage.h \
    ClearCache.h \
    abstractcamera.h \
    camera_data.h \
    camera_qthread.h \
    cameraimageprovider.h \
    iec104_class.h \
    iec104_types.h \
    logmsg.h \
    multicamera.h \
    multimedia/controls/qmediaavailabilitycontrol.h \
    multimedia/controls/qmetadatareadercontrol.h \
    multimedia/controls/qvideorenderercontrol.h \
    multimedia/qmediabindableinterface.h \
    multimedia/qmediacontrol.h \
    multimedia/qmediacontrol_p.h \
    multimedia/qmediaenumdebug.h \
    multimedia/qmediametadata.h \
    multimedia/qmediaobject.h \
    multimedia/qmediaobject_p.h \
    multimedia/qmediaresourcepolicyplugin_p.h \
    multimedia/qmediaresourceset_p.h \
    multimedia/qmediaservice.h \
    multimedia/qmediaservice_p.h \
    multimedia/qmediatimerange.h \
    multimedia/qmultimedia.h \
    multimedia/qmultimediautils_p.h \
    multimedia/qtmultimediaglobal.h \
    multimedia/qtmultimediaglobal_p.h \
    multimedia/video/mvideoframe.h \
    multimedia/video/mvideoframe_p.h \
    multimedia/video/qabstractvideobuffer.h \
    multimedia/video/qabstractvideobuffer_p.h \
    multimedia/video/qabstractvideofilter.h \
    multimedia/video/qabstractvideosurface.h \
    multimedia/video/qimagevideobuffer_p.h \
    multimedia/video/qmemoryvideobuffer_p.h \
    multimedia/video/qvideoframeconversionhelper_p.h \
    multimedia/video/qvideosurfaceformat.h \
    qcustomplot.h \
    qiec104.h \
    qmlplot.h \
    common.h \
    myfunction.h \
    qmlprocess.h \
    translator.h \
    mvideooutput.h \
    videowidgetsurface.h \
    yuyv_qthread.h
TRANSLATIONS = languages/language_zh.ts \
               languages/language_en.ts


