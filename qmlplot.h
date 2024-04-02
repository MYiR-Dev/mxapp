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

#ifndef QMLPLOT_H
#define QMLPLOT_H

#include <QtQuick>
class QCustomPlot;
class QCPAbstractPlottable;
#define DATA_COUNT 5000
class CustomPlotItem : public QQuickPaintedItem
{
    Q_OBJECT

public:
    CustomPlotItem( QQuickItem* parent = 0 );
    virtual ~CustomPlotItem();

    void paint( QPainter* painter );

    Q_INVOKABLE void initCustomPlot();

    void getECGData();
    void getRESPData();
    QVector<double> ecg_time;
    QVector<double> ecg_data1;
    QVector<double> ecg_data2;
    QVector<double> pleth_data;
    QVector<double> resp_data;
    QVector<double> ecg_data1_backup;
    QVector<double> ecg_data2_backup;
    QVector<double> pleth_data_backup;
    QVector<double> resp_data_backup;
    int timer_count;
protected:
//    void routeMouseEvents( QMouseEvent* event );
//    void routeWheelEvents( QWheelEvent* event );

//    virtual void mousePressEvent( QMouseEvent* event );
//    virtual void mouseReleaseEvent( QMouseEvent* event );
//    virtual void mouseMoveEvent( QMouseEvent* event );
//    virtual void mouseDoubleClickEvent( QMouseEvent* event );
//    virtual void wheelEvent( QWheelEvent *event );

    virtual void timerEvent(QTimerEvent *event);

private:
    QCustomPlot*         m_CustomPlot;
    int                  m_timerId;

private slots:
    void graphClicked( QCPAbstractPlottable* plottable );
    void onCustomReplot();
    void updateCustomPlotSize();

};

#endif // QMLPLOT_H
