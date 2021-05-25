#include "QGeoTileLocalReply.h"
#include <QFile>
#include <QtCore/qmath.h>

QGeoTileLocalManager::QGeoTileLocalManager()
{
	_threadPool.setMaxThreadCount(8);
}

QGeoTileLocalManager::~QGeoTileLocalManager()
{

}

static QGeoTileLocalManager* g_ins = NULL;
QGeoTileLocalManager* QGeoTileLocalManager::instance()
{
	if (NULL == g_ins)
		g_ins = new QGeoTileLocalManager;
	return g_ins;
}

void QGeoTileLocalManager::unInstance(QGeoTileLocalManager *ins)
{
	delete ins;
	ins = NULL;
}

void QGeoTileLocalManager::start(QGeoTileLocalReply *reply)
{
	_threadPool.start(reply);
}

void QGeoTileLocalManager::wait(quint32 msec)
{
	_threadPool.waitForDone(msec);
}

QGeoTileLocalReply::QGeoTileLocalReply(UrlFactory::MapType type, int row, int column, int level, QString format)
{
	setAutoDelete(false);
	_path.clear();
    //_path = TILE_PATH + getType(type) + QString::number(level) + "/" + QString::number(row) + "/" + QString::number(column) + format;
#ifdef TMS_TILE
    _path = TILE_PATH  + QString::number(level) + "/" + QString::number(row) + "/" + QString::number(qPow(2,level)-column-1) + format;
#else
    _path = TILE_PATH  + QString::number(level) + "/" + QString::number(row) + "/" + QString::number(column) + format;
#endif

}


QGeoTileLocalReply::~QGeoTileLocalReply()
{
}

void QGeoTileLocalReply::run()
{
	QFile file(_path);
	if (!file.exists())
	{
		//setErrorString("file not found:" + _path);
		//emit error();
		return;
	}
	if (!file.open(QIODevice::ReadOnly))
	{
		setErrorString(file.errorString());
		emit error();
		return;
	}

	_img = file.readAll();

	emit finished();
}

QString QGeoTileLocalReply::errorString()
{
	return _errorStr;
}

void QGeoTileLocalReply::setErrorString(QString error)
{
	_errorStr = error;
}

QByteArray QGeoTileLocalReply::readAll()
{
	return _img;
}

QString QGeoTileLocalReply::getType(UrlFactory::MapType type)
{
	switch (type)
	{
	case UrlFactory::GoogleChinaHybrid:
		return "satellite/";
	case UrlFactory::GoogleChinaSatellite:
		return "satellite/";
	case UrlFactory::GoogleChinaMap:
		return "roadmap/";
	default:
		return "satellite/";
	}
}
