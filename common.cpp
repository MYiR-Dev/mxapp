#include "common.h"
#include <QProcess>
#include <QObject>
#define MB (1024 * 1024)
#define KB (1024)
GetSystemInfo::GetSystemInfo(QObject *parent): QObject(parent)
{
    process = new QProcess(this);
    connect(process, SIGNAL(readyRead()), this, SLOT(ReadData()));

}
GetSystemInfo::~GetSystemInfo()
{
    qDebug() <<  "fffff";
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
//    qDebug() <<  memoryPercent;
    return memoryPercent;
}
QString GetSystemInfo::read_memory_usage()
{
    QString mem =memoryUse+"/"+memoryAll;
    return mem;
}
void GetSystemInfo::ReadData()
{

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
        } else if (s.startsWith("MemTotal")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryAll = s.left(s.length() - 3).toInt() / KB;
        } else if (s.startsWith("MemFree")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree = s.left(s.length() - 3).toInt() / KB;
        } else if (s.startsWith("Buffers")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += s.left(s.length() - 3).toInt() / KB;
        } else if (s.startsWith("Cached")) {
            s = s.replace(" ", "");
            s = s.split(":").at(1);
            memoryFree += s.left(s.length() - 3).toInt() / KB;
            memoryUse = memoryAll - memoryFree;
            memoryPercent = 100 * memoryUse / memoryAll;
            break;
        }
    }
    memUsed = QString(tr("Used: ")).append("%1MB").arg(memoryUse);
    memFree= QString(tr("Free: ")).append("%1MB").arg(memoryFree) ;
    memTotal= QString(tr("Total: ")).append("%1MB").arg(memoryAll) ;



}
