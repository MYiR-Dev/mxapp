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


#include "qmlprocess.h"

#include <QProcess>
#include <QDebug>
#include <QString>
#include <QByteArray>

using namespace  MQP;

Private::Private(QmlProcess *parent)
    :QProcess(parent),q(parent)
{
    connect(this, SIGNAL(started()), q, SIGNAL(started()));
    connect(this, SIGNAL(finished()), q, SIGNAL(finished()));

    connect(this, SIGNAL(readyReadStandardOutput()), q, SIGNAL(readyReadStandardOutput()));
    connect(this, SIGNAL(readyReadStandardError()), q, SIGNAL(readyReadStandardError()));

}

QmlProcess::QmlProcess(QObject *parent)
    :QObject(parent)
    ,d(new Private(this))
{
    d->shell = "bash";
}

QmlProcess::~QmlProcess(){

}

const QString &QmlProcess::shell() const
{
    return d->shell;
}

void QmlProcess::setShell(const QString &shell){
    if(shell == d->shell) return;
    d->shell = shell;
    emit shellChanged(d->shell);
}
const QString &QmlProcess::command() const
{
    return d->command;
}

void QmlProcess::setCommand(const QString &command)
{
    if (command == d->command) return;
    d->command = command;
    emit commandChanged(d->command);
}

void QmlProcess::start()
{
    d->start(d->shell);

    d->write(d->command.toUtf8().constData());
    d->closeWriteChannel();

    //d->waitForStarted();
    //d->waitForFinished();

    /*
    sh.waitForFinished();
    QByteArray output = sh.readAll();
    sh.close();
    d->start(d->program, d->arguments);
    */
}

void QmlProcess::terminate()
{
    d->terminate();
}

void QmlProcess::kill()
{
    d->kill();
}

QString QmlProcess::readAllStandardError()
{
    QByteArray errData = d->readAllStandardError();
    QString errStr =  QString(errData);

    return errStr;
}

QString QmlProcess::readAllStandardOutput()
{
    QByteArray outData = d->readAllStandardOutput();
    QString outStr = QString(outData);
//    qDebug() << "readAllStandOutput: " << outStr;

    return outStr;
}
