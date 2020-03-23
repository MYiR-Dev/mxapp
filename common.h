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

    Q_INVOKABLE int read_cpu_percent();
    Q_INVOKABLE int read_memory_percent();
    Q_INVOKABLE QString read_memory_usage();
    Q_INVOKABLE int read_memory_free();
    Q_INVOKABLE QString read_system_version();
    Q_INVOKABLE int read_system_runtime();
    Q_INVOKABLE void get_net_info();
    Q_INVOKABLE void set_net_info(QString net_info);
    Q_INVOKABLE QString read_net_ip();
    Q_INVOKABLE QString read_net_mac();
    Q_INVOKABLE  void set_date(QString date);
    Q_INVOKABLE QString get_wifi_list();
    QString getWirelessInterfaceStatus(QString interface);
    void parseIwlist(QString buffer);

    void Start(int interval);
    QProcess *process;
    QProcess *wifi_process;
    QProcess *msic_process;
    int totalNew, idleNew, totalOld, idleOld;
    int cpuPercent;
    int memoryPercent;
    int memoryAll;
    int memoryUse;
    int memoryFree;
    QString memUsed;
    QString memFree;
    QString memTotal;

    QTimer *timerCPU;       //定时器获取CPU信息
    QTimer *timerMemory;    //定时器获取内存信息
    QTimer *timerStorage;    //定时器获取存储信息
public slots:
    void ReadData();
    void Wifi_ReadData();
    void get_memory_info();
    void get_cpu_info();
signals:
    void begin();
};


#endif // COMMON_H
