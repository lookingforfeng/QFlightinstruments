#include "GetJsbsim.h"


GetJsbsim::GetJsbsim(QObject *parent)
    : QObject(parent)
{
    net3 =new FGNetFDM3();
    net1 =new FGNetFDM1();
    net13 = new FGNetFDM1_3();

    net3 = &(net13->data3);
    net1 = &(net13->data1);
}

GetJsbsim::~GetJsbsim()
{
    delete net3;
    delete net1;
    delete net13;
    delete getUdp;
    delete sendUdp;
}

void GetJsbsim::initUDPSocket()
{

    getUdp = new QUdpSocket;
    getUdp->bind(QHostAddress::AnyIPv4, 6666, QUdpSocket::ShareAddress);
    if(getUdp->joinMulticastGroup(QHostAddress("224.2.2.2")))
    {
        getUdp->setSocketOption(QAbstractSocket::ReceiveBufferSizeSocketOption,1024*1024*8);
        connect(getUdp,SIGNAL(readyRead()),this,SLOT(readUDPPendingDatagrams()));
        qDebug()<<"rec";
    }

    sendUdp = new QUdpSocket;
    QHostAddress *remoteIp = new QHostAddress("127.0.0.1");
    sendUdp->bind(QHostAddress::AnyIPv4, 5555, QUdpSocket::ShareAddress);
    sendUdp->connectToHost(*remoteIp, 5550);
}

void GetJsbsim::sendUDP()
{
//    QString msg = "UDP test- in Berger King";
//    QByteArray bytes = msg.toUtf8();
//    socketUdp->connectToHost(*remoteIp, 1000);
//    socketUdp->write(bytes);
}

void GetJsbsim::readUDPPendingDatagrams()
{
    while (getUdp->hasPendingDatagrams())
    {
        QNetworkDatagram datagram = getUdp->receiveDatagram();
        if  (datagram.data().length()>=(sizeof(FGNetFDM1) + sizeof(FGNetFDM3)))
        {
            sendUdp->write((char*)(datagram.data().data()),(sizeof(FGNetFDM1) + sizeof(FGNetFDM3)));

            memcpy(net13, datagram.data().data(), sizeof(FGNetFDM1) + sizeof(FGNetFDM3));

            //进行大小端转换
            if (isLittleEndian) {
                htond(net1->longitude);
                htond(net1->latitude);
                htond(net1->altitude);
                htonf(net1->agl);
                htonf(net1->phi);
                htonf(net1->theta);
                htonf(net1->psi);
                htonf(net1->alpha);
                htonf(net1->beta);

                htonf(net1->phidot);
                htonf(net1->thetadot);
                htonf(net1->psidot);
                htonf(net1->vcas);
                htonf(net1->climb_rate);
                htonf(net1->v_north);
                htonf(net1->v_east);
                htonf(net1->v_down);
                htonf(net1->v_body_u);
                htonf(net1->v_body_v);
                htonf(net1->v_body_w);

                htonf(net1->A_X_pilot);
                htonf(net1->A_Y_pilot);
                htonf(net1->A_Z_pilot);

                htonf(net1->stall_warning);
                htonf(net1->slip_deg);

                net1->num_engines = htonl(net1->num_engines);
                for (int i = 0; i < net1->num_engines; ++i)
                {
                    net1->eng_state[i] = htonl(net1->eng_state[i]);
                    htonf(net1->rpm[i]);
                    htonf(net1->fuel_flow[i]);
                    htonf(net1->fuel_px[i]);
                    htonf(net1->egt[i]);
                    htonf(net1->cht[i]);
                    htonf(net1->mp_osi[i]);
                    htonf(net1->tit[i]);
                    htonf(net1->oil_temp[i]);
                    htonf(net1->oil_px[i]);
                }

                net1->num_tanks = htonl(net1->num_tanks);
                for (int i = 0; i < net1->num_tanks; ++i)
                {
                    htonf(net1->fuel_quantity[i]);
                }

                net1->version = htonl(net1->version);

                net3->num_wheels = htonl(net3->num_wheels);
                for (int i = 0; i < net3->num_wheels; ++i)
                {
                    net3->wow[i] = htonl(net3->wow[i]);
                    htonf(net3->gear_pos[i]);
                    htonf(net3->gear_steer[i]);
                    htonf(net3->gear_compression[i]);
                }

                net3->cur_time = htonl(net3->cur_time);
                net3->warp = htonl(net3->warp);
                htonf(net3->visibility);

                htonf(net3->elevator);
                htonf(net3->elevator_trim_tab);
                htonf(net3->left_flap);
                htonf(net3->right_flap);
                htonf(net3->left_aileron);
                htonf(net3->right_aileron);
                htonf(net3->rudder);
                htonf(net3->nose_wheel);
                htonf(net3->speedbrake);
                htonf(net3->spoilers);
            }
        }
        emit dataUpdated(*net13);

    }
}


void GetJsbsim::htond(double &x)
{
    if (isLittleEndian) {
        int    *Double_Overlay = nullptr;
        int     Holding_Buffer;

        Double_Overlay = (int *)&x;
        Holding_Buffer = Double_Overlay[0];

        Double_Overlay[0] = htonl(Double_Overlay[1]);
        Double_Overlay[1] = htonl(Holding_Buffer);
    }
    else {
        return;
    }
}

void GetJsbsim::htonf(float &x)
{
    if (isLittleEndian) {
        int    *Float_Overlay = nullptr;
        int     Holding_Buffer = 0;

        Float_Overlay = (int *)&x;
        Holding_Buffer = *Float_Overlay;

        *Float_Overlay = htonl(Holding_Buffer);
    }
    else {
        return;
    }
}
