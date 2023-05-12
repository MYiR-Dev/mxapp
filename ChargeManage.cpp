#include "ChargeManage.h"

ChargeManage::ChargeManage(QObject *parent) : QObject(parent)
{
    worker.start();
    app_path=QApplication::applicationDirPath();
}


//开始快速充电
float ChargeManage::start_quick_charging()
{
    float result=get_total_electricity();
    QDir::setCurrent(app_path);
    system("touch quick_start.txt");
    return result;
}

//开始慢速充电sdsdas
float ChargeManage::start_slow_charging()
{
    float result=get_total_electricity();
    QDir::setCurrent(app_path);
    system("touch slow_start.txt");
    return result;
}

//停止充电
float ChargeManage::stop_charging()
{
    float result=get_total_electricity();
    QDir::setCurrent(app_path);
    system("touch stop.txt");
    return result;
}

//获取总功率
float ChargeManage::get_total_electricity()
{
    QFile file(app_path+"/total_electricity.txt");
    if(!file.open(QIODevice::ReadWrite | QIODevice::Text)){
        qDebug()<<"文件打开失败";
        return -1;
    }
    float result=file.readAll().toFloat();
    file.close();
    return result;
}

//获取功率因子
int ChargeManage::get_power_factory()
{
    QFile file(app_path+"/power_factory.txt");
    if(!file.open(QIODevice::ReadWrite | QIODevice::Text)){
        qDebug()<<"文件打开失败";
        return -1;
    }
    int result=file.readAll().toInt();
    file.close();
    return result;
}

//获取电压
int ChargeManage::get_voltage()
{
    QFile file(app_path+"/voltage.txt");
    if(!file.open(QIODevice::ReadWrite | QIODevice::Text)){
        qDebug()<<"文件打开失败";
        return -1;
    }
    int result=file.readAll().toInt();
    file.close();
    return result;
}

//获取电流
int ChargeManage::get_current()
{
    QFile file(app_path+"/current.txt");
    if(!file.open(QIODevice::ReadWrite | QIODevice::Text)){
        qDebug()<<"文件打开失败";
        return -1;
    }
    int result=file.readAll().toInt();
    file.close();
    return result;
}
