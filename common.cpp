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

#define MB (1024 * 1024)
#define KB (1024)

GetSystemInfo::GetSystemInfo(QObject *parent): QObject(parent), totalOld(0), idleOld(0)
{
    process = new QProcess(this);
    connect(process, SIGNAL(readyRead()), this, SLOT(ReadData()));
    wifi_process = new QProcess(this);
    connect(wifi_process, SIGNAL(finished(int)), this, SLOT(Wifi_ReadData()));

    msic_process = new QProcess(this);
    connect(msic_process, SIGNAL(finished(int)), this, SLOT(msic_ReadData()));

    timerCPU = new QTimer(this);
    connect(timerCPU, SIGNAL(timeout()), this, SLOT(get_cpu_info()));

    timerMemory = new QTimer(this);
    connect(timerMemory, SIGNAL(timeout()), this, SLOT(get_memory_info()));

    timerWifi = new QTimer(this);
    connect(timerWifi, SIGNAL(timeout()), this, SLOT(get_wifi_info()));
    wifi_id = "0";
    connect_wifi_status.resize(4);

}
GetSystemInfo::~GetSystemInfo()
{
    timerCPU->stop();
    timerMemory->stop();
    timerWifi->stop();
    process->close();
    wifi_process->close();
    msic_process->close();
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
    timerWifi->start(1000);
}

void GetSystemInfo::stopwifitimer()
{
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
    if (msic_process->state() == QProcess::NotRunning) {
        msic_process->start("wpa_cli", {"-i", wifi_port, "status"});
    }
}
void GetSystemInfo::wifi_open()
{
    QString command;
    command = "ifconfig | grep " + wifi_port + " | wc -l";
    msic_process->start("/bin/sh", {"-c", command});
	msic_process->start(command);
	msic_process->waitForFinished();
	if(msic_process->readAll().toInt() == 0){
        command = "ifconfig";
        msic_process->start(command, {wifi_port, "up"});
		msic_process->waitForFinished();
	}
}
void GetSystemInfo::wifi_close()
{
    QString command;
    command = "ifconfig";
    msic_process->start(command, {wifi_port, "down"});
    msic_process->waitForFinished();
}
void GetSystemInfo::connect_wifi(QString essid_passwd)
{
    QStringList tmp= essid_passwd.split("+");
    QString command;
	
	qDebug()<<tmp[0]<<tmp[1]<<tmp[2];
	if(tmp[0] != wifi_status){
        command = "wpa_cli";
        msic_process->start(command, {"-i", wifi_port, "disconnect"});
		msic_process->waitForFinished();
		
		QFile file("/usr/share/connect_wifi.sh");
        file.open(QIODevice::WriteOnly | QIODevice::Text);
		QTextStream out(&file);
        if(tmp[2] == "images/wvga/system/key.png")
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
		msic_process->execute("/usr/share/connect_wifi.sh");
	}
}
void GetSystemInfo::disconnect_wifi()
{
    QString command;
    command = "wpa_cli";
    msic_process->start(command, {"-i", wifi_port, "disconnect"});
    msic_process->waitForFinished();
    msic_process->start("ip", {"addr", "flush", "dev", wifi_port});
    connect_wifi_status[0] = "false";
}

void GetSystemInfo::msic_ReadData()
{
    QTextStream stream(msic_process->readAll().data());
    QString line,command;

    do {
        line = stream.readLine().trimmed();
        if ( line.startsWith("ssid") ){
            QStringList tmp = line.split("=");
            connect_wifi_status[1] = tmp[1];
        }
		else if( line.startsWith("wpa_state") ){
			QStringList tmp = line.split("=");
            connect_wifi_status[2] = tmp[1];
            if(tmp[1] == "COMPLETED"){
                if(connect_wifi_status[0] != "true"){
                    command = "udhcpc";
                    msic_process->execute(command, {"-i", wifi_port, "-t", "3", "-n", "-q", "-b"});
                }
            }else{
                emit wifiConnected(connect_wifi_status[1], "fasle");
			}
        }else if(line.startsWith("ip_address")){
            QStringList tmp = line.split("=");
            connect_wifi_status[3] = tmp[1];
            if(connect_wifi_status[2] == "COMPLETED"){
                connect_wifi_status[0] = "true";
                emit wifiConnected(connect_wifi_status[1], "true");
            }
        }
    } while (!line.isNull());
    wifi_status = connect_wifi_status[0];
}
QString GetSystemInfo::get_wifi_list()
{
    QString wirelessInterfaceStatus = getWirelessInterfaceStatus(wifi_port);

    if(wirelessInterfaceStatus == "down"){
        msic_process->start("ifconfig", {wifi_port, "up"});
    }
    wifi_process->start("wpa_cli", {"-i", wifi_port, "scan"});
    wifi_process->waitForFinished();
    wifi_process->start("wpa_cli", {"-i", wifi_port, "scan_result"});
    if(!wifi_process->waitForStarted()){
        qDebug() << "error starting wpa_cli scan process";
    }
    return "dd";
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
    QTextStream stream(data.data());
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
    parseIwlist(buffer);
}

void GetSystemInfo::parseIwlist(QString buffer)
{
    QStringList bufferLines = buffer.split("<<#>>");
    QString line;
    QVector<QStringList> wifi_info_list;
    QVariantList  wifi_info;
	
	QStringList infoLines = buffer.split("<<>>");
	for(int i=0;i<infoLines.length();i++){
		QString str = infoLines[i];
		QStringList list = str.split("\t");
		if(list.length()!=5)
			continue;
		else{
			wifi_info.append(list[0]);
			if(list[3].indexOf("WPA") >= 0)
				wifi_info.append("on");
			else
				wifi_info.append("off");
			wifi_info.append(list[4]);
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
            s.replace(QRegularExpression("( ){1,}")," ");
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
