#include "qmlplot.h"
#include "qcustomplot.h"
#include <QDebug>

CustomPlotItem::CustomPlotItem( QQuickItem* parent ) : QQuickPaintedItem( parent )
    , m_CustomPlot( nullptr ), m_timerId( 0 )
{
    setFlag( QQuickItem::ItemHasContents, true );
    setAcceptedMouseButtons( Qt::AllButtons );

    connect( this, &QQuickPaintedItem::widthChanged, this, &CustomPlotItem::updateCustomPlotSize );
    connect( this, &QQuickPaintedItem::heightChanged, this, &CustomPlotItem::updateCustomPlotSize );
}

CustomPlotItem::~CustomPlotItem()
{
    delete m_CustomPlot;
    m_CustomPlot = nullptr;

    if(m_timerId != 0) {
        killTimer(m_timerId);
    }
}

void CustomPlotItem::initCustomPlot()
{
#if 0 // original
    m_CustomPlot = new QCustomPlot();

    updateCustomPlotSize();
    m_CustomPlot->addGraph();
    m_CustomPlot->graph( 0 )->setPen( QPen( Qt::red ) );
    m_CustomPlot->xAxis->setLabel( "t" );
    m_CustomPlot->yAxis->setLabel( "S" );
    m_CustomPlot->xAxis->setRange( 0, 10 );
    m_CustomPlot->yAxis->setRange( 0, 5 );
    m_CustomPlot ->setInteractions( QCP::iRangeDrag | QCP::iRangeZoom );

    startTimer(500);

    connect( m_CustomPlot, &QCustomPlot::afterReplot, this, &CustomPlotItem::onCustomReplot );

    m_CustomPlot->replot();
#else
    m_CustomPlot = new QCustomPlot();

    updateCustomPlotSize();

    uchar *buffer;
    int fs = 360;
    QVector<double> t(650000), s1(650000), s2(650000);

    // The following plot setup is mostly taken from the plot demos:
    m_CustomPlot->addGraph();
    m_CustomPlot->graph()->setPen(QPen(Qt::blue));
    m_CustomPlot->addGraph();

    QFile aFile(":/ecg/100.dat");  //以文件方式读出
    if (!(aFile.open(QIODevice::ReadOnly)))
    {
//        qDebug() << "cannot open file "<< endl;
        return;
    }

    QByteArray s = aFile.readAll();
//    qDebug() << "size:" << s.size() << endl;

    buffer =(uchar*)(s.data());
    for (int i = 0; i < 650000; ++i)
    {
        s1[i] = 0.0;
        s2[i] = 0.0;
        t[i] = i/(1.0*fs);
    }

   int k = 0;
   for(int i = 0; i <650000; i++ )
   {
       //212->12bits.

       s1[i] = (buffer[k+1] & 15) * pow(2,8) + buffer[k];
       s2[i] = (buffer[k+1] & 240) * pow(2,4) + buffer[k+2] ;
       k = k + 3;

       //Signed.
       if ( s1[i] >= 2048 )
         s1[i] = ( 4096 - s1[i] ) * ( -1 );

       if ( s2[i] >= 2048 )
           s2[i] = ( 4096 - s2[i] ) * ( -1 );
    }
//    qDebug()<< "Signal 1 first Point Value :\t " << s1[0] << std::endl;
//    qDebug()<< "Signal 2 first Point Value :\t " << s2[0] << std::endl;

    //add offset to the second signal to visually seperate both signals
    for (int i = 0; i< 650000; i++)
    {
        s2[i] -= 500;
    }

    //plot data from .dat file
    m_CustomPlot->graph(0)->setData(t,s1);
    m_CustomPlot->graph(1)->setData(t, s2);

    m_CustomPlot->axisRect()->setupFullAxesBox(true);
    m_CustomPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    m_CustomPlot->xAxis->setLabel("Time (s)");
    m_CustomPlot->yAxis->setLabel("Amplitude");

    //insert plot title
    QCPPlotTitle *title = new QCPPlotTitle(m_CustomPlot);
    title->setText("Patient 100.dat ECG Record");
    m_CustomPlot->plotLayout()->insertRow(0); // insert an empty row above the axis rect
    m_CustomPlot->plotLayout()->addElement(0, 0, title); // place the title in the empty cell we've just created
    m_CustomPlot->xAxis->setRange(0, 5, Qt::AlignLeading); // display range is 5 seconds
    m_CustomPlot->yAxis->setRange(300, 1000, Qt::AlignLeading);


//    m_CustomPlot->addGraph();
//    m_CustomPlot->graph( 0 )->setPen( QPen( Qt::red ) );
//    m_CustomPlot->xAxis->setLabel( "t" );
//    m_CustomPlot->yAxis->setLabel( "S" );
//    m_CustomPlot->xAxis->setRange( 0, 10 );
//    m_CustomPlot->yAxis->setRange( 0, 5 );
    m_CustomPlot ->setInteractions( QCP::iRangeDrag | QCP::iRangeZoom );

//    startTimer(500);

    connect( m_CustomPlot, &QCustomPlot::afterReplot, this, &CustomPlotItem::onCustomReplot );

    m_CustomPlot->replot();
#endif
}


void CustomPlotItem::paint( QPainter* painter )
{
    if (m_CustomPlot)
    {
        QPixmap    picture( boundingRect().size().toSize() );
        QCPPainter qcpPainter( &picture );

        m_CustomPlot->toPainter( &qcpPainter );

        painter->drawPixmap( QPoint(), picture );
    }
}

void CustomPlotItem::mousePressEvent( QMouseEvent* event )
{
    qDebug() << Q_FUNC_INFO;
    routeMouseEvents( event );
}

void CustomPlotItem::mouseReleaseEvent( QMouseEvent* event )
{
    qDebug() << Q_FUNC_INFO;
    routeMouseEvents( event );
}

void CustomPlotItem::mouseMoveEvent( QMouseEvent* event )
{
    routeMouseEvents( event );
}

void CustomPlotItem::mouseDoubleClickEvent( QMouseEvent* event )
{
    qDebug() << Q_FUNC_INFO;
    routeMouseEvents( event );
}

void CustomPlotItem::wheelEvent( QWheelEvent *event )
{
    routeWheelEvents( event );
}

void CustomPlotItem::timerEvent(QTimerEvent *event)
{
    static double t, U;
    U = ((double)rand() / RAND_MAX) * 5;
    m_CustomPlot->graph(0)->addData(t, U);
    qDebug() << Q_FUNC_INFO << QString("Adding dot t = %1, S = %2").arg(t).arg(U);
    t++;
    m_CustomPlot->replot();
}

void CustomPlotItem::graphClicked( QCPAbstractPlottable* plottable )
{
    qDebug() << Q_FUNC_INFO << QString( "Clicked on graph '%1 " ).arg( plottable->name() );
}

void CustomPlotItem::routeMouseEvents( QMouseEvent* event )
{
    if (m_CustomPlot)
    {
        QMouseEvent* newEvent = new QMouseEvent( event->type(), event->localPos(), event->button(), event->buttons(), event->modifiers() );
        QCoreApplication::postEvent( m_CustomPlot, newEvent );
    }
}

void CustomPlotItem::routeWheelEvents( QWheelEvent* event )
{
    if (m_CustomPlot)
    {
        QWheelEvent* newEvent = new QWheelEvent( event->pos(), event->delta(), event->buttons(), event->modifiers(), event->orientation() );
        QCoreApplication::postEvent( m_CustomPlot, newEvent );
    }
}

void CustomPlotItem::updateCustomPlotSize()
{
    if (m_CustomPlot)
    {
        m_CustomPlot->setGeometry(0, 0, (int)width(), (int)height());
        m_CustomPlot->setViewport(QRect(0, 0, (int)width(), (int)height()));
    }
}

void CustomPlotItem::onCustomReplot()
{
    qDebug() << Q_FUNC_INFO;
    update();
}
