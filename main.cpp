#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>

#include "qmlplot.h"
#include "common.h"
#include "myfunction.h"

void iconFontInit()
{
    //加载fontawesome-webfont.ttf字体图标库
    //官网:www.fontawesome.com.cn
    int fontId_fws = QFontDatabase::addApplicationFont(":/fonts/fontawesome-webfont.ttf");  //加入字体，并获取字体ID
    QString fontName_fws = QFontDatabase::applicationFontFamilies(fontId_fws).at(0);    //获取字体名称
    QFont iconFont_fws = QFont(fontName_fws);
    iconFont_fws.setPixelSize(20);     //设置字体大小
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
    //font icon init
    iconFontInit();

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
