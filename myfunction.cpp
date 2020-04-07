#include "myfunction.h"
#include <QFile>
#include <QDir>

MyFunction::MyFunction()
{
//    qDebug() << "MyFunction Initial Success";
}

void MyFunction::deleteFile(QString filePath)
{
    QFile file(filePath);
    QString fileName = file.fileName();

    if(!file.remove())
        qDebug() << "delete failed:" << fileName;
    else
        qDebug() << "delete success:" << fileName;
    getPath();
}

QString MyFunction::getPath()
{
    QString path = QString("/usr/share/myir");
    return path;
}
