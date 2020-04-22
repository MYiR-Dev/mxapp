#include "common.h"
#include <QProcess>
#include <QObject>
#include <QSysInfo>
#include <QThread>
#include <QTest>
#define MB (1024 * 1024)
#define KB (1024)

GetSystemInfo::GetSystemInfo(QObject *parent): QObject(parent)
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

    this->Start(100);
}
GetSystemInfo::~GetSystemInfo()
{
    qDebug() <<  "fffff";

    timerCPU->stop();
    timerMemory->stop();
    timerWifi->stop();
    process->close();
    wifi_process->close();
    msic_process->close();
    delete timerCPU;
    delete timerMemory;
    delete timerWifi;
    delete process;
    delete wifi_process;
    delete msic_process;
}
QUrl GetSystemInfo::fromUserInput(const QString& userInput)
{

    QFileInfo fileInfo(userInput);
    if (fileInfo.exists())
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath());
    return QUrl::fromUserInput(userInput);
}
void GetSystemInfo::Start(int interval)
{
    timerCPU->start(interval);
    timerMemory->start(interval + 200);
    timerWifi->start(1000);
}
void GetSystemInfo::get_cpu_info()
{

    if (process->state() == QProcess::NotRunning) {
        totalNew = idleNew = 0;
        process->start("cat /proc/stat");
    }


}
void GetSystemInfo::get_memory_info()
{
    if (process->state() == QProcess::NotRunning) {
        process->start("cat /proc/meminfo");
    }
}
void GetSystemInfo::get_wifi_info()
{
    if (msic_process->state() == QProcess::NotRunning) {
        msic_process->start("iwconfig wlan0");
    }

}
void GetSystemInfo::wifi_open()
{
    QString command;
    command = "killall wpa_supplicant";
//    QThread::msleep(2000);
    msic_process->start(command);
    msic_process->waitForFinished();
    command = "ifconfig wlan0 up";
    msic_process->start(command);
    msic_process->waitForFinished();
//    QTest::qSleep(1000);
    command = "iwlist wlan0 scan";
    wifi_process->start(command);

    command = "wpa_supplicant -i wlan0 -c /etc/wpa_supplicant.conf -B";
    msic_process->start(command);
    msic_process->waitForFinished();
//    QTest::qSleep(1000);
}
void GetSystemInfo::wifi_close()
{
    QString command;
//    command = "killall udhcpc";
//    msic_process->start(command);
//    msic_process->waitForFinished();
    command = "wpa_cli -i wlan0 disconnect";
    msic_process->start(command);
    msic_process->waitForFinished();
    command = "killall wpa_supplicant";
    msic_process->start(command);
    msic_process->waitForFinished();
    command = "ifconfig wlan0 down";
    msic_process->start(command);
    msic_process->waitForFinished();

}
void GetSystemInfo::connect_wifi(QString essid_passwd)
{
    QStringList tmp= essid_passwd.split("+");
    QString command;

    qDebug() << tmp[0] << tmp[1]<<tmp[2];
    QFile file("/usr/share/connect_wifi.sh");
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);

    if(tmp[2] == "qrc:/images/wvga/system/key.png")
    {
        out << "#!/bin/bash\n";
        out << "wpa_cli -i wlan0 remove_network 0\n";
        out << "wpa_cli -i wlan0 add_network\n";
        out << "wpa_cli -i wlan0 set_network " + wifi_id + " ssid " + "\'\""+tmp[0]+"\"\'"+"\n";
        out << "wpa_cli -i wlan0 set_network "+ wifi_id + " psk "+ "\'\""+tmp[1]+"\"\'"+"\n";
        out <<  "wpa_cli -i wlan0 select_network "+wifi_id+"\n";

    }
    else {

        out << "#!/bin/bash\n";
        out << "wpa_cli -i wlan0 remove_network 0\n";
        out << "wpa_cli -i wlan0 add_network\n";
        out << "wpa_cli -i wlan0 set_network " + wifi_id + " ssid " + "\'\""+tmp[0]+"\"\'"+"\n";
        out << "wpa_cli -i wlan0 set_network "+ wifi_id +" key_mgmt NONE"+"\n";
        out <<  "wpa_cli -i wlan0 select_network "+wifi_id+"\n";

    }
    file.close();
    msic_process->execute("chmod +x /usr/share/connect_wifi.sh");
    msic_process->execute("/usr/share/connect_wifi.sh");

}
void GetSystemInfo::disconnect_wifi()
{
    QString command;
    command = "wpa_cli -i wlan0 disconnect";
    msic_process->start(command);
    msic_process->waitForFinished();
}
void GetSystemInfo::msic_ReadData()
{
    QTextStream stream(msic_process->readAll().data());
    QString wifi_connect_status;
    QString line,command;


    do {

        line = stream.readLine().trimmed();
//        qDebug() <<"msic_ReadData"<< line;
        if ( line.startsWith("wlan0") )
        {
            QStringList tmp = line.split("ESSID:");
            QString temp = tmp[1];
            if(tmp[1] != "on/off")
            {

                wifi_connect_status =temp.mid ( temp.indexOf ( "\"" ) + 1, temp.lastIndexOf ( "\"" ) - temp.indexOf ( "\"" ) - 1 );
                if(wifi_status != wifi_connect_status && wifi_status != NULL)
                {
                    emit wifiConnected(wifi_connect_status);
                    command = "udhcpc -i wlan0 -t 3 -n -q -b";
                    msic_process->start(command);
                }

            }
        }


    } while (!line.isNull());
    wifi_status = wifi_connect_status;
}
QString GetSystemInfo::get_wifi_list()
{
    QString wifi_interface = "wlan0";
    QString wirelessInterfaceStatus = getWirelessInterfaceStatus(wifi_interface);

    if(wirelessInterfaceStatus == "down")
    {
        msic_process->start("/sbin/ifconfig",QStringList() << wifi_interface << "up");

    }
    QString cmd="/sbin/iwlist";
    QStringList opts;
    wifi_process->start(cmd, opts << wifi_interface << "scan");

    if(!wifi_process->waitForStarted())
    {
        qDebug() << "error starting iwlist process";

    }
    return "dd";
}
void GetSystemInfo::shootScreenWindow(QQuickWindow *rootWindow)
{
//    QImage image = rootWindow->grabWindow();
    QString filePathName = "/root/";
    filePathName += QDateTime::currentDateTime().toString("yyyy-MM-dd hh-mm-ss-zzz");
    filePathName += QString(".jpg");
    QImage p = rootWindow->grabWindow();
    p.save(filePathName, "jpg");
}

QString GetSystemInfo::getWirelessInterfaceStatus(QString interface)
{
    QString status = "";
    QFile file("/sys/class/net/" + interface + "/operstate");
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
    QTextStream stream(wifi_process->readAll().data());
    QString buffer = "";
    QString line;
    int cellCount = 0;

    do {

        line = stream.readLine().trimmed();

        if ( line.startsWith("Cell") )
        {
            if (cellCount > 0)
                buffer = buffer + "<<#>>"; // cell change

            cellCount ++;
        }

        if (line.size() > 0)
            buffer = buffer + line + "<<>>"; // line change

    } while (!line.isNull());
//    qDebug() << buffer;
    parseIwlist(buffer);
}
void GetSystemInfo::parseIwlist(QString buffer)
{
    QStringList bufferLines = buffer.split("<<#>>");
    QString line;
    QVector<QStringList> wifi_info_list;
    QVariantList  wifi_info;
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
//        for(int i = 0; i< wifi_info.size();++i)
//        {
//            QString tmp = wifi_info.at(i);
//            qDebug()<<"tmp ="<< i<<tmp;
//        }
//        wifi_info_list.append(wifi_info);
    }
//    for(int i = 0; i< wifi_info_list.size();++i)
//    {
//        QStringList ifno = wifi_info_list.at(i);
//        qDebug()<<"ifno =";
//        for(int i = 0; i< ifno.size();++i)
//        {
//            QString tmp = ifno.at(i);
//            qDebug()<<"tmp ="<< i<<tmp;
//        }
//    }
    emit wifiReady(wifi_info);
}
void GetSystemInfo::set_net_info(QString net_info)
{

    QString command;
//    qDebug() << "net_info:" <<net_info;
    QStringList list = net_info.split(" ");

    if(list.at(0) =="DHCP")
    {
//        qDebug() << "DHCP";

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
            if(strList.at(i).startsWith("iface eth0 inet"))
            {
                QString tempStr=strList.at(i);
//                 qDebug() << tempStr;
                 tempStr.replace(0,tempStr.length(),"iface eth0 inet dhcp");
//                 qDebug() << tempStr;
                 strList.replace(i,tempStr);
//                 qDebug() << strList.at(i);
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
        command ="udhcpc -i eth0 -t 3 -n -q -b";
//        qDebug() << "command: " << command;
        process->startDetached(command);
    }
    else {
        if(!list.at(1).isEmpty()&& !list.at(2).isEmpty())
        {
            command ="ifconfig eth0 "+ list.at(1) +" netmask "+list.at(2);
//            qDebug() << "command: " << command;
           process->startDetached(command);
        }
        else {

            qDebug() << "ifconfig null";
        }

        if(!list.at(3).isEmpty() )
        {
            command ="route add default gw "+ list.at(3);
//            qDebug() << "command: " << command;
            process->startDetached(command);
        }
        else{
            qDebug() << "route null";
        }
        if(!list.at(4).isEmpty())
        {
            command ="echo \"nameserver "+ list.at(4)+ "\""+">> /etc/resolv.conf";
//            qDebug() << "command: " << command;
            process->startDetached(command);
        }
        else {
           qDebug() << "nameserver null";
        }
    }

//    process->startDetached(command);
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
//    qDebug() << "date: " << date;
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
//    qDebug() << "command: " << command;
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
    QFile file("/sys/class/net/eth0/carrier");
    int net_status = 0;
    int m_info[4] = {0};
    if (file.exists() && file.open(QIODevice::ReadOnly))
    {
        QTextStream stream(&file);
        QString line;

        do
        {
            line = stream.readLine();
            if (!line.isEmpty())
                net_status = line.toInt();
        }
        while (!line.isNull());
    }
    qDebug() << "net_status" << net_status;
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

    qDebug() << strIpAddress;
    return strIpAddress;
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
            QStringList list = s.split(" ");
            idleNew = list.at(5).toInt();
            foreach (QString value, list) {
                totalNew += value.toInt();
            }

            int total = totalNew - totalOld;
            int idle = idleNew - idleOld;
            cpuPercent = 100 * (total - idle) / total;

            totalOld = totalNew;
            idleOld = idleNew;
            break;
        }
        if (s.startsWith("MemTotal")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryAll = s.left(s.length() - 3).toInt() / KB;
        }
        if (s.startsWith("MemFree")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree = s.left(s.length() - 3).toInt() / KB;
        }
        if (s.startsWith("Buffers")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += s.left(s.length() - 3).toInt() / KB;
        }
        if (s.startsWith("Cached")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += s.left(s.length() - 3).toInt() / KB;
            memoryUse = memoryAll - memoryFree;
            memoryPercent = 100 * memoryUse / memoryAll;
            break;
        }
    }
    memUsed = QString().append("%1MB").arg(memoryUse);
    memFree= QString().append("%1MB").arg(memoryFree) ;
    memTotal= QString().append("%1MB").arg(memoryAll) ;



}
