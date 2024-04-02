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

#ifndef CHARGEMANAGE_H
#define CHARGEMANAGE_H

#include <QWidget>
#include <QObject>
#include <QFile>
#include <QDebug>
#include <unistd.h>
#include <QThread>
#include <QDir>
#include <QApplication>

class my_thread:public QThread{
    Q_OBJECT
public:
    void run(){
        QString app_path=QApplication::applicationDirPath();
        QDir::setCurrent(app_path);
        system("./adl10-e &");
        sleep(1);
        QDir::setCurrent(app_path);
        system("./adl10-e_client");
    }
};

class ChargeManage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(float start_quick_total_electricity READ start_quick_charging)
    Q_PROPERTY(float start_slow_total_electricity READ start_slow_charging)
    Q_PROPERTY(float stop_total_electricity READ stop_charging)
    Q_PROPERTY(float total_electricity READ get_total_electricity)
    Q_PROPERTY(float power_factory READ get_power_factory)
    Q_PROPERTY(float voltage READ get_voltage)
    Q_PROPERTY(float current READ get_current)
    Q_PROPERTY(int start_flag READ set_start)
    Q_PROPERTY(int stop_flag READ set_stop)
public:
    explicit ChargeManage(QObject *parent = nullptr);
    float start_quick_charging();
    float start_slow_charging();
    float stop_charging();
    float get_total_electricity();
    int get_power_factory();
    int get_voltage();
    int get_current();
    int set_start();
    int set_stop();
signals:
private:
    my_thread worker;
    QString app_path;
};

#endif // CHARGEMANAGE_H
