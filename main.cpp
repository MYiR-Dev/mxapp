#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include "qmlplot.h"
#include "common.h"
#include "myfunction.h"
#include "translator.h"
#include "mvideooutput.h"
#include "ChargeManage.h"
#include "Charge104.h"

void iconFontInit()
{
    //????????fontawesome-webfont.ttf??????????????????
    //????????:www.fontawesome.com.cn
//
    int fontId_digital = QFontDatabase::addApplicationFont(":/fonts/DIGITAL/DS-DIGIB.TTF");
    int fontId_fws = QFontDatabase::addApplicationFont(":/fonts/fontawesome-webfont.ttf");  //??????????????»…??????????????????ID

    QString fontName_fws = QFontDatabase::applicationFontFamilies(fontId_fws).at(0);    //??????????????????????
    QFont iconFont_fws;
    iconFont_fws.setFamily(fontName_fws);
    QApplication::setFont(iconFont_fws);
    iconFont_fws.setPixelSize(20);     //????????????????????ß≥
}

int main(int argc, char *argv[])
{

    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
//    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
//    QGuiApplication app(argc, argv);

    qmlRegisterType<GetSystemInfo>("GetSystemInfoAPI", 1, 0, "GetSystemInfo");
    qmlRegisterType<CustomPlotItem>("CustomPlot", 1, 0, "CustomPlotItem");
    qmlRegisterType<MyFunction>("MyFunction.module", 1, 0, "MyFunction");
    qmlRegisterType<MVideoOutput>("mvideooutput",1,0, "MVideoOutput");
	qmlRegisterType<ChargeManage>("ChargeManage",1,0,"ChargeManage");
	qmlRegisterType<Charge104>("Charge104",1,0,"Charge104");
//    qmlRegisterType<Translator>("translator", 1, 0, );
    Translator *translator = Translator::getInstance();
    translator->set_QQmlEngine(&engine);

    engine.rootContext()->setContextProperty("translator",
                                             translator);
    //font icon init
    iconFontInit();

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
