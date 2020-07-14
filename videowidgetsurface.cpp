/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "videowidgetsurface.h"

#include <QtWidgets>
#include <qabstractvideosurface.h>
#include <qvideosurfaceformat.h>

Q_LOGGING_CATEGORY(mlvc, "qt.multimedia.video")

VideoWidgetSurface::VideoWidgetSurface(QQuickPaintedItem *item, QObject *parent)
    : QAbstractVideoSurface(parent)
    , item(item)
    , imageFormat(QImage::Format_RGB32)
{
}

QList<QVideoFrame::PixelFormat> VideoWidgetSurface::supportedPixelFormats(
        QAbstractVideoBuffer::HandleType handleType) const
{
    if (handleType == QAbstractVideoBuffer::NoHandle) {
        return QList<QVideoFrame::PixelFormat>()
                << QVideoFrame::Format_RGB32
                << QVideoFrame::Format_ARGB32
                << QVideoFrame::Format_ARGB32_Premultiplied
                << QVideoFrame::Format_RGB565
                << QVideoFrame::Format_RGB555;
    } else {
        return QList<QVideoFrame::PixelFormat>();
    }
}

bool VideoWidgetSurface::isFormatSupported(const QVideoSurfaceFormat &format) const
{
    const QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(format.pixelFormat());
    const QSize size = format.frameSize();

    return imageFormat != QImage::Format_Invalid
            && !size.isEmpty()
            && format.handleType() == QAbstractVideoBuffer::NoHandle;
}

bool VideoWidgetSurface::start(const QVideoSurfaceFormat &format)
{
    qCDebug(mlvc) << "Video surface format:" << format << "all supported formats:" << supportedPixelFormats(format.handleType());

    if (!supportedPixelFormats(format.handleType()).contains(format.pixelFormat()))
        return false;
    return QAbstractVideoSurface::start(format);
}

void VideoWidgetSurface::stop()
{
    m_frame = QVideoFrame();
    QAbstractVideoSurface::stop();
}

bool VideoWidgetSurface::present(const QVideoFrame &frame)
{
    if (surfaceFormat().pixelFormat() != frame.pixelFormat()
            || surfaceFormat().frameSize() != frame.size()) {
        setError(IncorrectFormatError);
        stop();

        return false;
    } else {
        m_frame = frame;
        m_frameChanged = true;
        item->update();
        return true;
    }
}

void VideoWidgetSurface::paint(QPainter *painter)
{
    QMutexLocker lock(&m_frameMutex);

    bool isFrameModified = false;
    if (m_frameChanged) {
    qCDebug(mlvc)  << "==========frame changed =========";
    // Run the VideoFilter if there is one. This must be done before potentially changing the videonode below.
            if (m_frame.isValid()/* && !m_filters.isEmpty()*/) {
                const QVideoSurfaceFormat surfaceFormat = this->surfaceFormat();
                for (int i = 0; i < m_filters.count(); ++i) {
                    QAbstractVideoFilter *filter = m_filters[i].filter;
                    QVideoFilterRunnable *&runnable = m_filters[i].runnable;
                    if (filter && filter->isActive()) {
                        // Create the filter runnable if not yet done. Ownership is taken and is tied to this thread, on which rendering happens.
                        if (!runnable)
                            runnable = filter->createFilterRunnable();
                        if (!runnable)
                            continue;

                        QVideoFilterRunnable::RunFlags flags = 0;
                        if (i == m_filters.count() - 1)
                            flags |= QVideoFilterRunnable::LastInChain;

                        QVideoFrame newFrame = runnable->run(&m_frame, surfaceFormat, flags);

                        if (newFrame.isValid() && newFrame != m_frame) {
                            isFrameModified = true;
                            m_frameChanged = true;
                            m_frame = newFrame;
                        }
                    }
                }
            }

            if (!m_frame.isValid()) {
                qDebug() << "paint: no frames yet";
                m_frameChanged = false;
            }
        }

        if (m_frameChanged) {
        qCDebug(mlvc)  << "==== show frame===========";
            {
                if (m_frame.map(QAbstractVideoBuffer::ReadOnly)) {
                    const QTransform oldTransform = painter->transform();

                    if (this->surfaceFormat().scanLineDirection() == QVideoSurfaceFormat::BottomToTop) {
                       painter->scale(1, -1);
                       painter->translate(0, - item->height());
                    }

                    QImage image(
                            m_frame.bits(),
                            m_frame.width(),
                            m_frame.height(),
                            m_frame.bytesPerLine(),
                            QImage::Format_RGB32);
    //              QImage image(":/background-dark.png");
                    painter->drawImage(item->boundingRect(), image);
                    m_frame.unmap();
                }
            }

        }

        m_frameChanged = false;
        m_frame = QVideoFrame();
}
void VideoWidgetSurface::appendFilter(QAbstractVideoFilter *filter)
{
    QMutexLocker lock(&m_frameMutex);
    m_filters.append(Filter(filter));
}

void VideoWidgetSurface::clearFilters()
{
    QMutexLocker lock(&m_frameMutex);
    m_filters.clear();
}
