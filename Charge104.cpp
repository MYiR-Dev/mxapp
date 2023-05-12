#include "Charge104.h"

Charge104::Charge104(QWidget *parent) : QWidget(parent)
{
    connect_flag=0;
    connect_client=new QTcpSocket();
    tcp_client=new QTcpSocket();
    tcp_server=new QTcpServer();

    timer=new QTimer();
    connect(timer,&QTimer::timeout,this,&Charge104::server_client_connect);


    t1=new QTimer();
    t2=new QTimer();
    connect(t1,&QTimer::timeout,this,&Charge104::client_recv_data);
    connect(t2,&QTimer::timeout,this,&Charge104::server_recv_data);
	
	tcp_client=new QTcpSocket();
	connect(tcp_client,&QTcpSocket::stateChanged,this,&Charge104::update_connect_state);
}

int Charge104::open_server()
{
    tcp_server=new QTcpServer();
    if(!tcp_server->listen(QHostAddress("127.0.0.1"),2404)){
        return 0;
    }
    else{
        connect(tcp_server,&QTcpServer::newConnection,this,&Charge104::server_new_client);
        return 1;
    }
}

int Charge104::server_new_client()
{
    if(connect_client->state()==QAbstractSocket::UnconnectedState){
		qDebug()<<"new connection";
        connect_client=new QTcpSocket();
        connect_client=tcp_server->nextPendingConnection();
    }
    return 1;
}

int Charge104::close_server()
{
    if(connect_client->state()==QTcpSocket::ConnectedState)
        connect_client->close();
    tcp_server->close();
    connect_flag=0;
    return 1;
}

int Charge104::tcp_connect()
{
	tcp_client->close();
    tcp_client->connectToHost("127.0.0.1",2404);
    return 1;
}

void Charge104::update_connect_state()
{
    if(tcp_client->state()==QTcpSocket::ConnectedState){
		qDebug()<<"connected";
        connect_flag=1;
		client_send_data();

        t1->start(1000);
        t2->start(1000);
        //connect(tcp_client,&QTcpSocket::readyRead,this,&Charge104::client_recv_data);
        //connect(connect_client,&QTcpSocket::readyRead,this,&Charge104::server_recv_data);
        timer->start(1000);
    }
    else if(tcp_client->state()==QTcpSocket::UnconnectedState){
		qDebug()<<"disconnected";
        connect_flag=0;
		timer->stop();
        t1->stop();
        t2->stop();
        //disconnect(tcp_client,&QTcpSocket::readyRead,this,&Charge104::client_recv_data);
        //disconnect(connect_client,&QTcpSocket::readyRead,this,&Charge104::server_recv_data);
    }
}

int Charge104::tcp_disconnect()
{
    connect_client->close();
    tcp_client->close();
    connect_flag=0;
    disconnect(tcp_client,&QTcpSocket::readyRead,this,&Charge104::client_recv_data);
    disconnect(connect_client,&QTcpSocket::readyRead,this,&Charge104::server_recv_data);
    return 1;
}

int Charge104::get_connect_state()
{
    return connect_flag;
}

int Charge104::client_send_data()
{
    iec_apdu apdu;
    apdu.start = START;
    apdu.length = 4;
    apdu.NS = TESTFRACT;
    apdu.NR = 0;
    tcp_client->write(reinterpret_cast<char*>(&apdu),6);
    return 1;
}

int Charge104::client_recv_data()
{
    unsigned char *br;
    iec_apdu apdu;
    br=reinterpret_cast<unsigned char*>(&apdu);
    tcp_client->read(reinterpret_cast<char*>(br),6);
    if(br[0]==START){
        if(br[2]==TESTFRCON){
            time_flag=5;
            client_send_data();
        }
    }
    return 1;
}

void Charge104::server_client_connect()
{
    time_flag--;
    if(time_flag==0){
        connect_flag=0;
		timer->stop();
        t1->stop();
        t2->stop();
    }
}

int Charge104::server_send_data()
{
    iec_apdu apdu;
    apdu.start = START;
    apdu.length = 4;
    apdu.NS = TESTFRCON;
    apdu.NR = 0;
    connect_client->write(reinterpret_cast<char*>(&apdu),6);
    return 1;
}

int Charge104::server_recv_data()
{
    unsigned char *br;
    iec_apdu apdu;
    br=reinterpret_cast<unsigned char*>(&apdu);
    connect_client->read(reinterpret_cast<char*>(br),6);
    if(br[0]==START){
        if(br[2]==TESTFRACT){
            server_send_data();
        }
    }
    return 1;
}
