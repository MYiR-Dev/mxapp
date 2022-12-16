#include "mvideooutput.h"
#include <QQuickItem>
#include <QPainter>
#include <QObject>
#include <QRunnable>
#include <QtMultimedia/qmediaobject.h>
#include <QtMultimedia/qmediaservice.h>
#include "videowidgetsurface.h"
#include <QtMultimedia/qabstractvideofilter.h>
#include <QtMultimedia/qvideorenderercontrol.h>

MVideoOutput::MVideoOutput(QQuickItem *parent):
    QQuickPaintedItem(parent),
    m_sourceType(NoSource),
    m_fillMode(PreserveAspectFit),
    m_geometryDirty(true)
{
    m_surface = new VideoWidgetSurface(this);
    QObject::connect(m_surface, SIGNAL(surfaceFormatChanged(QVideoSurfaceFormat)),
                     this, SLOT(_q_updateNativeSize()), Qt::QueuedConnection);

    setFlag(ItemHasContents, true);
}

MVideoOutput::~MVideoOutput()
{
    releaseSource();
    releaseControl();
    delete m_surface;
    m_source.clear();
    _q_updateMediaObject();
}

void MVideoOutput::paint(QPainter *painter)
{
    _q_updateGeometry();

    if(m_surface){
        m_surface->paint(painter);
    }
}

void MVideoOutput::releaseSource()
{
    if(source() && sourceType() == MVideoOutput::VideoSurfaceSource){
        if (source()->property("videoSurface").value<QAbstractVideoSurface*>() == m_surface)
            source()->setProperty("videoSurface", QVariant::fromValue<QAbstractVideoSurface*>(0));
    }
    m_surface->stop();
}

void MVideoOutput::releaseControl(){
    if (m_rendererControl) {
        m_rendererControl->setSurface(0);
        if (m_service)
            m_service->releaseControl(m_rendererControl);
        m_rendererControl = 0;
    }
}

void MVideoOutput::setSource(QObject *source)
{
    qDebug() << "source is" << source;

    if (source == m_source.data())
        return;

    if (m_source && m_sourceType == MediaObjectSource) {
        disconnect(m_source.data(), 0, this, SLOT(_q_updateMediaObject()));
        disconnect(m_source.data(), 0, this, SLOT(_q_updateCameraInfo()));
    }

    releaseSource();

    m_source = source;

    if (m_source) {
        const QMetaObject *metaObject = m_source.data()->metaObject();

        int mediaObjectPropertyIndex = metaObject->indexOfProperty("mediaObject");
        if (mediaObjectPropertyIndex != -1) {
            const QMetaProperty mediaObjectProperty = metaObject->property(mediaObjectPropertyIndex);

            if (mediaObjectProperty.hasNotifySignal()) {
                QMetaMethod method = mediaObjectProperty.notifySignal();
                QMetaObject::connect(m_source.data(), method.methodIndex(),
                                     this, this->metaObject()->indexOfSlot("_q_updateMediaObject()"),
                                     Qt::DirectConnection, 0);

            }

            int deviceIdPropertyIndex = metaObject->indexOfProperty("deviceId");
            if (deviceIdPropertyIndex != -1) { // Camera source
                const QMetaProperty deviceIdProperty = metaObject->property(deviceIdPropertyIndex);

                if (deviceIdProperty.hasNotifySignal()) {
                    QMetaMethod method = deviceIdProperty.notifySignal();
                    QMetaObject::connect(m_source.data(), method.methodIndex(),
                                         this, this->metaObject()->indexOfSlot("_q_updateCameraInfo()"),
                                         Qt::DirectConnection, 0);

                }
            }

            m_sourceType = MediaObjectSource;
        } else if (metaObject->indexOfProperty("videoSurface") != -1) {
            // Can not assign videoSurface.
            qWarning()<< "can not assign videoSurface";
              m_geometryDirty = true;
              if(m_surface){
                  m_surface->clearFilters();
                  for (int i = 0; i < m_filters.count(); ++i)
                      m_surface->appendFilter(m_filters[i]);

                    m_source.data()->setProperty("videoSurface",
                                             QVariant::fromValue<QAbstractVideoSurface*>(m_surface));
                    m_sourceType = VideoSurfaceSource;
                }
              else {
                  m_sourceType = NoSource;
              }
        } else {
            m_sourceType = NoSource;
        }
    } else {
        m_sourceType = NoSource;
    }

    _q_updateMediaObject();
    emit sourceChanged();
}

bool MVideoOutput::_q_init(QMediaService *service)
{
    // When there is no service, the source is an object with a "videoSurface" property, which
    // doesn't require a QVideoRendererControl and therefore always works
    if (!service)
        return true;

    if (QMediaControl *control = service->requestControl(QVideoRendererControl_iid)) {
        if ((m_rendererControl = qobject_cast<QVideoRendererControl *>(control))) {
            m_rendererControl->setSurface(m_surface);
            m_service = service;
            return true;
        }
    }
    return false;
}

void MVideoOutput::_q_updateMediaObject()
{
    QMediaObject *mediaObject = 0;

    if (m_source)
        mediaObject = qobject_cast<QMediaObject*>(m_source.data()->property("mediaObject").value<QObject*>());

    qDebug() << "media object is" << mediaObject;

    if (m_mediaObject.data() == mediaObject)
        return;

    m_mediaObject.clear();
    m_service.clear();

    if (mediaObject) {
        if (QMediaService *service = mediaObject->service()) {
            if (_q_init(service)) {
                m_service = service;
                m_mediaObject = mediaObject;
            }
        }
    }

    _q_updateCameraInfo();
}

void MVideoOutput::_q_updateCameraInfo()
{
    if (m_mediaObject) {
        const QCamera *camera = qobject_cast<const QCamera *>(m_mediaObject);
        if (camera) {
            QCameraInfo info(*camera);

            if (m_cameraInfo != info) {
                m_cameraInfo = info;
            }
        }
    } else {
        m_cameraInfo = QCameraInfo();
    }
}

MVideoOutput::FillMode MVideoOutput::fillMode() const
{
    return m_fillMode;
}

void MVideoOutput::setFillMode(FillMode mode)
{
    if (mode == m_fillMode)
        return;

    m_fillMode = mode;
    m_geometryDirty = true;
    update();

    emit fillModeChanged(mode);
}

void MVideoOutput::_q_updateNativeSize()
{
    if (!m_surface)
        return;

    QSize size = m_surface->surfaceFormat().sizeHint();

    if (m_nativeSize != size) {
        m_nativeSize = size;

        m_geometryDirty = true;

        setImplicitWidth(size.width());
        setImplicitHeight(size.height());

        emit sourceRectChanged();
    }
}

/* Based on fill mode and our size, figure out the source/dest rects */
void MVideoOutput::_q_updateGeometry()
{
    const QRectF rect(0, 0, width(), height());
    const QRectF absoluteRect(x(), y(), width(), height());

    if (!m_geometryDirty && m_lastRect == absoluteRect)
        return;

    QRectF oldContentRect(m_contentRect);

    m_geometryDirty = false;
    m_lastRect = absoluteRect;

    if (m_nativeSize.isEmpty()) {
        //this is necessary for item to receive the
        //first paint event and configure video surface.
        m_contentRect = rect;
    } else if (m_fillMode == Stretch) {
        m_contentRect = rect;
    } else if (m_fillMode == PreserveAspectFit || m_fillMode == PreserveAspectCrop) {
        QSizeF scaled = m_nativeSize;
        scaled.scale(rect.size(), m_fillMode == PreserveAspectFit ?
                         Qt::KeepAspectRatio : Qt::KeepAspectRatioByExpanding);

        m_contentRect = QRectF(QPointF(), scaled);
        m_contentRect.moveCenter(rect.center());
    }

//    if(m_surface){
//        m_surface->updateGeometry();
//    }

    if (m_contentRect != oldContentRect)
        emit contentRectChanged();
}

QRectF MVideoOutput::contentRect() const
{
    return m_contentRect;
}

QRectF MVideoOutput::sourceRect() const
{
    // We might have to transpose back
    QSizeF size = m_nativeSize;

    return QRectF(QPointF(), size);

//    // Take the viewport into account for the top left position.
//    // m_nativeSize is already adjusted to the viewport, as it originats
//    // from QVideoSurfaceFormat::sizeHint(), which includes pixel aspect
//    // ratio and viewport.
//    const QRectF viewport = m_backend->adjustedViewport();
//    Q_ASSERT(viewport.size() == size);
//    return QRectF(viewport.topLeft(), size);
}

QPointF MVideoOutput::mapNormalizedPointToItem(const QPointF &point) const
{
    qreal dx = point.x();
    qreal dy = point.y();

    dx *= m_contentRect.width();
    dy *= m_contentRect.height();

    return m_contentRect.topLeft() + QPointF(dx, dy);
}

QRectF MVideoOutput::mapNormalizedRectToItem(const QRectF &rectangle) const
{
    return QRectF(mapNormalizedPointToItem(rectangle.topLeft()),
                  mapNormalizedPointToItem(rectangle.bottomRight())).normalized();
}

QPointF MVideoOutput::mapPointToSource(const QPointF &point) const
{
    QPointF norm = mapPointToSourceNormalized(point);
    return QPointF(norm.x() * m_nativeSize.width(), norm.y() * m_nativeSize.height());
}

QRectF MVideoOutput::mapRectToSource(const QRectF &rectangle) const
{
    return QRectF(mapPointToSource(rectangle.topLeft()),
                  mapPointToSource(rectangle.bottomRight())).normalized();
}

QPointF MVideoOutput::mapPointToSourceNormalized(const QPointF &point) const
{
    if (m_contentRect.isEmpty())
        return QPointF();

    // Normalize the item source point
    qreal nx = (point.x() - m_contentRect.left()) / m_contentRect.width();
    qreal ny = (point.y() - m_contentRect.top()) / m_contentRect.height();

    const qreal one(1.0f);

    return QPointF(nx, ny);
}

QRectF MVideoOutput::mapRectToSourceNormalized(const QRectF &rectangle) const
{
    return QRectF(mapPointToSourceNormalized(rectangle.topLeft()),
                  mapPointToSourceNormalized(rectangle.bottomRight())).normalized();
}

MVideoOutput::SourceType MVideoOutput::sourceType() const
{
    return m_sourceType;
}

QPointF MVideoOutput::mapPointToItem(const QPointF &point) const
{
    if (m_nativeSize.isEmpty())
        return QPointF();

    return mapNormalizedPointToItem(QPointF(point.x() / m_nativeSize.width(), point.y() / m_nativeSize.height()));
}

QRectF MVideoOutput::mapRectToItem(const QRectF &rectangle) const
{
    return QRectF(mapPointToItem(rectangle.topLeft()),
                  mapPointToItem(rectangle.bottomRight())).normalized();
}

QQmlListProperty<QAbstractVideoFilter> MVideoOutput::filters()
{
    return QQmlListProperty<QAbstractVideoFilter>(this, 0, filter_append, filter_count, filter_at, filter_clear);
}

void MVideoOutput::filter_append(QQmlListProperty<QAbstractVideoFilter> *property, QAbstractVideoFilter *value)
{
    MVideoOutput *self = static_cast<MVideoOutput *>(property->object);
    self->m_filters.append(value);
    self->m_surface->appendFilter(value);
}

int MVideoOutput::filter_count(QQmlListProperty<QAbstractVideoFilter> *property)
{
    MVideoOutput *self = static_cast<MVideoOutput *>(property->object);
    return self->m_filters.count();
}

QAbstractVideoFilter *MVideoOutput::filter_at(QQmlListProperty<QAbstractVideoFilter> *property, int index)
{
    MVideoOutput *self = static_cast<MVideoOutput *>(property->object);
    return self->m_filters.at(index);
}

void MVideoOutput::filter_clear(QQmlListProperty<QAbstractVideoFilter> *property)
{
    MVideoOutput *self = static_cast<MVideoOutput *>(property->object);
    self->m_filters.clear();
    if (self->m_surface)
        self->m_surface->clearFilters();
}
