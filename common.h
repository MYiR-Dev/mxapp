#ifndef COMMON_H
#define COMMON_H
#include <QObject>
#include <QDebug>
#include <QProcess>
#include <QtQuick>
class GetSystemInfo: public QObject
{
    Q_OBJECT

public:
    GetSystemInfo(QObject *parent = nullptr);
    virtual ~GetSystemInfo();
    Q_INVOKABLE void get_cpu_info();
    Q_INVOKABLE int read_cpu_percent();
    Q_INVOKABLE void get_memory_info();
    Q_INVOKABLE int read_memory_percent();
    Q_INVOKABLE QString read_memory_usage();
    Q_INVOKABLE void get_net_info();

    QProcess *process;
    int totalNew, idleNew, totalOld, idleOld;
    int cpuPercent;
    int memoryPercent;
    int memoryAll;
    int memoryUse;
    int memoryFree;
    QString memUsed;
    QString memFree;
    QString memTotal;
public slots:
    void ReadData();
signals:
    void begin();
};


#endif // COMMON_H
