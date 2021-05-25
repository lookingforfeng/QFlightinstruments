import QtQuick 2.0
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Dialogs  1.2

Map {
    id: _map
    anchors.fill: parent
    zoomLevel:                  5
    center:                     wps84_To_Gcj02(30.67,104.07, 0.0)
    property rect   centerViewport:             Qt.rect(0, 0, width, height)

    /*对GPS坐标做处理，Wps84转Gcj-02*/
    property real pi: 3.1415926535897932384626
    property real a: 6378245.0
    property real ee: 0.00669342162296594323;

    property string mapName:'defaultMap'


    function transformLat(x , y)
    {
        var ret
        ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.sqrt(Math.abs(x))
        ret += (20.0 * Math.sin(6.0 * x * pi) + 20.0 * Math.sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * Math.sin(y * pi) + 40.0 * Math.sin(y / 3.0 * pi)) * 2.0 / 3.0
        ret += (160.0 * Math.sin(y / 12.0 * pi) + 320 * Math.sin(y * pi / 30.0)) * 2.0 / 3.0
        return ret
    }

    function transformLon(x, y) {
        var ret
        ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.sqrt(Math.abs(x))
        ret += (20.0 * Math.sin(6.0 * x * pi) + 20.0 * Math.sin(2.0 * x * pi)) * 2.0 / 3.0
        ret += (20.0 * Math.sin(x * pi) + 40.0 * Math.sin(x / 3.0 * pi)) * 2.0 / 3.0
        ret += (150.0 * Math.sin(x / 12.0 * pi) + 300.0 * Math.sin(x / 30.0 * pi)) * 2.0 / 3.0
        return ret
    }

    function  wps84_To_Gcj02(lat, lon) {
        var dLat, dLon, radLat, magic, sqrtMagic , mgLat, mgLon
        dLat = transformLat(lon - 105.0, lat - 35.0);
        dLon = transformLon(lon - 105.0, lat - 35.0);
        radLat = lat / 180.0 * pi;
        magic = Math.sin(radLat);
        magic = 1 - ee * magic * magic;
        sqrtMagic = Math.sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
        dLon = (dLon * 180.0) / (a / sqrtMagic * Math.cos(radLat) * pi);
        mgLat = lat + dLat;
        mgLon = lon + dLon;

        return  QtPositioning.coordinate(mgLat, mgLon);
    }

    // 地图插件
    plugin:  Plugin { name: "QGroundControl" }

    function updateActiveMapType(maptype_num) {
        var fullMapName = "Google Hybrid Map"
        if (maptype_num===0)
        {
            fullMapName = "Google Satellite Map"
        }
        else if (maptype_num===1)
        {
            fullMapName = "Google Street Map"
        }
        else if (maptype_num===2)
        {
            fullMapName = "Google Hybrid Map"
        }
        for (var i = 0; i < _map.supportedMapTypes.length; i++) {
            if (fullMapName === _map.supportedMapTypes[i].name) {
                _map.activeMapType = _map.supportedMapTypes[i]
                return
            }
        }
    }

    Component.onCompleted: {
        updateActiveMapType()
    }
}


/*可设定的地图列表
qml: _________________________________Google Street Map
qml: _________________________________Google Satellite Map
qml: _________________________________Google Terrain Map
qml: _________________________________Gaode Street Map
qml: _________________________________Gaode Satellite Map
qml: _________________________________Bing Street Map
qml: _________________________________Bing Satellite Map
qml: _________________________________Bing Hybrid Map
qml: _________________________________GoogleChina Street Map
qml: _________________________________GoogleChina Satellite Map
qml: _________________________________GoogleChina Hybrid Map
qml: _________________________________Statkart Terrain Map
qml: _________________________________Eniro Terrain Map
qml: _________________________________Esri Street Map
qml: _________________________________Esri Satellite Map
qml: _________________________________Esri Terrain Map
qml: _________________________________VWorld Satellite Map
qml: _________________________________VWorld Street Map
qml: _________________________________Mapbox Street Map
qml: _________________________________Mapbox Satellite Map
qml: _________________________________Mapbox High Contrast Map
qml: _________________________________Mapbox Light Map
qml: _________________________________Mapbox Dark Map
qml: _________________________________Mapbox Hybrid Map
qml: _________________________________Mapbox Wheat Paste Map
qml: _________________________________Mapbox Streets Basic Map
qml: _________________________________Mapbox Comic Map
qml: _________________________________Mapbox Outdoors Map
qml: _________________________________Mapbox Run, Byke and Hike Map
qml: _________________________________Mapbox Pencil Map
qml: _________________________________Mapbox Pirates Map
qml: _________________________________Mapbox Emerald Map
*/
