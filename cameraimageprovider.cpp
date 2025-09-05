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

#include "cameraimageprovider.h"
#include <QDebug>

CameraImageProvider* CameraImageProvider::ImageProviderSingle = nullptr;
CameraImageProvider::CameraImageProvider(): QQuickImageProvider(QQuickImageProvider::Image)
{

}

CameraImageProvider *CameraImageProvider::getInstance()
{
    if(ImageProviderSingle != nullptr)
        return ImageProviderSingle;
    ImageProviderSingle = new CameraImageProvider;
    return ImageProviderSingle;
}

QImage CameraImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    return this->img;
}

QPixmap CameraImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    return QPixmap::fromImage(this->img);
}

void showImage::captureImg(QString path)
{
    QDir dir;
    if(!dir.exists("/usr/share/myir/Capture"))
        dir.mkpath("/usr/share/myir/Capture");
    bool ret = this->img.save(path + ".jpg");
    if(ret){
        qDebug()<<"save img:"<<path + ".jpg" << "succ";
        emit callQmlSavePath(path + ".jpg");
    }
    else
        qDebug()<<"save img:"<<path + ".jpg" << "fail";
}
//qml端点击打开摄像头后调用
//打开识别到第一个具有预览功能的/dev/video*节点
void showImage::startCamera()
{
    getCameraList();
    foreach (QString cameraPath, cameraList) {
        if(!thread->set_device(QString(cameraPath))){
            qDebug() << "can't open camera" << cameraPath;
            // return;
        }else{
            qDebug() << cameraPath << "camera open successed";
            thread->start();
            return ;
        }
    }
    qDebug() << "dont have supported camera";
    return ;
}

//qml端点击退出调用
void showImage::stopCamera()
{
    thread->exit_camera();
}

showImage::showImage(QObject *parent) : QObject(parent)
{
    thread = Camera_qthread::getInstance();
    cameraImageProvider = CameraImageProvider::getInstance();

    connect(thread,SIGNAL(sign_img(QImage)),this,SLOT(slot_img(QImage)));
}
//获取所有的/dev/video*
void showImage::getCameraList()
{
    QDir devDir("/dev");
    QString devStr("/dev/");
    cameraList.clear();
    cameraList = devDir.entryList({"video*"}, QDir::System);
    for(int i = 0; i < cameraList.count(); i++){
        cameraList[i] = devStr + cameraList[i];
    }
}

void showImage::slot_img(QImage img)
{
    this->img = img;
    cameraImageProvider->img = img;
    emit callQmlRefreshImage();
}
