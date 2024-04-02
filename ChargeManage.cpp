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


#include "ChargeManage.h"

ChargeManage::ChargeManage(QObject *parent) : QObject(parent)
{
    if(worker.isRunning())
        worker.exit();
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

//开始慢速充电
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

int ChargeManage::set_start()
{
    worker.start();
    return 1;
}

int ChargeManage::set_stop()
{
    worker.exit();
    return 1;
}
