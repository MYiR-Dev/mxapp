#ifndef MVIDEOOUTPUT_H
#define MVIDEOOUTPUT_H

#include <QObject>
#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QColor>
#include <QtCore/qrect.h>
#include <QtCore/qsharedpointer.h>
#include <QtQuick/qquickitem.h>
#include <QtCore/qpointer.h>
#include <QtMultimedia/qcamerainfo.h>
#include <QtMultimedia/qabstractvideofilter.h>
#include <QMutex>

#include "videowidgetsurface.h"

class QMediaObject;
class QMediaService;
class QVideoRendererControl;
class QAbstractVideoFilter;
class QVideoFilterRunnable;

class MVideoOutput : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QObject* source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(FillMode fillMode READ fillMode WRITE setFillMode NOTIFY fillModeChanged)
    Q_PROPERTY(QRectF sourceRect READ sourceRect NOTIFY sourceRectChanged)
    Q_PROPERTY(QRectF contentRect READ contentRect NOTIFY contentRectChanged)
    Q_PROPERTY(QQmlListProperty<QAbstractVideoFilter> filters READ filters);
    Q_ENUMS(FillMode)

public:
    enum FillMode
    {
        Stretch            = Qt::IgnoreAspectRatio,
        PreserveAspectFit  = Qt::KeepAspectRatio,
        PreserveAspectCrop = Qt::KeepAspectRatioByExpanding
    };

    MVideoOutput(QQuickItem *parent = 0);
    ~MVideoOutput();

    QObject *source() const { return m_source.data(); }
    void setSource(QObject *source);
    void releaseSource();

    void releaseControl();

    FillMode fillMode() const;
    void setFillMode(FillMode mode);

    QRectF sourceRect() const;
    QRectF contentRect() const;

    Q_INVOKABLE QPointF mapPointToItem(const QPointF &point) const;
    Q_INVOKABLE QRectF mapRectToItem(const QRectF &rectangle) const;
    Q_INVOKABLE QPointF mapNormalizedPointToItem(const QPointF &point) const;
    Q_INVOKABLE QRectF mapNormalizedRectToItem(const QRectF &rectangle) const;
    Q_INVOKABLE QPointF mapPointToSource(const QPointF &point) const;
    Q_INVOKABLE QRectF mapRectToSource(const QRectF &rectangle) const;
    Q_INVOKABLE QPointF mapPointToSourceNormalized(const QPointF &point) const;
    Q_INVOKABLE QRectF mapRectToSourceNormalized(const QRectF &rectangle) const;

    enum SourceType {
        NoSource,
        MediaObjectSource,
        VideoSurfaceSource
    };
    SourceType sourceType() const;

    QQmlListProperty<QAbstractVideoFilter> filters();

    QAbstractVideoSurface *videoSurface(){ return m_surface; }
    void paint(QPainter *painter) override;
protected:
    void appendFilter(QAbstractVideoFilter *filter);
    void clearFilters();
signals:
    void sourceChanged();
    void fillModeChanged(MVideoOutput::FillMode);
    void sourceRectChanged();
    void contentRectChanged();

public slots:
    bool _q_init(QMediaService *service);
    void _q_updateMediaObject();
    void _q_updateCameraInfo();
    void _q_updateNativeSize();
    void _q_updateGeometry();
//    void _q_invalidateSceneGraph();

private:
    static void filter_append(QQmlListProperty<QAbstractVideoFilter> *property, QAbstractVideoFilter *value);
    static int filter_count(QQmlListProperty<QAbstractVideoFilter> *property);
    static QAbstractVideoFilter *filter_at(QQmlListProperty<QAbstractVideoFilter> *property, int index);
    static void filter_clear(QQmlListProperty<QAbstractVideoFilter> *property);

    SourceType m_sourceType;

    QPointer<QObject> m_source;
    QPointer<QMediaObject> m_mediaObject;
    QPointer<QMediaService> m_service;
    QCameraInfo m_cameraInfo;

    FillMode m_fillMode;
    QSize m_nativeSize;

    bool m_geometryDirty;
    QRectF m_lastRect;      // Cache of last rect to avoid recalculating geometry
    QRectF m_contentRect;   // Destination pixel coordinates, unclipped

    QList<QAbstractVideoFilter *> m_filters;
    QPointer<QVideoRendererControl> m_rendererControl;
    VideoWidgetSurface *m_surface;
};

#endif // MVIDEOOUTPUT_H
