QT += widgets core testlib quick location-private location sql quickwidgets xml

TEMPLATE = lib
TARGET = Wmap
DESTDIR = $$PWD/../bin-Debug
CONFIG += debug
DEFINES += _WINDOWS _UNICODE WMAP_LIBRARY QT_DEPRECATED_WARNINGS DEM_CORE_DLL
LIBS += -L"$$PWD/DemReader/Libs/Win32/Debug" \
   -lDemReader
DEPENDPATH += .
MOC_DIR += .
OBJECTS_DIR += debug
UI_DIR += .
RCC_DIR += .
CONFIG += c++11

INCLUDEPATH += $$PWD/QtLocationPlugin \
    $$PWD/DemReader/Include

HEADERS += ./JsonHelper.h \
    ./QGCGeo.h \
    ./UTM.h \
    ./GpsTranslater.h \
    ./QGCFileDialogController.h \
    ./QGCMapPalette.h \
    ./QGCMapPolygon.h \
    ./QGCQGeoCoordinate.h \
    ./mymapenginemanager.h \
    ./wmap.h
SOURCES += ./GpsTranslater.cpp \
    ./UTM.cpp \
    ./mymapenginemanager.cpp \
    ./wmap.cpp \
    ./QGCFileDialogController.cc \
    ./QGCGeo.cc \
    ./QGCMapPalette.cc \
    ./QGCMapPolygon.cc \
    ./QGCQGeoCoordinate.cc
FORMS += ./wmap.ui
RESOURCES += res.qrc
include($$PWD/QtLocationPlugin/QGCLocationPlugin.pri)


