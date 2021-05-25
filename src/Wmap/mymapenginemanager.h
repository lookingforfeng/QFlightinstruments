#ifndef MYMAPENGINEMANAGER_H
#define MYMAPENGINEMANAGER_H

#include <qobject.h>
#include"QGCMapEngineManager.h"

class MyMapEngineManager: public QObject
{
    Q_OBJECT
public:
    MyMapEngineManager();

    Q_PROPERTY(QGCMapEngineManager* mapEngineManager    READ mapEngineManager       CONSTANT)

    QGCMapEngineManager*    mapEngineManager    ()  { return _mapEngineManager; }



private:
    QGCMapEngineManager*    _mapEngineManager;
};

#endif // MYMAPENGINEMANAGER_H
