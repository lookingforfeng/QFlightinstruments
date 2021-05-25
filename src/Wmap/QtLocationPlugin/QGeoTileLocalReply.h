#pragma once
#include <qiodevice.h>
#include <qthreadpool.h>
#include <qrunnable.h>
#include "QGCMapUrlEngine.h"

#define TMS_TILE

class QGeoTileLocalReply;

//#define TILE_PATH "D:/situationRes/googlemaps/"
#define TILE_PATH "C:/Users/Administrator/Desktop/GGGIS/GGGIS/cache_tms/GoogleEarth/"
#define TILE_FORMAT ".jpg"

class QGeoTileLocalManager
{
public:
    QGeoTileLocalManager();
	~QGeoTileLocalManager();

	static QGeoTileLocalManager *instance();
	static void unInstance(QGeoTileLocalManager *ins);

	void start(QGeoTileLocalReply *reply);
	void wait(quint32 msec = -1);

private:
	QThreadPool _threadPool;
};

class QGeoTileLocalReply : public QObject, public QRunnable
{
	Q_OBJECT
public:
	QGeoTileLocalReply(UrlFactory::MapType type, int row, int column, int level, QString format = TILE_FORMAT);
	~QGeoTileLocalReply();

	void run() override;

	QByteArray readAll();
	QString errorString();
	void setErrorString(QString error);
signals:
	void error();
	void finished();
private:
	QString getType(UrlFactory::MapType type);

private:
	QString _path;
	QByteArray _img;
	QString _errorStr;
};
