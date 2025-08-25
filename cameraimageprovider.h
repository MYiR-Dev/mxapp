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

#ifndef CAMERAIMAGEPROVIDER_H
#define CAMERAIMAGEPROVIDER_H

#include <QQuickItem>
#include <QQuickItem>
#include <QQuickImageProvider>
#include <QImage>
#include "yuyv_qthread.h"
class CameraImageProvider : public QQuickImageProvider
{
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE void captureImg(QString path);
    CameraImageProvider(QObject *parent = nullptr);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
    void registerImageProvider(QQmlEngine *engine);
    QImage img;
    YUYVQThread *thread;
signals:
    void callQmlRefreshImage();
    void callQmlSavePath(QString path);
private slots:
    void slot_img(QImage img);
};

#endif // CAMERAIMAGEPROVIDER_H
