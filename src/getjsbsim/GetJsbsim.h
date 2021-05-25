#pragma once

#include <QObject>
#include <QUdpSocket>
#include <QNetworkDatagram>

#include "winsock.h"
#include "net_fdm.hxx"

#pragma comment(lib,"ws2_32.lib")

static const int endianTest = 1;
#define isLittleEndian (*((char *) &endianTest ) != 0)

class GetJsbsim : public QObject
{
	Q_OBJECT

public:
	GetJsbsim(QObject *parent = nullptr);
	~GetJsbsim();
	void initUDPSocket();
	void sendUDP();

signals:
    void dataUpdated(FGNetFDM1_3 net13);

	private slots:
	void readUDPPendingDatagrams();

private:
	QUdpSocket* socketUdp;
	void htond(double &x);
	void htonf(float &x);

    FGNetFDM3 *net3 ;
    FGNetFDM1 *net1 ;
    FGNetFDM1_3 *net13;

};
