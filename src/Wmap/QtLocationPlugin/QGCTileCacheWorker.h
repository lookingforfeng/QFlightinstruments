/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 * @file
 *   @brief Map Tile Cache Worker Thread
 *
 *   @author Gus Grubba <mavlink@grubba.com>
 *
 */

#ifndef QGC_TILE_CACHE_WORKER_H
#define QGC_TILE_CACHE_WORKER_H

#include <QString>
#include <QThread>
#include <QQueue>
#include <QMutex>
#include <QWaitCondition>
#include <QMutexLocker>
#include <QtSql/QSqlDatabase>
#include <QHostInfo>
#include <qthreadpool.h>
#include <qrunnable.h>
#include <qhash.h>

//#include "QGCLoggingCategory.h"

//Q_DECLARE_LOGGING_CATEGORY(QGCTileCacheLog)

class QGCMapTask;
class QGCCachedTileSet;
class QGCCacheTile;
//
//class QGCReadTileWorker : public QRunnable
//{
//public:
//	QGCReadTileWorker(QSqlDatabase *db,  QGCMapTask *task);
//	~QGCReadTileWorker();
//
//	void run();
//
//private:
//	QSqlDatabase *_db;
//	QGCMapTask *_task;
//};

//-----------------------------------------------------------------------------
class QGCCacheWorker : public QThread
{
    Q_OBJECT
public:
    QGCCacheWorker  ();
    ~QGCCacheWorker ();

    void    quit            ();
    bool    enqueueTask     (QGCMapTask* task);
    void    setDatabaseFile (const QString& path);
	// M
	void	setMaxMemoryUse (quint32 memory);

protected:
    void    run             ();

private slots:
    void        _lookupReady            (QHostInfo info);

private:
    void        _saveTile               (QGCMapTask* mtask);
    void        _getTile                (QGCMapTask* mtask);
    void        _getTileSets            (QGCMapTask* mtask);
    void        _createTileSet          (QGCMapTask* mtask);
    void        _getTileDownloadList    (QGCMapTask* mtask);
    void        _updateTileDownloadState(QGCMapTask* mtask);
    void        _deleteTileSet          (QGCMapTask* mtask);
    void        _renameTileSet          (QGCMapTask* mtask);
    void        _resetCacheDatabase     (QGCMapTask* mtask);
    void        _pruneCache             (QGCMapTask* mtask);
    void        _exportSets             (QGCMapTask* mtask);
    void        _importSets             (QGCMapTask* mtask);
    bool        _testTask               (QGCMapTask* mtask);
    void        _testInternet           ();

    quint64     _findTile               (const QString hash);
    bool        _findTileSetID          (const QString name, quint64& setID);
    void        _updateSetTotals        (QGCCachedTileSet* set);
    bool        _init                   ();
    bool        _createDB               (QSqlDatabase *db, bool createDefault = true);
    quint64     _getDefaultTileSet      ();
    void        _updateTotals           ();
    void        _deleteTileSet          (qulonglong id);

signals:
    void        updateTotals            (quint32 totaltiles, quint64 totalsize, quint32 defaulttiles, quint64 defaultsize);
    void        internetStatus          (bool active);

private:
    QQueue<QGCMapTask*>     _taskQueue;
    QMutex                  _mutex;
    QMutex                  _waitmutex;
    QWaitCondition          _waitc;
    QString                 _databasePath;
    QSqlDatabase*           _db;
    bool                    _valid;
    bool                    _failed;
    quint64                 _defaultSet;
    quint64                 _totalSize;
    quint32                 _totalCount;
    quint64                 _defaultSize;
    quint32                 _defaultCount;
    time_t                  _lastUpdate;
    int                     _updateTimeout;
    int                     _hostLookupID;
	quint64					_memory;
	quint64					_memoryUsed;
	QHash<QString, QGCCacheTile *> _tileMap;
	QList<QString>			_tileList;

	//QThreadPool				_tileReader;
};

#endif // QGC_TILE_CACHE_WORKER_H
