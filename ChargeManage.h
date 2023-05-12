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

        while(1){
        }
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
public:
    explicit ChargeManage(QObject *parent = nullptr);
    float start_quick_charging();
    float start_slow_charging();
    float stop_charging();
    float get_total_electricity();
    int get_power_factory();
    int get_voltage();
    int get_current();
signals:
private:
    my_thread worker;
    QString app_path;
};

#endif // CHARGEMANAGE_H
