#include "qmlplot.h"
#include "qcustomplot.h"
#include <QDebug>
#define DATA1_GAIN 400
#define DATA2_GAIN 350
#define DATA3_GAIN 400
#define DATA4_GAIN 200
CustomPlotItem::CustomPlotItem( QQuickItem* parent ) : QQuickPaintedItem( parent )
                                                     , m_CustomPlot( nullptr ), m_timerId( 0 )
{
    setFlag( QQuickItem::ItemHasContents, true );
    setAcceptedMouseButtons( Qt::AllButtons );

//    QPalette backGround;
//    backGround.setColor(QPalette::Background, QColor(0,0,0,255));

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
    m_CustomPlot = new QCustomPlot();

    updateCustomPlotSize();

    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();
    m_CustomPlot->addGraph();

    m_CustomPlot->graph(0)->setPen(QPen(Qt::green));
    m_CustomPlot->graph(1)->setPen(QPen(Qt::green));
    m_CustomPlot->graph(2)->setPen(QPen(Qt::red));
    m_CustomPlot->graph(3)->setPen(QPen(Qt::red));
    m_CustomPlot->graph(4)->setPen(QPen(Qt::green));
    m_CustomPlot->graph(5)->setPen(QPen(Qt::green));
    m_CustomPlot->graph(6)->setPen(QPen(Qt::red));
    m_CustomPlot->graph(7)->setPen(QPen(Qt::red));

    m_CustomPlot->xAxis->setLabel( "t" );
    m_CustomPlot->yAxis->setLabel( "S" );
    m_CustomPlot->xAxis->setRange(0, 5, Qt::AlignLeading);
    m_CustomPlot->yAxis->setRange(0, 1200, Qt::AlignLeading);
    m_CustomPlot->setInteractions( QCP::iRangeDrag | QCP::iRangeZoom );
    m_CustomPlot->yAxis->setVisible(false);
    m_CustomPlot->xAxis->setVisible(false);
//    m_CustomPlot->setBackground(Qt :: transparent);

    getECGData();
    getRESPData();
    timer_count = 0;
    startTimer(20);

    connect( m_CustomPlot, &QCustomPlot::afterReplot, this, &CustomPlotItem::onCustomReplot );

    m_CustomPlot->replot();
}
void CustomPlotItem::timerEvent(QTimerEvent *event)
{
    int i = 0;
    if (ecg_time[timer_count] > 5)
    {

        timer_count = 0;;

        m_CustomPlot->graph(0)->data()->clear();
        m_CustomPlot->graph(4)->setData(ecg_time,ecg_data1_backup);

        m_CustomPlot->graph(1)->data()->clear();
        m_CustomPlot->graph(5)->setData(ecg_time,ecg_data2_backup);

        m_CustomPlot->graph(2)->data()->clear();
        m_CustomPlot->graph(6)->setData(ecg_time,pleth_data_backup);

        m_CustomPlot->graph(3)->data()->clear();
        m_CustomPlot->graph(7)->setData(ecg_time,resp_data_backup);

    }

    m_CustomPlot->graph(4)->data()->removeBefore(ecg_time[timer_count+50]);
    m_CustomPlot->graph(5)->data()->removeBefore(ecg_time[timer_count+50]);
    m_CustomPlot->graph(6)->data()->removeBefore(ecg_time[timer_count+50]);
    m_CustomPlot->graph(7)->data()->removeBefore(ecg_time[timer_count+50]);

    m_CustomPlot->graph(0)->addData(ecg_time[timer_count],ecg_data1[timer_count]);
    m_CustomPlot->graph(1)->addData(ecg_time[timer_count],ecg_data2[timer_count]);
    m_CustomPlot->graph(2)->addData(ecg_time[timer_count],pleth_data[timer_count+30]);
    m_CustomPlot->graph(3)->addData(ecg_time[timer_count],resp_data[timer_count+30]);

    m_CustomPlot->replot();

    timer_count++;
}
void CustomPlotItem::getRESPData()
{
    int i = 0;
    QFile file("/usr/share/myir/resp.text");

    if (file.open(QFile::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        QString strLine;
        QStringList list;

        for( i = 0; i < DATA_COUNT; i++)
        {
            if(!in.atEnd())
            {
                strLine = in.readLine();
                strLine.remove("\r\n");
                list = strLine.split("\t");

                pleth_data.append(list[3].trimmed().toDouble()/10+DATA3_GAIN);
                pleth_data_backup.append(list[3].trimmed().toDouble()/10+DATA3_GAIN);
                resp_data.append(list[4].trimmed().toDouble()/8+DATA4_GAIN);
                resp_data_backup.append(list[4].trimmed().toDouble()/8+DATA4_GAIN);
            }
        }
    }
    else
    {
        qDebug() << "cannot open file resp.text!";
    }

}
void CustomPlotItem::getECGData()
{
    FILE *pFile;
    uchar *buffer;
    long lSize;
    size_t result;
    int fs = 360;

    QVector<double> t(DATA_COUNT), s1(DATA_COUNT), s2(DATA_COUNT);

    pFile = fopen("/usr/share/myir/ecg.dat","rb");
    if (pFile == NULL)

    {
        qDebug() << "cannot open file ecg.dat";
    }

    for (int i = 0; i < DATA_COUNT; ++i)
    {
        s1[i] = 0.0;
        s2[i] = 0.0;
        t[i] = i/(1.0*fs);
    }
    fseek (pFile , 0 , SEEK_END);
    lSize = ftell (pFile);
    rewind (pFile);

    buffer = (uchar*) malloc (sizeof(uchar)*lSize);
    if (buffer == NULL) {fputs ("Memory error",stderr); exit (2);}

    result = fread (buffer, 1, lSize, pFile);
    if ((long)result != lSize) {fputs ("Reading error",stderr); exit (3);}

    fclose(pFile);


    int k = 0;
    for(int i = 0; i <DATA_COUNT; i++ )
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

//    qDebug() <<  "Signal 1 first Point Value :\t " << s1[0] ;
//    qDebug() <<  "Signal 2 first Point Value :\t " << s2[0] ;


    for (int i = 0; i< DATA_COUNT; i++)
    {
        s1[i] += DATA1_GAIN;
        s2[i] -= DATA2_GAIN;

        ecg_data1.append(s1[i]/1.5);
        ecg_data1_backup.append(s1[i]/1.5);
        ecg_data2.append(s2[i]);
        ecg_data2_backup.append(s2[i]);
        ecg_time.append(t[i]);
    }

    free(buffer);
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

void CustomPlotItem::graphClicked( QCPAbstractPlottable* plottable )
{
    qDebug() << Q_FUNC_INFO << QString( "Clicked on graph '%1 " ).arg( plottable->name() );
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
    //qDebug() << Q_FUNC_INFO;
    update();
}
