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

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Additional permission under GNU Lesser General Public License version 3.0
    See <https://www.gnu.org/licenses/lgpl-3.0.html> for more details.
***********************************************************************/

#ifndef COMMON_H
#define COMMON_H
#include <QObject>
#include <QDebug>
#include <QProcess>
#include <QTimer>
#include <QtQuick>
#include <QtCore/QFileInfo>
#include <QtCore/QUrl>

// WiFi 命令类型枚举 — 用于异步状态机分发 finished 信号
enum WifiCmd : int {
    Cmd_Idle,
    Cmd_Open,            // ifconfig up
    Cmd_Close,           // ifconfig down
    Cmd_Disconnect,      // wpa_cli disconnect (第一阶段)
    Cmd_DisconnectFlush  // ip addr flush (第二阶段)
};

// WiFi 状态结构体 — 统一管理连接状态
struct WifiState {
    bool available = false;   // WiFi 硬件是否可用
    bool connected = false;   // 是否已连接 (获取到 IP)
    QString ssid;             // 当前 SSID
    QString bssid;            // 当前 BSSID (MAC)
    QString ipAddress;        // IP 地址
    QString wpaState;         // wpa_supplicant 状态
};

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
    Q_INVOKABLE QString read_net_ip(const QString interfaceName);
    Q_INVOKABLE QString read_net_mac();
    Q_INVOKABLE int get_net_status();
    Q_INVOKABLE int get_net_status(QString netport);
    Q_INVOKABLE  void set_date(QString date);
    Q_INVOKABLE void wifi_open();
    Q_INVOKABLE void wifi_close();
    Q_INVOKABLE QString get_wifi_list();
    Q_INVOKABLE void connect_wifi(QString essid_passwd);
    Q_INVOKABLE void disconnect_wifi();
    Q_INVOKABLE void shootScreenWindow(QQuickWindow *rootWindow);
    Q_INVOKABLE QUrl fromUserInput(const QString& userInput);
    QString getWirelessInterfaceStatus(QString str);
    void parseIwlist(QString buffer);
	int Runcommand(const char * cmd,char * result, int length);


    Q_INVOKABLE void starttimer(int interval);
    Q_INVOKABLE void stoptimer();
    Q_INVOKABLE void startwifitimer();
    Q_INVOKABLE void stopwifitimer();
    Q_INVOKABLE bool isWifi_avail();
    Q_INVOKABLE bool isScanning() const { return m_scanning; }  // 扫描防重入
    Q_INVOKABLE QVariantList get_net_ports();

    // 通用 ALSA 音量初始化：扫描并设置所有匹配的输出控制
    Q_INVOKABLE void initAlsaVolume();
    QProcess *process = nullptr;
    QProcess *wifi_process = nullptr;
    QProcess *msic_process = nullptr;          // 专用于 wpa_cli status 轮询
    QProcess *wifi_process_connoct = nullptr;
    QProcess *wifi_cmd_process = nullptr;      // 新增: ifconfig/wpa_cli 命令专用 (异步)
    QProcess *udhcpc_process = nullptr;         // 新增: DHCP 客户端生命周期管理
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
    QString wifi_port;
    QStringList connect_wifi_status;  // 连接wifi信息 [0]=status, [1]=ssid, [2]=wpa_state, [3]=ip, [4]=bssid
    QVariantList net_ports;

    // WiFi 状态统一管理
    WifiState m_wifiState;
    // 异步命令状态机
    WifiCmd m_pendingCmd = Cmd_Idle;
    // DHCP 防重入
    bool udhcpcRunning = false;
    int m_dhcpAttempts = 0;            // DHCP 尝试次数，超限停止

    QTimer *timerCPU = nullptr;       //定时器获取CPU信息
    QTimer *timerMemory = nullptr;    //定时器获取内存信息
    QTimer *timerWifi = nullptr;      //定时器获取WiFi信息
    QTimer *udhcpcTimeout = nullptr;  //定时器DHCP超时检测
    QTimer *scanTimer = nullptr;       //定时器WiFi扫描延迟
    bool m_scanning = false;           //扫描进行中，防重复点击
    int m_scanRetry = 0;               //扫描重试计数，超限自动停止
public slots:
    void ReadData();
    void Wifi_ReadData();
    void msic_ReadData();
    void get_memory_info();
    void get_cpu_info();
    void connect_ReadData();
    void wifiCmd_ReadData();          // 新增: 异步 WiFi 命令 finished 处理
    void onUdchpcTimeout();           // 新增: DHCP 超时处理
    void udhcpc_ReadData();           // 新增: DHCP 完成处理
    void onScanTimeout();             // 新增: 扫描完成后获取结果
//    void get_wifi_info();
signals:
    void begin();
    void wifiReady(QVariantList  wifi_data);
    void wifiConnected(QString  wifi_essid_info, QString flag);
    void wifiConnectedStatus(QString flag);
};


#endif // COMMON_H
