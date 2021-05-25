
QT  += location-private positioning-private network

contains(QT_VERSION, 5.5.1) {
    #message(Using Local QtLocation headers for Qt 5.5.1)
    INCLUDEPATH += \
        $$PWD/qtlocation/include \
} else {
    #message(Using Default QtLocation headers)
    INCLUDEPATH += $$QT.location.includes
}

HEADERS += \
    $$PWD/QGCMapEngine.h \
    $$PWD/QGCMapEngineData.h \
    $$PWD/QGCMapTileSet.h \
    $$PWD/QGCMapUrlEngine.h \
    $$PWD/QGCTileCacheWorker.h \
    $$PWD/QGeoCodeReplyQGC.h \
    $$PWD/QGeoCodingManagerEngineQGC.h \
    $$PWD/QGeoMapReplyQGC.h \
    $$PWD/QGeoServiceProviderPluginQGC.h \
    $$PWD/QGeoTileFetcherQGC.h \
    $$PWD/QGeoTileLocalReply.h \
    $$PWD/QGeoTiledMappingManagerEngineQGC.h \
    $$PWD/QGCMapEngineManager.h \
    $$PWD/QmlObjectListModel.h \

SOURCES += \
    $$PWD/QGCMapEngine.cpp \
    $$PWD/QGCMapTileSet.cpp \
    $$PWD/QGCMapUrlEngine.cpp \
    $$PWD/QGCTileCacheWorker.cpp \
    $$PWD/QGeoCodeReplyQGC.cpp \
    $$PWD/QGeoCodingManagerEngineQGC.cpp \
    $$PWD/QGeoMapReplyQGC.cpp \
    $$PWD/QGeoServiceProviderPluginQGC.cpp \
    $$PWD/QGeoTileFetcherQGC.cpp \
    $$PWD/QGeoTileLocalReply.cpp \
    $$PWD/QGeoTiledMappingManagerEngineQGC.cpp \
    $$PWD/QGCMapEngineManager.cc \
    $$PWD/QmlObjectListModel.cc \

OTHER_FILES += \
    $$PWD/qgc_maps_plugin.json
