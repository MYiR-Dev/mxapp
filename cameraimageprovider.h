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

#include <QQuickImageProvider>
#include <QImage>
#include <QPixmap>
#include <QQmlEngine>
#include <QDir>
#include <QStringList>
#include "camera_qthread.h"

class CameraImageProvider : public QQuickImageProvider
{
public:
    static CameraImageProvider* getInstance();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
    QImage img;
private:
    explicit CameraImageProvider();
    static CameraImageProvider* ImageProviderSingle;
};


class showImage : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE void captureImg(QString path);
    Q_INVOKABLE void startCamera();
    Q_INVOKABLE void selectCamera(QString path);
    Q_INVOKABLE void stopCamera();
    Q_INVOKABLE QStringList getCameraList();
    Q_INVOKABLE bool fileExists(QString path);  // 检查文件是否存在

    showImage(QObject *parent = nullptr);
    Camera_qthread *thread;
    QImage img;
    CameraImageProvider *cameraImageProvider;
    QStringList cameraList;
signals:
    void callQmlRefreshImage();
    void callQmlSavePath(QString path);
    void selectCameraPort(QString port);
private slots:
    void slot_img(QImage img);
};

#endif // CAMERAIMAGEPROVIDER_H
