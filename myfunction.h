#ifndef MYFUNCTION_H
#define MYFUNCTION_H

#include <QObject>
#include <QDebug>

class MyFunction: public QObject
{
Q_OBJECT
public:
    MyFunction();
public slots:
    void deleteFile(QString filePath);
    QString getPath();

signals:
    void begin();
};

#endif // MYFUNCTION_H
