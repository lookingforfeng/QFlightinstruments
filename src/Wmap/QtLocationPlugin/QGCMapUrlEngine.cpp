﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/**
 *  @file
 *  @author Gus Grubba <mavlink@grubba.com>
 *  Original work: The OpenPilot Team, http://www.openpilot.org Copyright (C) 2012.
 */

//#define DEBUG_GOOGLE_MAPS

//#include "QGCApplication.h"
#include "QGCMapEngine.h"
//#include "AppSettings.h"
//#include "SettingsManager.h"

#include <QRegExp>
#include <QNetworkReply>
#include <QEventLoop>
#include <QTimer>
#include <QString>
#include <QByteArray>

#if defined(DEBUG_GOOGLE_MAPS)
#include <QFile>
#include <QStandardPaths>
#endif

static const unsigned char pngSignature[]   = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00};
static const unsigned char jpegSignature[]  = {0xFF, 0xD8, 0xFF, 0x00};
static const unsigned char gifSignature[]   = {0x47, 0x49, 0x46, 0x38, 0x00};

//-----------------------------------------------------------------------------
UrlFactory::UrlFactory()
    : _timeout(5 * 1000)
    #ifndef QGC_NO_GOOGLE_MAPS
    , _googleVersionRetrieved(false)
    , _googleReply(NULL)
    #endif
{
    QStringList langs = QLocale::system().uiLanguages();
    if (langs.length() > 0) {
        _language = langs[0];
    }

#ifndef QGC_NO_GOOGLE_MAPS
    // Google version strings
    _versionGoogleMap            = "m@354000000";
    _versionGoogleSatellite      = "692";
    _versionGoogleLabels         = "h@336";
    _versionGoogleTerrain        = "t@354,r@354000000";
    _secGoogleWord               = "Galileo";
#endif
    // BingMaps
    _versionBingMaps             = "563";
}

//-----------------------------------------------------------------------------
UrlFactory::~UrlFactory()
{
#ifndef QGC_NO_GOOGLE_MAPS
    if(_googleReply)
        _googleReply->deleteLater();
#endif
}


//-----------------------------------------------------------------------------
QString
UrlFactory::getImageFormat(MapType type, const QByteArray& image)
{
    QString format;
    if(image.size() > 2)
    {
        if (image.startsWith(reinterpret_cast<const char*>(pngSignature)))
            format = "png";
        else if (image.startsWith(reinterpret_cast<const char*>(jpegSignature)))
            format = "jpg";
        else if (image.startsWith(reinterpret_cast<const char*>(gifSignature)))
            format = "gif";
        else {
            switch (type) {
            case GaodeStreet:
                format = "png";
                break;
            case GaodeSatellite:
                format = "jpg";
                break;
            case GoogleMap:
            case GoogleLabels:
            case GoogleTerrain:
            case GoogleHybrid:
            case BingMap:
            case StatkartTopo:
                format = "png";
                break;
            case EniroTopo:
                format = "png";
                break;
                /*
                case MapQuestMap:
                case MapQuestSat:
                case OpenStreetMap:
                */
            case MapboxStreets:
            case MapboxLight:
            case MapboxDark:
            case MapboxSatellite:
            case MapboxHybrid:
            case MapboxWheatPaste:
            case MapboxStreetsBasic:
            case MapboxComic:
            case MapboxOutdoors:
            case MapboxRunBikeHike:
            case MapboxPencil:
            case MapboxPirates:
            case MapboxEmerald:
            case MapboxHighContrast:
            case GoogleSatellite:
            case BingSatellite:
            case BingHybrid:
                format = "jpg";
                break;
            case AirmapElevation:
                format = "bin";
                break;
            case VWorldStreet :
                format = "png";
                break;
            case VWorldSatellite :
                format = "jpg";
                break;
            default:
                qWarning("UrlFactory::getImageFormat() Unknown map id %d", type);
                break;
            }
        }
    }
    return format;
}

//-----------------------------------------------------------------------------
QNetworkRequest
UrlFactory::getTileURL(MapType type, int x, int y, int zoom, QNetworkAccessManager* networkManager)
{
    //-- Build URL
    QNetworkRequest request;
    QString url = _getURL(type, x, y, zoom, networkManager);
    if(url.isEmpty()) {
        return request;
    }
    request.setUrl(QUrl(url));
    request.setRawHeader("Accept", "*/*");
    switch (type) {
#ifndef QGC_NO_GOOGLE_MAPS
    case GaodeStreet:
    case GaodeSatellite:
        request.setRawHeader("Referrer", "https://www.gaode.com/maps/");
        break;
    case GoogleMap:
    case GoogleSatellite:
    case GoogleLabels:
    case GoogleTerrain:
    case GoogleHybrid:
        request.setRawHeader("Referrer", "https://www.google.com/maps/preview");
        break;
#endif
    case BingHybrid:
    case BingMap:
    case BingSatellite:
        request.setRawHeader("Referrer", "https://www.bing.com/maps/");
        break;
    case StatkartTopo:
        request.setRawHeader("Referrer", "https://www.norgeskart.no/");
        break;
    case EniroTopo:
        request.setRawHeader("Referrer", "https://www.eniro.se/");
        break;
        /*
        case OpenStreetMapSurfer:
        case OpenStreetMapSurferTerrain:
            request.setRawHeader("Referrer", "http://www.mapsurfer.net/");
            break;
        case OpenStreetMap:
        case OpenStreetOsm:
            request.setRawHeader("Referrer", "https://www.openstreetmap.org/");
            break;
        */

   /* case EsriWorldStreet:
    case EsriWorldSatellite:
    case EsriTerrain: {
        QByteArray token = qgcApp()->toolbox()->settingsManager()->appSettings()->esriToken()->rawValue().toString().toLatin1();
        request.setRawHeader("User-Agent", QByteArrayLiteral("Qt Location based application"));
        request.setRawHeader("User-Token", token);
    }
        return request;*/

    case AirmapElevation:
        request.setRawHeader("Referrer", "https://api.airmap.com/");
        break;

    default:
        break;
    }
    request.setRawHeader("User-Agent", _userAgent);
    return request;
}

//-----------------------------------------------------------------------------
#ifndef QGC_NO_GOOGLE_MAPS
void
UrlFactory::_getSecGoogleWords(int x, int y, QString &sec1, QString &sec2)
{
    sec1 = ""; // after &x=...
    sec2 = ""; // after &zoom=...
    int seclen = ((x * 3) + y) % 8;
    sec2 = _secGoogleWord.left(seclen);
    if (y >= 10000 && y < 100000) {
        sec1 = "&s=";
    }
}

#endif

//-----------------------------------------------------------------------------
QString
UrlFactory::_getURL(MapType type, int x, int y, int zoom, QNetworkAccessManager* networkManager)
{
    switch (type) {
#ifdef QGC_NO_GOOGLE_MAPS
    Q_UNUSED(networkManager);
#else
    case GoogleChinaMap : //Road Map
    {
        QString sec1 = ""; // after &x=...
        QString sec2 = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        return QString("http://mt%1.google.cn/vt/lyrs=%2&gl=cn&hl=zh-CN&x=%3%4&y=%5&z=%6&s=%7&scale=%8").arg(_getServerNum(x, y, 4)).arg("m@298").arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2).arg(1);
    }
        break;
    case GoogleChinaSatellite : //Satallite Map
    {
        QString sec1 = ""; // after &x=...
        QString sec2 = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        return QString("http://mt%1.google.cn/vt/lyrs=%2&gl=cn&hl=zh-CN&x=%3%4&y=%5&z=%6&s=%7&scale=%8").arg(_getServerNum(x, y, 4)).arg("s@170").arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2).arg(1);
    }
        break;

    case GoogleChinaHybrid : //Hybrid Map
    {
        QString sec1 = ""; // after &x=...
        QString sec2 = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        return QString("http://mt%1.google.cn/vt/lyrs=%2&gl=cn&hl=zh-CN&x=%3%4&y=%5&z=%6&s=%7&scale=%8").arg(_getServerNum(x, y, 4)).arg("y@298").arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2).arg(1);
    }
        break;



    case GaodeStreet:
    {
        return QString("http://wprd03.is.autonavi.com/appmaptile?style=7&x=%1&y=%2&z=%3").arg(x).arg(y).arg(zoom);
    }
        break;
    case GaodeSatellite:
    {
        return QString("http://wprd03.is.autonavi.com/appmaptile?style=6&x=%1&y=%2&z=%3").arg(x).arg(y).arg(zoom);
    }
        break;
    case GoogleMap:
    {
        // http://mt1.google.com/vt/lyrs=m
        QString server  = "mt";
        QString request = "vt";
        QString sec1    = ""; // after &x=...
        QString sec2    = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        _tryCorrectGoogleVersions(networkManager);
        return QString("http://%1%2.google.com/%3/lyrs=%4&hl=%5&x=%6%7&y=%8&z=%9&s=%10").arg(server).arg(_getServerNum(x, y, 4)).arg(request).arg(_versionGoogleMap).arg(_language).arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2);
    }
        break;
    case GoogleSatellite:
    {
        // http://mt1.google.com/vt/lyrs=s
        QString server  = "khm";
        QString request = "kh";
        QString sec1    = ""; // after &x=...
        QString sec2    = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        _tryCorrectGoogleVersions(networkManager);
        return QString("http://%1%2.google.com/%3/v=%4&hl=%5&x=%6%7&y=%8&z=%9&s=%10").arg(server).arg(_getServerNum(x, y, 4)).arg(request).arg(_versionGoogleSatellite).arg(_language).arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2);
    }
        break;
    case GoogleLabels:
    {
        QString server  = "mts";
        QString request = "vt";
        QString sec1    = ""; // after &x=...
        QString sec2    = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        _tryCorrectGoogleVersions(networkManager);
        return QString("http://%1%2.google.com/%3/lyrs=%4&hl=%5&x=%6%7&y=%8&z=%9&s=%10").arg(server).arg(_getServerNum(x, y, 4)).arg(request).arg(_versionGoogleLabels).arg(_language).arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2);
    }
        break;
    case GoogleTerrain:
    {
        QString server  = "mt";
        QString request = "vt";
        QString sec1    = ""; // after &x=...
        QString sec2    = ""; // after &zoom=...
        _getSecGoogleWords(x, y, sec1, sec2);
        _tryCorrectGoogleVersions(networkManager);
        return QString("http://%1%2.google.com/%3/v=%4&hl=%5&x=%6%7&y=%8&z=%9&s=%10").arg(server).arg(_getServerNum(x, y, 4)).arg(request).arg(_versionGoogleTerrain).arg(_language).arg(x).arg(sec1).arg(y).arg(zoom).arg(sec2);
    }
        break;
#endif
    case StatkartTopo:
    {
        return QString("http://opencache.statkart.no/gatekeeper/gk/gk.open_gmaps?layers=topo4&zoom=%1&x=%2&y=%3").arg(zoom).arg(x).arg(y);
    }
        break;
    case EniroTopo:
    {
        return QString("http://map.eniro.com/geowebcache/service/tms1.0.0/map/%1/%2/%3.png").arg(zoom).arg(x).arg((1<<zoom)-1-y);
    }
        break;
        /*
    case OpenStreetMap:
    {
        char letter = "abc"[_getServerNum(x, y, 3)];
        return QString("https://%1.tile.openstreetmap.org/%2/%3/%4.png").arg(letter).arg(zoom).arg(x).arg(y);
    }
    break;
    case OpenStreetOsm:
    {
        char letter = "abc"[_getServerNum(x, y, 3)];
        return QString("http://%1.tah.openstreetmap.org/Tiles/tile/%2/%3/%4.png").arg(letter).arg(zoom).arg(x).arg(y);
    }
    break;
    case OpenStreetMapSurfer:
    {
        // http://tiles1.mapsurfer.net/tms_r.ashx?x=37378&y=20826&z=16
        return QString("http://tiles1.mapsurfer.net/tms_r.ashx?x=%1&y=%2&z=%3").arg(x).arg(y).arg(zoom);
    }
    break;
    case OpenStreetMapSurferTerrain:
    {
        // http://tiles2.mapsurfer.net/tms_t.ashx?x=9346&y=5209&z=14
        return QString("http://tiles2.mapsurfer.net/tms_t.ashx?x=%1&y=%2&z=%3").arg(x).arg(y).arg(zoom);
    }
    break;
    */
    case BingMap:
    {
        QString key = _tileXYToQuadKey(x, y, zoom);
        return QString("http://ecn.t%1.tiles.virtualearth.net/tiles/r%2.png?g=%3&mkt=%4").arg(_getServerNum(x, y, 4)).arg(key).arg(_versionBingMaps).arg(_language);
    }
        break;
    case BingSatellite:
    {
        QString key = _tileXYToQuadKey(x, y, zoom);
        return QString("http://ecn.t%1.tiles.virtualearth.net/tiles/a%2.jpeg?g=%3&mkt=%4").arg(_getServerNum(x, y, 4)).arg(key).arg(_versionBingMaps).arg(_language);
    }
        break;
    case BingHybrid:
    {
        QString key = _tileXYToQuadKey(x, y, zoom);
        return QString("http://ecn.t%1.tiles.virtualearth.net/tiles/h%2.jpeg?g=%3&mkt=%4").arg(_getServerNum(x, y, 4)).arg(key).arg(_versionBingMaps).arg(_language);
    }
        /*
    case MapQuestMap:
    {
        char letter = "1234"[_getServerNum(x, y, 4)];
        return QString("http://otile%1.mqcdn.com/tiles/1.0.0/map/%2/%3/%4.jpg").arg(letter).arg(zoom).arg(x).arg(y);
    }
    break;
    case MapQuestSat:
    {
        char letter = "1234"[_getServerNum(x, y, 4)];
        return QString("http://otile%1.mqcdn.com/tiles/1.0.0/sat/%2/%3/%4.jpg").arg(letter).arg(zoom).arg(x).arg(y);
    }
    break;
    */
    case EsriWorldStreet:
        return QString("http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/%1/%2/%3").arg(zoom).arg(y).arg(x);
    case EsriWorldSatellite:
        return QString("http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/%1/%2/%3").arg(zoom).arg(y).arg(x);
    case EsriTerrain:
        return QString("http://server.arcgisonline.com/ArcGIS/rest/services/World_Terrain_Base/MapServer/tile/%1/%2/%3").arg(zoom).arg(y).arg(x);

case MapboxStreets:
    case MapboxLight:
    case MapboxDark:
    case MapboxSatellite:
    case MapboxHybrid:
    case MapboxWheatPaste:
    case MapboxStreetsBasic:
    case MapboxComic:
    case MapboxOutdoors:
    case MapboxRunBikeHike:
    case MapboxPencil:
    case MapboxPirates:
    case MapboxEmerald:
    case MapboxHighContrast:
    {
        //QString mapBoxToken = qgcApp()->toolbox()->settingsManager()->appSettings()->mapboxToken()->rawValue().toString();
        //下面这个是我的账号
        //QString mapBoxToken="pk.eyJ1IjoibG9va2luZ2ZlbmciLCJhIjoiY2pvOWZuanV6MDNvdzNwbXBibHlkMmVtcyJ9.hIyJhazZfKQN6eAW7O9yAw";
        //QString mapBoxToken="pk.eyJ1IjoidHJhdmVsZXIiLCJhIjoiY2lpbXlzdWxxMDA1NXZra3MwMnN5MnpraSJ9.z4saehoFXwlTkhLsXMJHhg";
        QString mapBoxToken="pk.eyJ1IjoidHJhdmVsZXIiLCJhIjoiY2lpbXlzdWxxMDA1NXZra3MwMnN5MnpraSJ9.z4saehoFXwlTkhLsXMJHhg";
        if(!mapBoxToken.isEmpty()) {
            QString server = "https://api.mapbox.com/v4/";
            switch(type) {
            case MapboxStreets:
                server += "mapbox.streets";
                break;
            case MapboxLight:
                server += "mapbox.light";
                break;
            case MapboxDark:
                server += "mapbox.dark";
                break;
            case MapboxSatellite:
                server += "mapbox.satellite";
                break;
            case MapboxHybrid:
                server += "mapbox.streets-satellite";
                //server += "mapbox.terrain-rgb";
                break;
            case MapboxWheatPaste:
                server += "mapbox.wheatpaste";
                break;
            case MapboxStreetsBasic:
                server += "mapbox.streets-basic";
                break;
            case MapboxComic:
                server += "mapbox.comic";
                break;
            case MapboxOutdoors:
                server += "mapbox.outdoors";
                break;
            case MapboxRunBikeHike:
                server += "mapbox.run-bike-hike";
                break;
            case MapboxPencil:
                server += "mapbox.pencil";
                break;
            case MapboxPirates:
                server += "mapbox.pirates";
                break;
            case MapboxEmerald:
                server += "mapbox.emerald";
                break;
            case MapboxHighContrast:
                server += "mapbox.high-contrast";
                break;
            default:
                return QString::null;
            }
            server += QString("/%1/%2/%3.jpg80?access_token=%4").arg(zoom).arg(x).arg(y).arg(mapBoxToken);
            //qDebug()<<"_________"<<server;
            return server;
           //return QString("https://api.mapbox.com/styles/v1/mapbox/dark/tiles/%1/%2/%3?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NDg1bDA1cjYzM280NHJ5NzlvNDMifQ.d6e-nNyBDtmQCVwVNivz7A").arg(zoom).arg(x).arg(y);


        }
    }
        break;
    case AirmapElevation:
    {
        return QString("https://api.airmap.com/elevation/v1/ele/carpet?points=%1,%2,%3,%4").arg(static_cast<double>(y)*QGCMapEngine::srtm1TileSize - 90.0).arg(
                    static_cast<double>(x)*QGCMapEngine::srtm1TileSize - 180.0).arg(
                    static_cast<double>(y + 1)*QGCMapEngine::srtm1TileSize - 90.0).arg(
                    static_cast<double>(x + 1)*QGCMapEngine::srtm1TileSize - 180.0);
    }
        break;

    case VWorldStreet :
    {
        int gap = zoom - 6;
        int x_min = 53 * pow(2, gap);
        int x_max = 55 * pow(2, gap) + (2*gap - 1);
        int y_min = 22 * pow(2, gap);
        int y_max = 26 * pow(2, gap) + (2*gap - 1);

        if ( zoom > 19 ) {
            return QString("");
        }
        else if ( zoom > 5 && x >= x_min && x <= x_max && y >= y_min && y <= y_max ) {
            return QString("http://xdworld.vworld.kr:8080/2d/Base/service/%1/%2/%3.png").arg(zoom).arg(x).arg(y);
        }
        else {
            QString key = _tileXYToQuadKey(x, y, zoom);
            return QString("http://ecn.t%1.tiles.virtualearth.net/tiles/r%2.png?g=%3&mkt=%4").arg(_getServerNum(x, y, 4)).arg(key).arg(_versionBingMaps).arg(_language);
        }


    }
        break;

    case VWorldSatellite :
    {
        int gap = zoom - 6;
        int x_min = 53 * pow(2, gap);
        int x_max = 55 * pow(2, gap) + (2*gap - 1);
        int y_min = 22 * pow(2, gap);
        int y_max = 26 * pow(2, gap) + (2*gap - 1);

        if ( zoom > 19 ) {
            return QString("");
        }
        else if ( zoom > 5 && x >= x_min && x <= x_max && y >= y_min && y <= y_max ) {
            return QString("http://xdworld.vworld.kr:8080/2d/Satellite/service/%1/%2/%3.jpeg").arg(zoom).arg(x).arg(y);
        }
        else {
            QString key = _tileXYToQuadKey(x, y, zoom);
            return QString("http://ecn.t%1.tiles.virtualearth.net/tiles/a%2.jpeg?g=%3&mkt=%4").arg(_getServerNum(x, y, 4)).arg(key).arg(_versionBingMaps).arg(_language);
        }
    }
        break;
    default:
        qWarning("Unknown map id %d\n", type);
        break;
    }
    return QString::null;
}

//-----------------------------------------------------------------------------
QString
UrlFactory::_tileXYToQuadKey(int tileX, int tileY, int levelOfDetail)
{
    QString quadKey;
    for (int i = levelOfDetail; i > 0; i--) {
        char digit = '0';
        int mask   = 1 << (i - 1);
        if ((tileX & mask) != 0) {
            digit++;
        }
        if ((tileY & mask) != 0) {
            digit++;
            digit++;
        }
        quadKey.append(digit);
    }
    return quadKey;
}

//-----------------------------------------------------------------------------
int
UrlFactory::_getServerNum(int x, int y, int max)
{
    return (x + 2 * y) % max;
}

//-----------------------------------------------------------------------------
#ifndef QGC_NO_GOOGLE_MAPS
void
UrlFactory::_networkReplyError(QNetworkReply::NetworkError error)
{
    qWarning() << "Could not connect to google maps. Error:" << error;
    if(_googleReply)
    {
        _googleReply->deleteLater();
        _googleReply = NULL;
    }
}
#endif
//-----------------------------------------------------------------------------
#ifndef QGC_NO_GOOGLE_MAPS
void
UrlFactory::_replyDestroyed()
{
    _googleReply = NULL;
}
#endif

//-----------------------------------------------------------------------------
#ifndef QGC_NO_GOOGLE_MAPS
void
UrlFactory::_googleVersionCompleted()
{
    if (!_googleReply || (_googleReply->error() != QNetworkReply::NoError)) {
        qDebug() << "Error collecting Google maps version info";
        return;
    }
    QString html = QString(_googleReply->readAll());

#if defined(DEBUG_GOOGLE_MAPS)
    QString filename = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    filename += "/google.output";
    QFile file(filename);
    if (file.open(QIODevice::ReadWrite))
    {
        QTextStream stream( &file );
        stream << html << endl;
    }
#endif

    QRegExp reg("\"*https?://mt\\D?\\d..*/vt\\?lyrs=m@(\\d*)", Qt::CaseInsensitive);
    if (reg.indexIn(html) != -1) {
        QStringList gc = reg.capturedTexts();
        _versionGoogleMap = QString("m@%1").arg(gc[1]);
    }
    reg = QRegExp("\"*https?://khm\\D?\\d.googleapis.com/kh\\?v=(\\d*)", Qt::CaseInsensitive);
    if (reg.indexIn(html) != -1) {
        QStringList gc = reg.capturedTexts();
        _versionGoogleSatellite = gc[1];
    }
    reg = QRegExp("\"*https?://mt\\D?\\d..*/vt\\?lyrs=t@(\\d*),r@(\\d*)", Qt::CaseInsensitive);
    if (reg.indexIn(html) != -1) {
        QStringList gc = reg.capturedTexts();
        _versionGoogleTerrain = QString("t@%1,r@%2").arg(gc[1]).arg(gc[2]);
    }
    _googleReply->deleteLater();
    _googleReply = NULL;
}
#endif

//-----------------------------------------------------------------------------
#ifndef QGC_NO_GOOGLE_MAPS
void
UrlFactory::_tryCorrectGoogleVersions(QNetworkAccessManager* networkManager)
{
    QMutexLocker locker(&_googleVersionMutex);
    if (_googleVersionRetrieved) {
        return;
    }
    _googleVersionRetrieved = true;
    if(networkManager)
    {
        QNetworkRequest qheader;
        QNetworkProxy proxy = networkManager->proxy();
        QNetworkProxy tProxy;
        tProxy.setType(QNetworkProxy::DefaultProxy);
        networkManager->setProxy(tProxy);
        QSslConfiguration conf = qheader.sslConfiguration();
        conf.setPeerVerifyMode(QSslSocket::VerifyNone);
        qheader.setSslConfiguration(conf);
        QString url = "http://maps.google.com/maps/api/js?v=3.2&sensor=false";
        qheader.setUrl(QUrl(url));
        QByteArray ua;
        ua.append(getQGCMapEngine()->userAgent());
        qheader.setRawHeader("User-Agent", ua);
        _googleReply = networkManager->get(qheader);
        connect(_googleReply, &QNetworkReply::finished, this, &UrlFactory::_googleVersionCompleted);
        connect(_googleReply, &QNetworkReply::destroyed, this, &UrlFactory::_replyDestroyed);
        connect(_googleReply, static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error),
                this, &UrlFactory::_networkReplyError);
        networkManager->setProxy(proxy);
    }
}
#endif

#define AVERAGE_GOOGLE_STREET_MAP   4913
#define AVERAGE_GOOGLE_TERRAIN_MAP  19391
#define AVERAGE_BING_STREET_MAP     1297
#define AVERAGE_BING_SAT_MAP        19597
#define AVERAGE_GOOGLE_SAT_MAP      56887
#define AVERAGE_MAPBOX_SAT_MAP      15739
#define AVERAGE_MAPBOX_STREET_MAP   5648
#define AVERAGE_TILE_SIZE           13652
#define AVERAGE_AIRMAP_ELEV_SIZE    2786

//-----------------------------------------------------------------------------
quint32
UrlFactory::averageSizeForType(MapType type)
{
    switch (type) {
    case GoogleMap:
        return AVERAGE_GOOGLE_STREET_MAP;
    case BingMap:
        return AVERAGE_BING_STREET_MAP;
    case GoogleSatellite:
        return AVERAGE_GOOGLE_SAT_MAP;
    case MapboxSatellite:
        return AVERAGE_MAPBOX_SAT_MAP;
    case BingHybrid:
    case BingSatellite:
        return AVERAGE_BING_SAT_MAP;
    case GoogleTerrain:
        return AVERAGE_GOOGLE_TERRAIN_MAP;
    case MapboxStreets:
    case MapboxStreetsBasic:
    case MapboxRunBikeHike:
        return AVERAGE_MAPBOX_STREET_MAP;
    case AirmapElevation:
        return AVERAGE_AIRMAP_ELEV_SIZE;
    case GoogleLabels:
    case MapboxDark:
    case MapboxLight:
    case MapboxOutdoors:
    case MapboxPencil:
    case OpenStreetMap:
    case GoogleHybrid:
    case MapboxComic:
    case MapboxEmerald:
    case MapboxHighContrast:
    case MapboxHybrid:
    case MapboxPirates:
    case MapboxWheatPaste:
    default:
        break;
    }
    return AVERAGE_TILE_SIZE;
}
