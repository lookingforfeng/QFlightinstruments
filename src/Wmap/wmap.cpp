#include "wmap.h"
#include "ui_wmap.h"
#include <QtPlugin>
#include "QGCMapEngineManager.h"
#include "QQmlContext"

#include <QQmlEngine>
#include "mymapenginemanager.h"
#include "QGCFileDialogController.h"
#include "QGCMapPalette.h"
#include "QGCMapPolygon.h"
#include "GpsTranslater.h"

//获取高程值
#include "DemReaderInterface.h"

static QObject* MyMapEngineManagerCallback(QQmlEngine*, QJSEngine*);
static QObject* QGCMapPolygonCallback(QQmlEngine*, QJSEngine*);

class WMapInstance;

static WMapInstance *ins = NULL;
class WMapInstance
{
public:
    WMapInstance()
    {
        //引入地图插件
        Q_IMPORT_PLUGIN(QGeoServiceProviderFactoryQGC);

        //注册qml类到qml空间
        qmlRegisterType<QGCMapPalette>("QGCMapPalette_R", 1, 0, "QGCMapPalette_instance");
        qmlRegisterSingletonType<MyMapEngineManager>("MyMapEngineManager_R", 1, 0, "MyMapEngineManager_instance", MyMapEngineManagerCallback);
        qmlRegisterSingletonType<QGCMapPolygon>("QGCMapPolygon_R", 1, 0, "QGCMapPolygon_instance", QGCMapPolygonCallback);
        qmlRegisterType<QGCFileDialogController>("QGCControllers", 1, 0, "QGCFileDialogController");
    }
    ~WMapInstance() {}

    static WMapInstance *instance()
    {
        if (NULL == ins)
            ins = new WMapInstance;
        return ins;
    }
};

Wmap::Wmap(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Wmap)
{
    ui->setupUi(this);

    WMapInstance::instance();

    //载入主控件
    QUrl source("qrc:/qml/main.qml");
    ui->quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);
    ui->quickWidget->setSource(source);
    ui->quickWidget->setClearColor(QColor(Qt::transparent));

    //转发qml信号
    QObject* map_item = ui->quickWidget->rootObject()->findChild<QObject*>("lookingfeng_wmap");
    map_root_item = qobject_cast<QQuickItem*>(map_item);

    connect(map_root_item, SIGNAL(mapCenterChanged(double, double)), this, SLOT(deal_mapCenterChanged(double, double)));
    connect(map_root_item, SIGNAL(map_error(QString)), this, SIGNAL(map_error(QString)));
    connect(map_root_item, SIGNAL(measure_distance(double)), this, SIGNAL(measure_distance(double)));
    connect(map_root_item, SIGNAL(clicked_Point(double, double)), this, SLOT(deal_clicked_Point(double, double)));
    connect(map_root_item, SIGNAL(measure_angle(double)), this, SIGNAL(measure_angle(double)));
    connect(map_root_item, SIGNAL(marker_clicked(double, double, QString)), this, SLOT(deal_marker_clicked(double, double, QString)));
    connect(map_root_item, SIGNAL(marker_position_changed(double, double, QString)), this, SLOT(deal_marker_position_changed(double, double, QString)));

    //初始化图层，添加默认图层
    overlays_["default"] = default_overlay;
}

Wmap::~Wmap()
{
    delete ui;
}

static QObject* MyMapEngineManagerCallback(QQmlEngine*, QJSEngine*)
{
    MyMapEngineManager* _MyMapEngineManager = new MyMapEngineManager();
    return _MyMapEngineManager;
}

static QObject* QGCMapPolygonCallback(QQmlEngine*, QJSEngine*)
{
    static QGCMapPolygon* g_QGCMapPolygon = NULL;
    if (NULL == g_QGCMapPolygon)
        g_QGCMapPolygon = new QGCMapPolygon();
    return g_QGCMapPolygon;
}

void Wmap::addMarker(const QString& name, const QString& image_file, const double& lat,
                     const double& lng, const QString& color, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return;
    }

    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

    QVariant obj;
    QMetaObject::invokeMethod(map_root_item, "addMarker", Q_RETURN_ARG(QVariant, obj),
                              Q_ARG(QVariant, name), Q_ARG(QVariant, image_file),
                              Q_ARG(QVariant, lat_adapted), Q_ARG(QVariant, lng_adapted), Q_ARG(QVariant, color));
    overlay[name] = obj;
}

void Wmap::addMarker(const QString& name, const int& index, const double& lat, const double& lng,
                     const QString& color, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return;
    }
    QVariant obj;

    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

    QMetaObject::invokeMethod(map_root_item, "addMarker1", Q_RETURN_ARG(QVariant, obj),
                              Q_ARG(QVariant, name), Q_ARG(QVariant, index),
                              Q_ARG(QVariant, lat_adapted), Q_ARG(QVariant, lng_adapted), Q_ARG(QVariant, color));
    overlay[name] = obj;
}

void Wmap::addTextMarker(const QString&name, const QString&text, const double&lat, const double&lng,
                         const QString&color, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return;
    }
    QVariant obj;

    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

    QMetaObject::invokeMethod(map_root_item, "addTextMarker", Q_RETURN_ARG(QVariant, obj),
                              Q_ARG(QVariant, name), Q_ARG(QVariant, text),
                              Q_ARG(QVariant, lat_adapted), Q_ARG(QVariant, lng_adapted), Q_ARG(QVariant, color));
    overlay[name] = obj;
}

QVariant Wmap::addLine(const QString&name, const double&line_width, const QString&line_color, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return overlay[name];
    }
    QVariant the_obj;
    QMetaObject::invokeMethod(map_root_item, "addLine", Q_RETURN_ARG(QVariant, the_obj), Q_ARG(QVariant, name),
                              Q_ARG(QVariant, line_width), Q_ARG(QVariant, line_color));
    overlay[name] = the_obj;
    return the_obj;
}

void Wmap::addLine_point(const QString&name, const double&lat, const double&lng, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        double lat_adapted=lat;
        double lng_adapted=lng;
        adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

        QMetaObject::invokeMethod(map_root_item, "addLine_point", Q_ARG(QVariant, overlay[name]), Q_ARG(QVariant, lat_adapted),
                                  Q_ARG(QVariant, lng_adapted));
    }
}

void Wmap::addLine_point(QVariant line_obj, const double&lat, const double&lng, OverLay& overlay)
{
    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

    QMetaObject::invokeMethod(map_root_item, "addLine_point", Q_ARG(QVariant, line_obj), Q_ARG(QVariant, lat_adapted),
                              Q_ARG(QVariant, lng_adapted));
}

void Wmap::deleteLine_point(const QString&name, const double&lat, const double&lng, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        double lat_adapted=lat;
        double lng_adapted=lng;
        adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

        QMetaObject::invokeMethod(map_root_item, "deleteLine_point", Q_ARG(QVariant, overlay[name]), Q_ARG(QVariant, lat_adapted),
                                  Q_ARG(QVariant, lng_adapted));
    }
}

void Wmap::addRegion(const QString&name, const double&border_width, const QString&border_color,
                     QString&fill_color, const double&fill_opacity, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return;
    }
    QVariant the_obj;
    QMetaObject::invokeMethod(map_root_item, "addRegion", Q_RETURN_ARG(QVariant, the_obj)
                              , Q_ARG(QVariant, name), Q_ARG(QVariant, border_width),
                              Q_ARG(QVariant, border_color), Q_ARG(QVariant, fill_color),
                              Q_ARG(QVariant, fill_opacity));
    overlay[name] = the_obj;
}


void Wmap::addRegion_point(const QString&name, const double&lat, const double&lng, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        double lat_adapted=lat;
        double lng_adapted=lng;
        adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

        QMetaObject::invokeMethod(map_root_item, "addRegion_point", Q_ARG(QVariant, overlay[name]), Q_ARG(QVariant, lat_adapted),
                                  Q_ARG(QVariant, lng_adapted));
    }
}

void Wmap::rotateMarker(const QString &name, const double &angle, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        QMetaObject::invokeMethod(map_root_item, "rotateMarker", Q_ARG(QVariant, overlay[name]), Q_ARG(QVariant, angle));
    }
}

void Wmap::deleteMarker(const QString& name, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        QMetaObject::invokeMethod(map_root_item, "deleteMarker", Q_ARG(QVariant, overlay.take(name)));
    }
}

void Wmap::setMapCenter(const double& lat, const double& lng)
{
    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

    QMetaObject::invokeMethod(map_root_item, "setMapCenter", Q_ARG(QVariant, lat_adapted), Q_ARG(QVariant, lng_adapted));
}

void Wmap::getMapCenter(double *lat, double *lng)
{
    double lat_adapted=map_root_item->property("mapcenter_lat").toDouble();
    double lng_adapted=map_root_item->property("mapcenter_lng").toDouble();
    adaptMapCoordinateSys_output(lat_adapted,lng_adapted);

    *lat = lat_adapted;
    *lng = lng_adapted;
}

void Wmap::setZoomLevel(double zoomlevel)
{
    QMetaObject::invokeMethod(map_root_item, "setZoomLevel", Q_ARG(QVariant, zoomlevel));
}

double Wmap::getZoomLevel()
{
    return (map_root_item->property("map_zoom_level")).toDouble();
}

void Wmap::addRectangle(const QString &name, const double&lat1, const double&lng1,
                        const double&lat2, const double&lng2, const double&borer_width,
                        const QString &border_color, const QString &fill_color,
                        const double&fill_opacity, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return;
    }
    QVariant the_obj;

    double lat_adapted1=lat1;
    double lng_adapted1=lng1;
    adaptMapCoordinateSys_input(lat_adapted1,lng_adapted1);
    double lat_adapted2=lat2;
    double lng_adapted2=lng2;
    adaptMapCoordinateSys_input(lat_adapted2,lng_adapted2);

    QMetaObject::invokeMethod(map_root_item, "addRectangle", Q_RETURN_ARG(QVariant, the_obj), \
                              Q_ARG(QVariant, name), Q_ARG(QVariant, lat_adapted1), Q_ARG(QVariant, lng_adapted1), \
                              Q_ARG(QVariant, lat_adapted2), Q_ARG(QVariant, lng_adapted2), Q_ARG(QVariant, borer_width), \
                              Q_ARG(QVariant, border_color), Q_ARG(QVariant, fill_color), Q_ARG(QVariant, fill_opacity));
    overlay[name] = the_obj;
}

void Wmap::addCircle(const QString &name, const double&lat,
                     const double&lng, const double&radius, const double&borer_width,
                     const QString &border_color, const QString &fill_color,
                     const double&fill_opacity, OverLay& overlay)
{
    if (DuplicationCheck(overlay, name))
    {
        return;
    }
    QVariant the_obj;

    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

    QMetaObject::invokeMethod(map_root_item, "addCircle", Q_RETURN_ARG(QVariant, the_obj), \
                              Q_ARG(QVariant, name), Q_ARG(QVariant, lat_adapted), Q_ARG(QVariant, lng_adapted), \
                              Q_ARG(QVariant, radius), Q_ARG(QVariant, borer_width), \
                              Q_ARG(QVariant, border_color), Q_ARG(QVariant, fill_color), Q_ARG(QVariant, fill_opacity));
    overlay[name] = the_obj;
}

void Wmap::moveMarker(const QString &name, const double &lat, const double &lng, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        double lat_adapted=lat;
        double lng_adapted=lng;
        adaptMapCoordinateSys_input(lat_adapted,lng_adapted);

        QMetaObject::invokeMethod(map_root_item, "moveMarker", \
                                  Q_ARG(QVariant, overlay[name]), Q_ARG(QVariant, lat_adapted), Q_ARG(QVariant, lng_adapted));
    }
}

void  Wmap::setMapType(const int& type_num)
{
    QMetaObject::invokeMethod(map_root_item, "setMapType", \
                              Q_ARG(QVariant, type_num));
}

void Wmap::deleteAllMarker(OverLay& overlay)
{
    while (overlay.count() > 0)
    {
        QMetaObject::invokeMethod(map_root_item, "deleteMarker", Q_ARG(QVariant, overlay.take(overlay.firstKey())));
    }
}

void Wmap::setMarkerHighlight(const QString &name, bool highlight, const QString& color, OverLay& overlay)
{
    if (overlay.contains(name))
    {
        QMetaObject::invokeMethod(map_root_item, "setMarkerHighlight", \
                                  Q_ARG(QVariant, overlay[name]), Q_ARG(QVariant, highlight), Q_ARG(QVariant, color));
    }
}

void Wmap::DTEDReader_init(HQDTEDReader::eDriverType type, std::string demFilePath) throw(std::exception)
{
    //HQDTEDReader_init(type, demFilePath);
}

short  Wmap::DTEDReader_getAltitude(double longitude, double latitude) throw(std::exception)
{
    return 0;
    //return HQDTEDReader_getAltitude(longitude, latitude);
}

std::string Wmap::DTEDReader_getDemFilePath()
{
    return "";
    //return HQDTEDReader_getDemFilePath();
}

void Wmap::DTEDReader_setDemFilePath(std::string path)
{
    //HQDTEDReader_setDemFilePath(path);
}

void Wmap::DTEDReader_release()
{
    //HQDTEDReader_release();
}

void Wmap::showPolygon()
{
    QMetaObject::invokeMethod(map_root_item, "showPolygon");
}

void Wmap::hidePolygon()
{
    QMetaObject::invokeMethod(map_root_item, "hidePolygon");
}

QList<QGeoCoordinate> Wmap::coordinateList()
{
    QGCMapPolygon *_polygon = (QGCMapPolygon *)QGCMapPolygonCallback(NULL, NULL);
    return _polygon->coordinateList();

    //@TODO：这个列表要转坐标系
}

void Wmap::setBearing(double bearing)
{
    QMetaObject::invokeMethod(map_root_item, "setBearing", Q_ARG(QVariant, bearing));
}

void Wmap::deal_clicked_Point(double lat, double lng)
{
    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_output(lat_adapted,lng_adapted);
    emit clicked_Point(lat_adapted,lng_adapted);
}

void Wmap::deal_marker_clicked(double lat, double lng, QString name)
{
    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_output(lat_adapted,lng_adapted);
    emit marker_clicked(lat_adapted,lng_adapted, name);
}

void Wmap::deal_marker_position_changed(double lat, double lng, QString name )
{
    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_output(lat_adapted,lng_adapted);
    emit marker_position_changed(lat_adapted,lng_adapted, name);
}

void Wmap::deal_mapCenterChanged(double lat, double lng)
{
    double lat_adapted=lat;
    double lng_adapted=lng;
    adaptMapCoordinateSys_output(lat_adapted,lng_adapted);
    emit mapCenterChanged(lat_adapted,lng_adapted);
}

bool Wmap::DuplicationCheck(OverLay& overlay, QString name)
{
    if (!overlay.contains(name))
        return false;
    else
    {
        emit map_error("duplication of name");
        return true;
    }
}

void Wmap::adaptMapCoordinateSys_input(double &lat, double &lng)
{
    //如果地图是国测局坐标系，进行转换，否则不进行任何操作
    if(is_maptype_gcj)
    {
        double temp_lat=lat;
        double temp_lng=lng;
        bool ok=GpsTranslater::gps84_To_Gcj02(temp_lat,temp_lng,lat,lng);
        //非中国区会转换失败，还原初始值
        if(!ok)
        {
            lat=temp_lat;
            lng=temp_lng;
        }
    }
}

void Wmap::adaptMapCoordinateSys_output(double &lat, double &lng)
{
    //如果地图是国测局坐标系，进行转换，否则不进行任何操作
    if(is_maptype_gcj)
    {
        double temp_lat=lat;
        double temp_lng=lng;
        bool ok=GpsTranslater::gcj_To_Gps84(temp_lat,temp_lng,lat,lng);
        //非中国区会转换失败，还原初始值
        if(!ok)
        {
            lat=temp_lat;
            lng=temp_lng;
        }
    }
}

