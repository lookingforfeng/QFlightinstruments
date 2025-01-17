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
 *   @brief Map Tile Set
 *
 *   @author Gus Grubba <mavlink@grubba.com>
 *
 */

#ifndef QGC_MAP_TILE_SET_H
#define QGC_MAP_TILE_SET_H

#include <QObject>
#include <QString>
#include <QHash>
#include <QDateTime>
#include <QImage>

//#include "QGCLoggingCategory.h"
#include "QGCMapEngineData.h"
#include "QGCMapUrlEngine.h"

//Q_DECLARE_LOGGING_CATEGORY(QGCCachedTileSetLog)

class QGCTile;
class QGCMapEngineManager;

//-----------------------------------------------------------------------------
class QGCCachedTileSet : public QObject
{
    Q_OBJECT
public:
    QGCCachedTileSet    (const QString& name);
    ~QGCCachedTileSet   ();

    Q_PROPERTY(QString      name                READ    name                NOTIFY nameChanged)
    Q_PROPERTY(QString      mapTypeStr          READ    mapTypeStr          CONSTANT)
    Q_PROPERTY(double       topleftLon          READ    topleftLon          CONSTANT)
    Q_PROPERTY(double       topleftLat          READ    topleftLat          CONSTANT)
    Q_PROPERTY(double       bottomRightLon      READ    bottomRightLon      CONSTANT)
    Q_PROPERTY(double       bottomRightLat      READ    bottomRightLat      CONSTANT)
    Q_PROPERTY(int          minZoom             READ    minZoom             CONSTANT)
    Q_PROPERTY(int          maxZoom             READ    maxZoom             CONSTANT)
    Q_PROPERTY(quint32      totalTileCount      READ    totalTileCount      NOTIFY totalTileCountChanged)
    Q_PROPERTY(QString      totalTileCountStr   READ    totalTileCountStr   NOTIFY totalTileCountChanged)
    Q_PROPERTY(quint64      totalTilesSize      READ    totalTilesSize      NOTIFY totalTilesSizeChanged)
    Q_PROPERTY(QString      totalTilesSizeStr   READ    totalTilesSizeStr   NOTIFY totalTilesSizeChanged)
    Q_PROPERTY(quint32      uniqueTileCount     READ    uniqueTileCount     NOTIFY uniqueTileCountChanged)
    Q_PROPERTY(QString      uniqueTileCountStr  READ    uniqueTileCountStr  NOTIFY uniqueTileCountChanged)
    Q_PROPERTY(quint64      uniqueTileSize      READ    uniqueTileSize      NOTIFY uniqueTileSizeChanged)
    Q_PROPERTY(QString      uniqueTileSizeStr   READ    uniqueTileSizeStr   NOTIFY uniqueTileSizeChanged)
    Q_PROPERTY(quint32      savedTileCount      READ    savedTileCount      NOTIFY savedTileCountChanged)
    Q_PROPERTY(QString      savedTileCountStr   READ    savedTileCountStr   NOTIFY savedTileCountChanged)
    Q_PROPERTY(quint64      savedTileSize       READ    savedTileSize       NOTIFY savedTileSizeChanged)
    Q_PROPERTY(QString      savedTileSizeStr    READ    savedTileSizeStr    NOTIFY savedTileSizeChanged)
    Q_PROPERTY(QString      downloadStatus      READ    downloadStatus      NOTIFY savedTileSizeChanged)
    Q_PROPERTY(QDateTime    creationDate        READ    creationDate        CONSTANT)
    Q_PROPERTY(bool         complete            READ    complete            NOTIFY completeChanged)
    Q_PROPERTY(bool         defaultSet          READ    defaultSet          CONSTANT)
    Q_PROPERTY(quint64      setID               READ    setID               CONSTANT)
    Q_PROPERTY(bool         deleting            READ    deleting            NOTIFY deletingChanged)
    Q_PROPERTY(bool         downloading         READ    downloading         NOTIFY downloadingChanged)
    Q_PROPERTY(quint32      errorCount          READ    errorCount          NOTIFY errorCountChanged)
    Q_PROPERTY(QString      errorCountStr       READ    errorCountStr       NOTIFY errorCountChanged)

    Q_PROPERTY(bool         selected            READ    selected            WRITE  setSelected  NOTIFY selectedChanged)

    Q_INVOKABLE void createDownloadTask ();
    Q_INVOKABLE void resumeDownloadTask ();
    Q_INVOKABLE void cancelDownloadTask ();

    void        setManager              (QGCMapEngineManager* mgr);

    QString     name                    () { return _name; }
    QString     mapTypeStr              () { return _mapTypeStr; }
    double      topleftLat              () { return _topleftLat; }
    double      topleftLon              () { return _topleftLon; }
    double      bottomRightLat          () { return _bottomRightLat; }
    double      bottomRightLon          () { return _bottomRightLon; }
    quint32     totalTileCount          () { return (quint32)_totalTileCount; }
    QString     totalTileCountStr       ();
    quint64     totalTilesSize          () { return (quint64)_totalTileSize; }
    QString     totalTilesSizeStr       ();
    quint32     uniqueTileCount         () { return _uniqueTileCount; }
    QString     uniqueTileCountStr      ();
    quint64     uniqueTileSize          () { return _uniqueTileSize; }
    QString     uniqueTileSizeStr       ();
    quint32     savedTileCount          () { return (quint32)_savedTileCount; }
    QString     savedTileCountStr       ();
    quint64     savedTileSize           () { return (quint64)_savedTileSize; }
    QString     savedTileSizeStr        ();
    QString     downloadStatus          ();
    int         minZoom                 () { return _minZoom; }
    int         maxZoom                 () { return _maxZoom; }
    QDateTime   creationDate            () { return _creationDate; }
    quint64     id                      () { return _id; }
    UrlFactory::MapType type            () { return _type; }
    bool        complete                () { return _defaultSet || (_totalTileCount <= _savedTileCount); }
    bool        defaultSet              () { return _defaultSet; }
    quint64     setID                   () { return _id; }
    bool        deleting                () { return _deleting; }
    bool        downloading             () { return _downloading; }
    quint32     errorCount              () { return _errorCount; }
    QString     errorCountStr           ();
    bool        selected                () { return _selected; }

    void        setSelected             (bool sel);
    void        setName                 (QString name)              { _name = name; }
    void        setMapTypeStr           (QString typeStr)           { _mapTypeStr = typeStr; }
    void        setTopleftLat           (double lat)                { _topleftLat = lat; }
    void        setTopleftLon           (double lon)                { _topleftLon = lon; }
    void        setBottomRightLat       (double lat)                { _bottomRightLat = lat; }
    void        setBottomRightLon       (double lon)                { _bottomRightLon = lon; }
    void        setTotalTileCount       (quint32 num)               { _totalTileCount = num; emit totalTileCountChanged(); }
    void        setUniqueTileCount      (quint32 num)               { _uniqueTileCount = num; }
    void        setUniqueTileSize       (quint64 size)              { _uniqueTileSize  = size; }
    void        setTotalTileSize        (quint64 size)              { _totalTileSize  = size; emit totalTilesSizeChanged(); }
    void        setSavedTileCount       (quint32 num)               { _savedTileCount = num; emit savedTileCountChanged(); }
    void        setSavedTileSize        (quint64 size)              { _savedTileSize  = size; emit savedTileSizeChanged();  }
    void        setMinZoom              (int zoom)                  { _minZoom = zoom; }
    void        setMaxZoom              (int zoom)                  { _maxZoom = zoom; }
    void        setCreationDate         (QDateTime date)            { _creationDate = date; }
    void        setId                   (quint64 id)                { _id = id; }
    void        setType                 (UrlFactory::MapType type)  { _type = type; }
    void        setDefaultSet           (bool def)                  { _defaultSet = def; }
    void        setDeleting             (bool del)                  { _deleting = del; emit deletingChanged(); }
    void        setDownloading          (bool down)                 { _downloading = down; }

signals:
    void        deletingChanged         ();
    void        downloadingChanged      ();
    void        totalTileCountChanged   ();
    void        uniqueTileCountChanged  ();
    void        uniqueTileSizeChanged   ();
    void        totalTilesSizeChanged   ();
    void        savedTileCountChanged   ();
    void        savedTileSizeChanged    ();
    void        completeChanged         ();
    void        errorCountChanged       ();
    void        selectedChanged         ();
    void        nameChanged             ();

private slots:
    void _tileListFetched               (QList<QGCTile*> tiles);
    void _networkReplyFinished          ();
    void _networkReplyError             (QNetworkReply::NetworkError error);

private:
    void        _prepareDownload        ();
    void        _doneWithDownload       ();

private:
    QString     _name;
    QString     _mapTypeStr;
    double      _topleftLat;
    double      _topleftLon;
    double      _bottomRightLat;
    double      _bottomRightLon;
    quint32     _totalTileCount;
    quint64     _totalTileSize;
    quint32     _uniqueTileCount;
    quint64     _uniqueTileSize;
    quint32     _savedTileCount;
    quint64     _savedTileSize;
    int         _minZoom;
    int         _maxZoom;
    bool        _defaultSet;
    bool        _deleting;
    bool        _downloading;
    QDateTime   _creationDate;
    quint64     _id;
    UrlFactory::MapType _type;
    QNetworkAccessManager*  _networkManager;
    QHash<QString, QNetworkReply*> _replies;
    quint32     _errorCount;
    //-- Tile download
    QList<QGCTile *> _tilesToDownload;
    bool        _noMoreTiles;
    bool        _batchRequested;
    QGCMapEngineManager* _manager;
    bool        _selected;
};

#endif // QGC_MAP_TILE_SET_H

