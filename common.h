/***********************************************************************
 *  This file is part of MXAPP2

    Copyright (C) 2020-2024

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

#ifndef COMMON_H
#define COMMON_H
#include <QObject>
#include <QDebug>
#include <QProcess>
#include <QtQuick>
#include <QtCore/QFileInfo>
#include <QtCore/QUrl>
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
    Q_INVOKABLE void get_wifi_info();
    Q_INVOKABLE void set_net_info(QString net_info);
    Q_INVOKABLE QString read_net_ip();
    Q_INVOKABLE QString read_net_mac();
    Q_INVOKABLE int get_net_status();
    Q_INVOKABLE  void set_date(QString date);
    Q_INVOKABLE void wifi_open();
    Q_INVOKABLE void wifi_close();
    Q_INVOKABLE QString get_wifi_list();
    Q_INVOKABLE void connect_wifi(QString essid_passwd);
    Q_INVOKABLE void disconnect_wifi();
    Q_INVOKABLE void shootScreenWindow(QQuickWindow *rootWindow);
    Q_INVOKABLE QUrl fromUserInput(const QString& userInput);
//    Q_INVOKABLE void wifiReady();
    QString getWirelessInterfaceStatus(QString interface);
    void parseIwlist(QString buffer);
	int Runcommand(const char * cmd,char * result, int length);


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
    QString wifi_id;
    QString wifi_status;

    QTimer *timerCPU;       //定时器获取CPU信息
    QTimer *timerMemory;    //定时器获取内存信息
    QTimer *timerWifi;    //定时器获取存储信息
public slots:
    void ReadData();
    void Wifi_ReadData();
    void msic_ReadData();
    void get_memory_info();
    void get_cpu_info();
//    void get_wifi_info();
signals:
    void begin();
    void wifiReady(QVariantList  wifi_data);
    void wifiConnected(QString  wifi_essid_info);
};


#endif // COMMON_H
