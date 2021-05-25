/****************************************************************************
** Meta object code from reading C++ file 'wmap.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.9.9)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../Wmap/wmap.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'wmap.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.9.9. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_Wmap_t {
    QByteArrayData data[16];
    char stringdata0[226];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Wmap_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Wmap_t qt_meta_stringdata_Wmap = {
    {
QT_MOC_LITERAL(0, 0, 4), // "Wmap"
QT_MOC_LITERAL(1, 5, 10), // "msgFromQml"
QT_MOC_LITERAL(2, 16, 0), // ""
QT_MOC_LITERAL(3, 17, 9), // "map_error"
QT_MOC_LITERAL(4, 27, 16), // "measure_distance"
QT_MOC_LITERAL(5, 44, 13), // "clicked_Point"
QT_MOC_LITERAL(6, 58, 3), // "lat"
QT_MOC_LITERAL(7, 62, 3), // "lng"
QT_MOC_LITERAL(8, 66, 13), // "measure_angle"
QT_MOC_LITERAL(9, 80, 14), // "marker_clicked"
QT_MOC_LITERAL(10, 95, 23), // "marker_position_changed"
QT_MOC_LITERAL(11, 119, 16), // "mapCenterChanged"
QT_MOC_LITERAL(12, 136, 18), // "deal_clicked_Point"
QT_MOC_LITERAL(13, 155, 19), // "deal_marker_clicked"
QT_MOC_LITERAL(14, 175, 28), // "deal_marker_position_changed"
QT_MOC_LITERAL(15, 204, 21) // "deal_mapCenterChanged"

    },
    "Wmap\0msgFromQml\0\0map_error\0measure_distance\0"
    "clicked_Point\0lat\0lng\0measure_angle\0"
    "marker_clicked\0marker_position_changed\0"
    "mapCenterChanged\0deal_clicked_Point\0"
    "deal_marker_clicked\0deal_marker_position_changed\0"
    "deal_mapCenterChanged"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Wmap[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      12,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       8,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   74,    2, 0x06 /* Public */,
       3,    1,   77,    2, 0x06 /* Public */,
       4,    1,   80,    2, 0x06 /* Public */,
       5,    2,   83,    2, 0x06 /* Public */,
       8,    1,   88,    2, 0x06 /* Public */,
       9,    3,   91,    2, 0x06 /* Public */,
      10,    3,   98,    2, 0x06 /* Public */,
      11,    2,  105,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      12,    2,  110,    2, 0x08 /* Private */,
      13,    3,  115,    2, 0x08 /* Private */,
      14,    3,  122,    2, 0x08 /* Private */,
      15,    2,  129,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, QMetaType::QString,    2,
    QMetaType::Void, QMetaType::QString,    2,
    QMetaType::Void, QMetaType::Double,    2,
    QMetaType::Void, QMetaType::Double, QMetaType::Double,    6,    7,
    QMetaType::Void, QMetaType::Double,    2,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::QString,    2,    2,    2,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::QString,    2,    2,    2,
    QMetaType::Void, QMetaType::Double, QMetaType::Double,    6,    7,

 // slots: parameters
    QMetaType::Void, QMetaType::Double, QMetaType::Double,    6,    7,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::QString,    6,    7,    2,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::QString,    6,    7,    2,
    QMetaType::Void, QMetaType::Double, QMetaType::Double,    6,    7,

       0        // eod
};

void Wmap::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Wmap *_t = static_cast<Wmap *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->msgFromQml((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 1: _t->map_error((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 2: _t->measure_distance((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 3: _t->clicked_Point((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2]))); break;
        case 4: _t->measure_angle((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 5: _t->marker_clicked((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 6: _t->marker_position_changed((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 7: _t->mapCenterChanged((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2]))); break;
        case 8: _t->deal_clicked_Point((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2]))); break;
        case 9: _t->deal_marker_clicked((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 10: _t->deal_marker_position_changed((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< QString(*)>(_a[3]))); break;
        case 11: _t->deal_mapCenterChanged((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            typedef void (Wmap::*_t)(QString );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::msgFromQml)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(QString );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::map_error)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(double );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::measure_distance)) {
                *result = 2;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(double , double );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::clicked_Point)) {
                *result = 3;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(double );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::measure_angle)) {
                *result = 4;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(double , double , QString );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::marker_clicked)) {
                *result = 5;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(double , double , QString );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::marker_position_changed)) {
                *result = 6;
                return;
            }
        }
        {
            typedef void (Wmap::*_t)(double , double );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&Wmap::mapCenterChanged)) {
                *result = 7;
                return;
            }
        }
    }
}

const QMetaObject Wmap::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_Wmap.data,
      qt_meta_data_Wmap,  qt_static_metacall, nullptr, nullptr}
};


const QMetaObject *Wmap::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Wmap::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_Wmap.stringdata0))
        return static_cast<void*>(this);
    return QWidget::qt_metacast(_clname);
}

int Wmap::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 12)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 12;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 12)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 12;
    }
    return _id;
}

// SIGNAL 0
void Wmap::msgFromQml(QString _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void Wmap::map_error(QString _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void Wmap::measure_distance(double _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void Wmap::clicked_Point(double _t1, double _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void Wmap::measure_angle(double _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void Wmap::marker_clicked(double _t1, double _t2, QString _t3)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void Wmap::marker_position_changed(double _t1, double _t2, QString _t3)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void Wmap::mapCenterChanged(double _t1, double _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 7, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
