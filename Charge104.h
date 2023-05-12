#ifndef CHARGE104_H
#define CHARGE104_H

#include <QWidget>
#include <QTime>
#include <QTimer>
#include <QtNetwork/QTcpServer>
#include <QtNetwork/QTcpSocket>
#include <QThread>
#include "iec104_class.h"
#include "iec104_types.h"
#include "logmsg.h"
#include "qiec104.h"
#include "unistd.h"

class Charge104 : public QWidget
{
    Q_OBJECT
    Q_PROPERTY(int open_server READ open_server)
    Q_PROPERTY(int close_server READ close_server)
    Q_PROPERTY(int tcp_connect READ tcp_connect)
    Q_PROPERTY(int tcp_disconnect READ tcp_disconnect)
    Q_PROPERTY(int get_connect_state READ get_connect_state)
public:
    explicit Charge104(QWidget *parent = nullptr);

    int open_server();
    int server_new_client();
    int close_server();
    int tcp_connect();
    int tcp_disconnect();
    int get_connect_state();
    int server_send_data();
    int server_recv_data();
    int client_send_data();
    int client_recv_data();
    void server_client_connect();
	void update_connect_state();

    static const unsigned int TESTFRACT = 0x43;
    static const unsigned int TESTFRCON = 0x83;
    static const unsigned int START = 0x68;

signals:

private:
    QTcpServer *tcp_server;
    QTcpSocket *tcp_client;
    QTcpSocket *connect_client;
    int connect_flag;
    QTimer *timer;
    QTimer *t1,*t2;
    int time_flag;
};

#endif // CHARGE104_H
