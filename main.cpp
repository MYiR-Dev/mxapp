#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include "qmlplot.h"
#include "common.h"
#include "myfunction.h"
#include "translator.h"
void iconFontInit()
{
    //�1�7�1�7�1�7�1�7fontawesome-webfont.ttf�1�7�1�7�1�7�1�7�0�0�1�7�1�7�1�7�1�7
    //�1�7�1�7�1�7�1�7:www.fontawesome.com.cn
//
    int fontId_digital = QFontDatabase::addApplicationFont(":/fonts/DIGITAL/DS-DIGIB.TTF");
    int fontId_fws = QFontDatabase::addApplicationFont(":/fonts/fontawesome-webfont.ttf");  //�1�7�1�7�1�7�1�7�1�7�1�7�1�7�Ʉ1�7�1�7�1�7�1�7�0�0�1�7�1�7�1�7�1�7ID

    QString fontName_fws = QFontDatabase::applicationFontFamilies(fontId_fws).at(0);    //�1�7�1�7�0�0�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7
    QFont iconFont_fws;
    iconFont_fws.setFamily(fontName_fws);
    QApplication::setFont(iconFont_fws);
    iconFont_fws.setPixelSize(20);     //�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7�1�7��
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
