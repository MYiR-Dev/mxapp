#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "qmlplot.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
//    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
//    QGuiApplication app(argc, argv);


    qmlRegisterType<CustomPlotItem>("CustomPlot", 1, 0, "CustomPlotItem");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
