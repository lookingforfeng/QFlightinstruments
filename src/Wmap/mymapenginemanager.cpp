#include "mymapenginemanager.h"

MyMapEngineManager::MyMapEngineManager()
    : _mapEngineManager(NULL)
{
    _mapEngineManager       = new QGCMapEngineManager();
    //_mapEngineManager->init();
    //qDebug()<<"____________new QGCMapEngineManager";
}


