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

#include "common.h"
#include <QProcess>
#include <QObject>
#include <QSysInfo>
#include <QThread>
#include <QTest>
#include <QStringView>
#include <QDir>
#include <QSet>

#define MB (1024 * 1024)
#define KB (1024)

// 通用 ALSA 音量初始化：扫描所有匹配的输出控制名并设置音量
void GetSystemInfo::initAlsaVolume()
{
    // 按优先级排列的常见音频输出控制名（多个可能都需要设置，如 PCM+Headphone）
    static const char *candidates[] = {
        "Master", "PCM", "Headphone", "Lineout",
        "Speaker", "Digital", "DAC", "Front"
    };

    QProcess proc;
    proc.start("amixer", {"scontrols"});
    proc.waitForFinished(2000);
    const QString scontrols = proc.readAllStandardOutput();

    bool found = false;
    for (const char *name : candidates) {
        if (scontrols.contains(QString("'%1'").arg(name))) {
            qDebug() << "ALSA: setting" << name << "to 80%";
            QProcess::execute("amixer", {"sset", name, "80%", "unmute"});
            found = true;
        }
    }
    if (!found)
        qDebug() << "ALSA: no known output control found, skip volume init";
}

GetSystemInfo::GetSystemInfo(QObject *parent): QObject(parent), totalOld(0), idleOld(0), cpuPercent(0), memoryPercent(0)
{
    process = new QProcess(this);
    connect(process, SIGNAL(readyRead()), this, SLOT(ReadData()));

    timerCPU = new QTimer(this);
    connect(timerCPU, SIGNAL(timeout()), this, SLOT(get_cpu_info()));

    timerMemory = new QTimer(this);
    connect(timerMemory, SIGNAL(timeout()), this, SLOT(get_memory_info()));

    // 存在wifi节点初始化相关资源
    if(isWifi_avail()){
        m_wifiState.available = true;

        wifi_process = new QProcess(this);
        // 待优化: 仅在 WiFi 打开时才启动 wpa_supplicant
        wifi_process->start("wpa_supplicant", {"-Dnl80211", "-i"+wifi_port ,"-c/etc/wpa_supplicant.conf", "-B"});
        connect(wifi_process, SIGNAL(finished(int)), this, SLOT(Wifi_ReadData()));

        msic_process = new QProcess(this);
        connect(msic_process, SIGNAL(finished(int)), this, SLOT(msic_ReadData()));

        wifi_process_connoct = new QProcess(this);
        connect(wifi_process_connoct, SIGNAL(finished(int)), this, SLOT(connect_ReadData()));

        // P1: 新增 wifi_cmd_process — 替代同步 waitForFinished 的异步状态机
        wifi_cmd_process = new QProcess(this);
        connect(wifi_cmd_process, SIGNAL(finished(int)), this, SLOT(wifiCmd_ReadData()));

        // P0: 新增 udhcpc_process — 替代 startDetached，可管理生命周期
        udhcpc_process = new QProcess(this);
        connect(udhcpc_process, SIGNAL(finished(int)), this, SLOT(udhcpc_ReadData()));

        // P0: DHCP 超时定时器（8 秒兜底）
        udhcpcTimeout = new QTimer(this);
        connect(udhcpcTimeout, SIGNAL(timeout()), this, SLOT(onUdchpcTimeout()));

        // WiFi 扫描延迟定时器 — 等待 wpa_supplicant 后台扫描完成
        scanTimer = new QTimer(this);
        scanTimer->setSingleShot(true);
        connect(scanTimer, SIGNAL(timeout()), this, SLOT(onScanTimeout()));

        timerWifi = new QTimer(this);
        connect(timerWifi, SIGNAL(timeout()), this, SLOT(get_wifi_info()));

        wifi_id = "0";
        connect_wifi_status.reserve(5);
        for (int i = 0; i < 5; ++i) {
            connect_wifi_status << QString();
        }
    }
}
GetSystemInfo::~GetSystemInfo()
{
    timerCPU->stop();
    timerMemory->stop();
    process->close();
    if(isWifi_avail()){
        timerWifi->stop();
        wifi_process->close();
        msic_process->close();
        wifi_process_connoct->close();
        // P0: 清理 DHCP 进程
        if (udhcpcTimeout) udhcpcTimeout->stop();
        if (scanTimer) scanTimer->stop();
        if (udhcpc_process) {
            if (udhcpc_process->state() != QProcess::NotRunning) {
                udhcpc_process->kill();
                udhcpc_process->waitForFinished(1000);
            }
        }
        // P1: 清理命令进程
        if (wifi_cmd_process) {
            if (wifi_cmd_process->state() != QProcess::NotRunning) {
                wifi_cmd_process->kill();
                wifi_cmd_process->waitForFinished(1000);
            }
            wifi_cmd_process->close();
        }
    }
}

int GetSystemInfo::Runcommand(const char * cmd,char * result, int length)
{
	if(cmd == NULL){
        printf("cmd is NULL");
        return -1;
    }
    FILE *stream ;
    stream = popen(cmd, "r");
    if(stream == NULL){
        printf("error to run cmd:%s",cmd);
        return -2;
    }
    if(result != NULL && length != 0){
        int i = fread( result, sizeof(char), length-1,  stream) ;
        if(i > (length -1)){
            printf("error to read result of %s ",cmd);
            pclose(stream);
            return -1;
        }
        result[i] = '\0';
    }
    pclose( stream );
    return 0;
}

QUrl GetSystemInfo::fromUserInput(const QString& userInput)
{

    QFileInfo fileInfo(userInput);
    if (fileInfo.exists())
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath());
    return QUrl::fromUserInput(userInput);
}
void GetSystemInfo::starttimer(int interval)
{
    timerCPU->start(interval);
    timerMemory->start(interval + 200);
}
void GetSystemInfo::stoptimer()
{
    timerCPU->stop();
    timerMemory->stop();
    qDebug() << "cpp timer close";
}

void GetSystemInfo::startwifitimer()
{
    if (!timerWifi) return;
    timerWifi->start(1000);
}

void GetSystemInfo::stopwifitimer()
{
    if (!timerWifi) return;
    timerWifi->stop();
}

bool GetSystemInfo::isWifi_avail()
{
    QDir net_path("/sys/class/net/");
    QStringList net_list = net_path.entryList({"wlan*", "mlan*"});
    if(!net_list.isEmpty())
        wifi_port = net_list[0];
    return net_list.isEmpty() ? false : true;
}

QVariantList GetSystemInfo::get_net_ports()
{
    return net_ports;
}
void GetSystemInfo::get_cpu_info()
{
    if (process->state() == QProcess::NotRunning) {
        totalNew = idleNew = 0;
        process->start(QString("cat"), QStringList()<<"/proc/stat");
    }
}
void GetSystemInfo::get_memory_info()
{
    if (process->state() == QProcess::NotRunning) {
        process->start(QString("cat"), QStringList()<<"/proc/meminfo");
    }
}
void GetSystemInfo::get_wifi_info()
{
    if (!msic_process) return;
    if (msic_process->state() == QProcess::NotRunning) {
        msic_process->start("wpa_cli", {"-i", wifi_port, "status"});
    }
}
void GetSystemInfo::wifi_open()
{
    // P1: 改异步 — ifconfig up 是幂等操作，无需检查接口是否存在
    if (!wifi_cmd_process) return;
    m_pendingCmd = Cmd_Open;
    wifi_cmd_process->start("ifconfig", {wifi_port, "up"});
}
void GetSystemInfo::wifi_close()
{
    // P1: 改异步 — 快速切换保护：重置状态机后 kill 旧命令，防止 finished 信号重入
    if (!wifi_cmd_process) return;
    if (wifi_cmd_process->state() != QProcess::NotRunning) {
        m_pendingCmd = Cmd_Idle;  // ★ 必须在 kill 前重置，防止 wifiCmd_ReadData 误判
        wifi_cmd_process->kill();
        wifi_cmd_process->waitForFinished(1000);
    }
    m_pendingCmd = Cmd_Close;
    wifi_cmd_process->start("ifconfig", {wifi_port, "down"});
}
void GetSystemInfo::connect_wifi(QString essid_passwd)
{
    if (!msic_process || !wifi_process_connoct) return;
    QStringList tmp= essid_passwd.split("+");

    // qDebug()<<tmp[0]<<tmp[1]<<tmp[2];
	if(tmp[0] != wifi_status){
		QFile file("/usr/share/connect_wifi.sh");
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
		QTextStream out(&file);
        if(tmp[2] == "true")
		{
			out << "#!/bin/sh\n";
            out << "wpa_cli -i " +wifi_port+ " remove_network 0\n";
            out << "wpa_cli -i " +wifi_port+ " add_network\n";
            out << "wpa_cli -i " +wifi_port+ " set_network " + wifi_id + " ssid " + "\'\""+tmp[0]+"\"\'"+"\n";
            out << "wpa_cli -i " +wifi_port+ " set_network "+ wifi_id + " psk "+ "\'\""+tmp[1]+"\"\'"+"\n";
            out << "wpa_cli -i " +wifi_port+ " select_network "+wifi_id+"\n";
		}
		else {
			out << "#!/bin/sh\n";
            out << "wpa_cli -i " +wifi_port+ " remove_network 0\n";
            out << "wpa_cli -i " +wifi_port+ " add_network\n";
            out << "wpa_cli -i " +wifi_port+ " set_network " + wifi_id + " ssid " + "\'\"" + tmp[0] + "\"\'" + "\n";
            out << "wpa_cli -i " +wifi_port+ " set_network " + wifi_id + " key_mgmt NONE" + "\n";
            out << "wpa_cli -i " +wifi_port+ " select_network " + wifi_id + "\n";
		}
		file.close();
        msic_process->execute("chmod", {"a+x", "/usr/share/connect_wifi.sh"});
        wifi_process_connoct->start("/bin/sh", {"-c", "/usr/share/connect_wifi.sh"});
        // P2: 确保连接过程中轮询运行，以便检测 COMPLETED + IP 获取
        startwifitimer();
	}
	}
}
void GetSystemInfo::disconnect_wifi()
{
    // P1: 改异步两阶段 — 第一阶段: wpa_cli disconnect
    if (!wifi_cmd_process) return;
    if (wifi_cmd_process->state() != QProcess::NotRunning) {
        m_pendingCmd = Cmd_Idle;  // ★ 必须在 kill 前重置，防止 wifiCmd_ReadData 误判
        wifi_cmd_process->kill();
        wifi_cmd_process->waitForFinished(1000);
    }
    // 中止正在运行的 DHCP 进程，防止关闭 WiFi 后残留
    if (udhcpcRunning) {
        udhcpc_process->kill();
        udhcpcRunning = false;
        udhcpcTimeout->stop();
    }
    // 重置扫描状态，防止关闭 WiFi 期间扫描阻塞后续操作
    m_scanning = false;
    scanTimer->stop();

    m_pendingCmd = Cmd_Disconnect;
    wifi_cmd_process->start("wpa_cli", {"-i", wifi_port, "disconnect"});
}

// 获取wifi连接状态[status, ssid, wpa_state, ip, bssid]
void GetSystemInfo::msic_ReadData()
{
    QByteArray data = msic_process->readAll();
    QTextStream stream(data);
    QString line;

    do {
        line = stream.readLine().trimmed();
        if ( line.startsWith("ssid") ){
            QStringList tmp = line.split("=");
            connect_wifi_status[1] = tmp[1];
            m_wifiState.ssid = tmp[1];
        }
        else if(line.startsWith("bssid")) {
            QStringList tmp = line.split("=");
            connect_wifi_status[4] = tmp[1];
            m_wifiState.bssid = tmp[1];
        }
        else if( line.startsWith("wpa_state") ){
            QStringList tmp = line.split("=");
            connect_wifi_status[2] = tmp[1];
            m_wifiState.wpaState = tmp[1];
            if(tmp[1] == "COMPLETED"){
                // P0: udhcpc 单次尝试 + 10s 超时，失败即停不再重试
                if(connect_wifi_status[0] != "true" && !udhcpcRunning && m_dhcpAttempts < 1){
                    m_dhcpAttempts++;
                    udhcpc_process->start("udhcpc",
                        {"-i", wifi_port, "-t", "5", "-n", "-q"});
                    udhcpcRunning = true;
                    udhcpcTimeout->start(10000);  // 10 秒超时
                } else if (m_dhcpAttempts >= 1) {
                    // DHCP 失败，停止轮询并通知 QML
                    if (timerWifi->isActive()) timerWifi->stop();
                    emit wifiConnectedStatus("false");
                }
            }else{
                connect_wifi_status[0] = "";  // 离开 COMPLETED，允许下次进入时重新 DHCP
                emit wifiConnected(connect_wifi_status[4], "false");
                m_wifiState.connected = false;
            }
        }else if(line.startsWith("ip_address")){
            QStringList tmp = line.split("=");
            connect_wifi_status[3] = tmp[1];
            m_wifiState.ipAddress = tmp[1];
            if(connect_wifi_status[2] == "COMPLETED"){
                // 获取到ip并且"COMPLETED"才算连接成功
                connect_wifi_status[0] = "true";
                m_wifiState.connected = true;
                m_dhcpAttempts = 0;  // 重置 DHCP 尝试计数
                // P0: 停止 DHCP 超时定时器
                if (udhcpcRunning) {
                    udhcpcRunning = false;
                    udhcpcTimeout->stop();
                }
                emit wifiConnected(connect_wifi_status[4], "true");
                // P2: WiFi 已连接稳定 → 停止轮询
                if (timerWifi->isActive()) {
                    timerWifi->stop();
                }
            }
        }
    } while (!line.isNull());
    wifi_status = connect_wifi_status[1];  // 存当前连接的SSID名，用于connect_wifi中的重复断开优化
}
// 检测wifi连接脚本的返回结果
void GetSystemInfo::connect_ReadData()
{
    QByteArray data = wifi_process_connoct->readAll();
    if(data.isEmpty()) return;
    QTextStream stream(data);
    QString line;

    do {
        line = stream.readLine().trimmed();
        if (line.contains("FAIL", Qt::CaseInsensitive))
            emit wifiConnectedStatus("false");
    } while (!line.isNull());
}

// P1: 异步 WiFi 命令状态机 — 根据 m_pendingCmd 分发 finished 信号
void GetSystemInfo::wifiCmd_ReadData()
{
    switch (m_pendingCmd) {
    case Cmd_Disconnect:
        // 第一阶段完成 → 执行第二阶段: ip addr flush
        wifi_cmd_process->start("ip", {"addr", "flush", "dev", wifi_port});
        m_pendingCmd = Cmd_DisconnectFlush;
        return;  // 不设回 Idle，等第二阶段 finished
    case Cmd_DisconnectFlush:
        // 两阶段都完成 → 清理状态 + 通知 QML
        connect_wifi_status[0] = "false";
        connect_wifi_status[1] = "";  // 清空SSID，确保connect_wifi中的比对不会跳过重连
        m_wifiState.connected = false;
        m_wifiState.ssid.clear();
        m_dhcpAttempts = 0;  // 重置 DHCP 尝试计数
        emit wifiConnected(connect_wifi_status[4], "false");
        break;
    case Cmd_Open:
    case Cmd_Close:
        break;  // 无需额外处理
    default:
        break;
    }
    m_pendingCmd = Cmd_Idle;
}

// P0: DHCP 进程完成回调 — 无论成功失败都重置运行标记
void GetSystemInfo::udhcpc_ReadData()
{
    udhcpcTimeout->stop();
    udhcpcRunning = false;
}

// P0: DHCP 超时处理 — 终止进程并重置状态
void GetSystemInfo::onUdchpcTimeout()
{
    if (udhcpcRunning) {
        udhcpc_process->kill();
        udhcpcRunning = false;
        qDebug() << "udhcpc timeout after 8s, process killed";
    }
}

QString GetSystemInfo::get_wifi_list()
{
    if (!msic_process || !wifi_process) return {};
    if (m_scanning) return "scanning";  // 扫描进行中，防止重复点击

    QString wirelessInterfaceStatus = getWirelessInterfaceStatus(wifi_port);
    if(wirelessInterfaceStatus == "down"){
        msic_process->start("ifconfig", {wifi_port, "up"});
    }
    // 触发后台扫描，scanTimer 延迟获取 scan_result（不阻塞 UI）
    // scan 和 scan_result 之间需要短暂间隔让 wpa_supplicant 完成扫描
    wifi_process->start("wpa_cli", {"-i", wifi_port, "scan"});
    wifi_process->waitForFinished();
    m_scanning = true;
    m_scanRetry = 0;
    scanTimer->start(300);  // 事件驱动：首次轮询 300ms，无数据自动重试
    return "dd";
}

// WiFi 扫描延迟回调 — 事件驱动轮询 scan_result
void GetSystemInfo::onScanTimeout()
{
    if (!wifi_process || wifi_process->state() != QProcess::NotRunning) return;
    wifi_process->start("wpa_cli", {"-i", wifi_port, "scan_result"});
}
void GetSystemInfo::shootScreenWindow(QQuickWindow *rootWindow)
{
    QString filePathName = "/root/";
    filePathName += QDateTime::currentDateTime().toString("yyyy-MM-dd hh-mm-ss-zzz");
    filePathName += QString(".jpg");
    QImage p = rootWindow->grabWindow();
    p.save(filePathName, "jpg");
}

QString GetSystemInfo::getWirelessInterfaceStatus(QString str)
{
    QString status = "";
    QFile file("/sys/class/net/" + str + "/operstate");
    if (file.exists())
    {
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            return status;
        QByteArray line = file.readLine();
        status = line.trimmed();
    }
    return status;
}

void GetSystemInfo::Wifi_ReadData()
{
	QByteArray data = wifi_process->readAll();

    // 事件驱动扫描：只有 "bssid..." 开头才是 scan_result 输出
    if (data.startsWith("bssid")) {
        // 检查是否有实际数据行（不止表头一行）
        int lineCount = data.count('\n');
        if (lineCount <= 1) {
            // 只有表头无数据 → 扫描未完成，300ms 后重试（最多 10 次 = 3 秒）
            if (m_scanning && m_scanRetry < 10) {
                m_scanRetry++;
                scanTimer->start(300);
            } else {
                m_scanning = false;
            }
            return;
        }
        // 有数据 → 停止轮询，正常解析
        m_scanning = false;
        scanTimer->stop();
    } else {
        // 不是 scan_result 输出（如 "OK\n"、"FAIL-BUSY\n"）→ 忽略，不发送 wifiReady
        return;
    }

    QTextStream stream(data);
    QString buffer = "";
    QString line;
    int cellCount = 0;

    do {
        line = stream.readLine().trimmed();
        if ( line.startsWith("bssid") || cellCount == 0 )
            cellCount++;
		else{
			if (line.size() > 0)
				buffer = buffer + line + "<<>>"; // line change
		}
    } while (!line.isNull());
    // 解析扫描信息
    parseIwlist(buffer);
}

void GetSystemInfo::parseIwlist(QString buffer)
{
    // QStringList bufferLines = buffer.split("<<#>>");
    // QString line;
    // QVector<QStringList> wifi_info_list;
    QVariantList  wifi_info;
    QSet<QString> seenBssids;  // 按MAC地址去重

    // 按"<<>>"分割wifi信息
    QStringList infoLines = buffer.split("<<>>");
    for(int i=0;i<infoLines.length();i++){
        QString str = infoLines[i];
        QStringList list = str.split("\t");
        if(list.length()!=5)
            continue;
        else{
            // 按BSSID(MAC地址)去重，同一MAC只保留一个
            if(seenBssids.contains(list[0]))
                continue;
            seenBssids.insert(list[0]);
            wifi_info.append(list[0]);
            if(list[3].indexOf("WPA") >= 0)
                wifi_info.append("on");
            else
                wifi_info.append("off");
            wifi_info.append(list[4]);
            wifi_info.append(list[2]);
        }
    }

    /*
    if (bufferLines.size() > 0)
    {
        if ( bufferLines.at(0).contains("No scan results") )
        {

            qDebug() << "ssid";
        }
    }

    for (int i=0 ; i < bufferLines.size() ; i++)
    {
        QStringList infoLines = bufferLines.at(i).split("<<>>");

        QString toolTip;

        for (int j=0 ; j < infoLines.size() ; j++)
        {
            line = infoLines.at(j);

            if ( line.startsWith ( "Cell" ) && line.contains( "Address:" ) )
            {
                QStringList tmp = line.split("Address:");
                toolTip.append("Address: " + tmp.at(tmp.size()-1).trimmed());
            }
            else if((!line.isEmpty()) && (!line.contains("completed")) && (!line.contains("IE: Unknown")))
                toolTip.append("\n" + line);

            if ( line.startsWith ( "ESSID:" ) )
            {
                QString ssid =line.mid ( line.indexOf ( "\"" ) + 1, line.lastIndexOf ( "\"" ) - line.indexOf ( "\"" ) - 1 );
                if(ssid.contains("\\"))
                {
                    ssid = " ";
                    qDebug() << ssid << j;
//                    QString wifi_name =QString::fromUtf8("\xE8\xBD\xAF\xE5\xB8\x9D\xE7\xA7\x91\xE6\x8A");
                }


                wifi_info.append(ssid);

            }
            if ( line.startsWith ( "Encryption key:on" ) )
                wifi_info.append("on");
            if ( line.startsWith ( "Encryption key:off" ) )
                wifi_info.append("off");
            if ( line.startsWith ( "Quality=" ) )
                wifi_info.append(line.mid (line.indexOf ("=") + 1, line.indexOf ("/") - line.indexOf ("=") - 1 ));
        }
    }
	*/
    emit wifiReady(wifi_info);
}
void GetSystemInfo::set_net_info(QString net_info)
{

    QString command;
    QStringList list = net_info.split(" ");
    qDebug() << "net port " << list[5];

    if(list.at(0) =="DHCP")
    {
        QFile readFile("/etc/network/interfaces");
        QString strAll;
        if(readFile.open((QIODevice::ReadOnly|QIODevice::Text)))
        {
            QTextStream stream(&readFile);
            strAll=stream.readAll();
        }
        readFile.close();
        QStringList strList;
        strList=strAll.split("\n");

        for(int i=0;i<strList.size();i++)
        {
            if(strList.at(i).startsWith("iface" + list[5] + "inet"))
            {
                QString tempStr=strList.at(i);
                 tempStr.replace(0,tempStr.length(),"iface" + list[5] + "inet dhcp");
                 strList.replace(i,tempStr);
            }
        }
        QFile writeFile("/etc/network/interfaces");
        if(writeFile.open((QIODevice::WriteOnly|QIODevice::Text)))
        {
             QTextStream stream(&writeFile);
            for(int i=0;i<strList.size();i++)
            {
                  stream<<strList.at(i)<<'\n';
            }

        }
        writeFile.close();
        command ="udhcpc";
        process->startDetached(command, {"-i", list[5], "-t", "3", "-n", "-q", "-b"});
    }
    else {
        if(!list.at(1).isEmpty()&& !list.at(2).isEmpty())
        {
            command ="ifconfig";
           process->startDetached(command, {list[5], list.at(1), "netmask", list.at(2)});
        }
        else {

            qDebug() << "ifconfig null";
        }

        if(!list.at(3).isEmpty() )
        {
            command ="route";
            process->startDetached(command, {"add", "default", "gw", list.at(3)});
        }
        else{
            qDebug() << "route null";
        }
        if(!list.at(4).isEmpty())
        {
            command ="echo nameserver "+ list.at(4)+ " >> /etc/resolv.conf";
            process->startDetached("/bin/sh", {"-c", command});
        }
        else {
           qDebug() << "nameserver null";
        }
    }
}
int GetSystemInfo::read_cpu_percent()
{
    return cpuPercent;
}
int GetSystemInfo::read_memory_percent()
{
    return memoryPercent;
}
QString GetSystemInfo::read_memory_usage()
{
    QString mem =memUsed+"/"+memTotal;
    return mem;
}
int GetSystemInfo::read_memory_free()
{
    return memoryFree;
}
void GetSystemInfo::set_date(QString date)
{
    QString year,month,day,hour,minute,second,command;
    int j = 0;

    QStringList list = date.split(" ");

    hour = list.at(0);
    minute = list.at(1);
    second = list.at(2);

    for(j = 0; j < list.at(3).length(); j++)
    {
        if(list.at(3)[j] >= '0' && list.at(3)[j] <= '9')
            year.append(list.at(3)[j]);
    }

    for( j = 0; j < list.at(4).length(); j++)
    {
        if(list.at(4)[j] >= '0' && list.at(4)[j] <= '9')
            month.append(list.at(4)[j]);
    }

    for( j = 0; j < list.at(5).length(); j++)
    {
        if(list.at(5)[j] >= '0' && list.at(5)[j] <= '9')
            day.append(list.at(5)[j]);
    }


    command ="date -s \""+year+"-"+month+"-"+day+" "+hour+":"+minute+":"+second+"\"";
    process->startDetached(command);

}
QString GetSystemInfo::read_system_version()
{
//    qDebug() << "WindowsVersion: " << QSysInfo::WindowsVersion;
//    qDebug() << "buildAbi: " << QSysInfo::buildAbi();
//    qDebug() << "buildCpuArchitecture: " << QSysInfo::buildCpuArchitecture();
//    qDebug() << "currentCpuArchitecture: " << QSysInfo::currentCpuArchitecture();
//    qDebug() << "kernelType: " << QSysInfo::kernelType();
//    qDebug() << "kernelVersion: " << QSysInfo::kernelVersion();
//    qDebug() << "machineHostName: " << QSysInfo::machineHostName();
//    qDebug() << "prettyProductName: " << QSysInfo::prettyProductName();
//    qDebug() << "productType: " << QSysInfo::productType();
//    qDebug() << "productVersion: " << QSysInfo::productVersion();
//    qDebug() << "Windows Version: " << QSysInfo::windowsVersion();
    return  QSysInfo::kernelType()+" "+ QSysInfo::kernelVersion();

}
int GetSystemInfo::get_net_status()
{
    QDir net_path("/sys/class/net/");
    QFileInfoList net_list = net_path.entryInfoList({"e*"});
    QList<QString> file_list;
    foreach(auto file_name, net_list){
        file_list.append(file_name.absoluteFilePath() + QString("/carrier"));
        net_ports.append(file_name.fileName());
    }
    int net_status = 0;
    foreach(auto filestring, file_list){
        QFile file(filestring);
        if (file.exists() && file.open(QIODevice::ReadOnly))
        {
            QTextStream stream(&file);
            QString line;

            do
            {
                line = stream.readLine();
                if (!line.isEmpty())
                    net_status = line.toInt();
                if(net_status)
                    break;
            }
            while (!line.isNull());
        }

        if(net_status)
            break;
    }
    return net_status;
}

int GetSystemInfo::get_net_status(QString netport)
{
    QString net_status_file = "/sys/class/net/" + netport + "/carrier";
    QFile file(net_status_file);
    int net_status = 0;
    if (file.exists() && file.open(QIODevice::ReadOnly))
    {
        QTextStream stream(&file);
        QString line;
        line = stream.readLine();
        if (!line.isEmpty())
            net_status = line.toInt();
    }
    return net_status;
}
QString GetSystemInfo::read_net_ip()
{
    QString strIpAddress;
    QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
    // 获取第一个本主机的IPv4地址
    int nListSize = ipAddressesList.size();
    for (int i = 0; i < nListSize; ++i)
    {
        if (ipAddressesList.at(i) != QHostAddress::LocalHost &&
            ipAddressesList.at(i).toIPv4Address())
        {
            strIpAddress = ipAddressesList.at(i).toString();
            break;
        }
    }
    // 如果没有找到，则以本地IP地址为IP
    if (strIpAddress.isEmpty())
        strIpAddress = QHostAddress(QHostAddress::LocalHost).toString();
    return strIpAddress;
}

QString GetSystemInfo::read_net_ip(const QString interfaceName)
{
    QList<QNetworkInterface> ipAddressesList = QNetworkInterface::allInterfaces();

    // 获取本主机的IPv4地址
    foreach (auto iface ,ipAddressesList) {
        // 查找指定接口
        if (iface.name() == interfaceName && iface.flags().testFlag(QNetworkInterface::IsUp)) {
            // 获取该接口的所有地址条目
            QList<QNetworkAddressEntry> entries = iface.addressEntries();
            foreach (auto entry , entries) {
                QHostAddress ip = entry.ip();

                // IPv4 地址
                if (ip.protocol() == QAbstractSocket::IPv4Protocol)
                    return ip.toString();
            }
        }
    }
    return {};
}
QString GetSystemInfo::read_net_mac()
{
    QList<QNetworkInterface> nets = QNetworkInterface::allInterfaces();// 获取所有网络接口列表
    int nCnt = nets.count();
    QString strMacAddr = "";
    for(int i = 0; i < nCnt; i ++)
    {
        // 如果此网络接口被激活并且正在运行并且不是回环地址，则就是我们需要找的Mac地址
        if(nets[i].flags().testFlag(QNetworkInterface::IsUp) && nets[i].flags().testFlag(QNetworkInterface::IsRunning)
            && !nets[i].flags().testFlag(QNetworkInterface::IsLoopBack))
        {
            strMacAddr = nets[i].hardwareAddress();
            break;
        }
    }
    qDebug() << strMacAddr;
    return strMacAddr;
}
int GetSystemInfo::read_system_runtime()
{
    QFile file("/proc/uptime");
    double real_uptime = 0;
    int m_info[4] = {0};
    if (file.exists() && file.open(QIODevice::ReadOnly))
    {
        QTextStream stream(&file);
        QString line;

        do
        {
            line = stream.readLine();
            if (!line.isEmpty())
                real_uptime = line.section(" ", 0, 0).trimmed().toDouble();
        }
        while (!line.isNull());
    }

    int int_real_uptime = (int)real_uptime;

    m_info[0] = int_real_uptime % 60;
    m_info[1] = int_real_uptime / 60 % 60;
    m_info[2] = int_real_uptime / 3600 % 24;
    m_info[3] = int_real_uptime / 86400;

    return int_real_uptime;
}
void GetSystemInfo::ReadData()
{
//    qDebug() << process->readAll();

    while (!process->atEnd()) {

        QString s = QLatin1String(process->readLine());
        if (s.startsWith("cpu")) {
            s = s.simplified();
            QStringList list = s.split(" ");
            idleNew = list.at(4).toInt() + list.at(5).toInt();
            for(int i = 1; i < 8; i++){
                totalNew += list.at(i).toInt();
            }
            // qDebug() << "cat /proc/stat: " << totalNew << idleNew;
            int total = qAbs(totalNew - totalOld);
            int idle = qAbs(idleNew - idleOld);
            if(total != 0 &&  totalOld > 0){
                cpuPercent = 100 * (total - idle) / total;
            }
            totalOld = totalNew;
            idleOld = idleNew;
            break;
        }
        if (s.startsWith("MemTotal")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryAll = QStringView(s).left(s.length() - 3).toInt() / KB;
        }
        if (s.startsWith("MemFree")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree = QStringView(s).left(s.length() - 3).toInt() / KB;
        }
        if (s.startsWith("Buffers")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += QStringView(s).left(s.length() - 3).toInt() / KB;
        }
        if (s.startsWith("Cached")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += QStringView(s).left(s.length() - 3).toInt() / KB;
            memoryUse = memoryAll - memoryFree;
            memoryPercent = 100 * memoryUse / memoryAll;
            break;
        }
    }
    memUsed = QString().append("%1MB").arg(memoryUse);
    memFree= QString().append("%1MB").arg(memoryFree);
    memTotal= QString().append("%1MB").arg(memoryAll);
}
