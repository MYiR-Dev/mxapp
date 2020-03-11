#include "common.h"
#include <QProcess>
#include <QObject>
#include <QSysInfo>
#define MB (1024 * 1024)
#define KB (1024)
GetSystemInfo::GetSystemInfo(QObject *parent): QObject(parent)
{
    process = new QProcess(this);
    connect(process, SIGNAL(readyRead()), this, SLOT(ReadData()));

    timerCPU = new QTimer(this);
    connect(timerCPU, SIGNAL(timeout()), this, SLOT(get_cpu_info()));

    timerMemory = new QTimer(this);
    connect(timerMemory, SIGNAL(timeout()), this, SLOT(get_memory_info()));



    this->Start(100);
}
GetSystemInfo::~GetSystemInfo()
{
    qDebug() <<  "fffff";

    timerCPU->stop();
    timerMemory->stop();
    process->close();
    delete timerCPU;
    delete timerMemory;
    delete timerStorage;
    delete process;
}

void GetSystemInfo::Start(int interval)
{
    timerCPU->start(interval);
    timerMemory->start(interval + 200);
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
void GetSystemInfo::get_net_info()
{


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
