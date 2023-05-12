/****************************************************************************
** Meta object code from reading C++ file 'ChargeManage.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "ChargeManage.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ChargeManage.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_my_thread_t {
    QByteArrayData data[1];
    char stringdata0[10];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_my_thread_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_my_thread_t qt_meta_stringdata_my_thread = {
    {
QT_MOC_LITERAL(0, 0, 9) // "my_thread"

    },
    "my_thread"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_my_thread[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

void my_thread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}

QT_INIT_METAOBJECT const QMetaObject my_thread::staticMetaObject = { {
    QMetaObject::SuperData::link<QThread::staticMetaObject>(),
    qt_meta_stringdata_my_thread.data,
    qt_meta_data_my_thread,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *my_thread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *my_thread::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_my_thread.stringdata0))
        return static_cast<void*>(this);
    return QThread::qt_metacast(_clname);
}

int my_thread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
    return _id;
}
struct qt_meta_stringdata_ChargeManage_t {
    QByteArrayData data[8];
    char stringdata0[143];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_ChargeManage_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_ChargeManage_t qt_meta_stringdata_ChargeManage = {
    {
QT_MOC_LITERAL(0, 0, 12), // "ChargeManage"
QT_MOC_LITERAL(1, 13, 29), // "start_quick_total_electricity"
QT_MOC_LITERAL(2, 43, 28), // "start_slow_total_electricity"
QT_MOC_LITERAL(3, 72, 22), // "stop_total_electricity"
QT_MOC_LITERAL(4, 95, 17), // "total_electricity"
QT_MOC_LITERAL(5, 113, 13), // "power_factory"
QT_MOC_LITERAL(6, 127, 7), // "voltage"
QT_MOC_LITERAL(7, 135, 7) // "current"

    },
    "ChargeManage\0start_quick_total_electricity\0"
    "start_slow_total_electricity\0"
    "stop_total_electricity\0total_electricity\0"
    "power_factory\0voltage\0current"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_ChargeManage[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       7,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // properties: name, type, flags
       1, QMetaType::Float, 0x00095001,
       2, QMetaType::Float, 0x00095001,
       3, QMetaType::Float, 0x00095001,
       4, QMetaType::Float, 0x00095001,
       5, QMetaType::Float, 0x00095001,
       6, QMetaType::Float, 0x00095001,
       7, QMetaType::Float, 0x00095001,

       0        // eod
};

void ChargeManage::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{

#ifndef QT_NO_PROPERTIES
    if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<ChargeManage *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< float*>(_v) = _t->start_quick_charging(); break;
        case 1: *reinterpret_cast< float*>(_v) = _t->start_slow_charging(); break;
        case 2: *reinterpret_cast< float*>(_v) = _t->stop_charging(); break;
        case 3: *reinterpret_cast< float*>(_v) = _t->get_total_electricity(); break;
        case 4: *reinterpret_cast< float*>(_v) = _t->get_power_factory(); break;
        case 5: *reinterpret_cast< float*>(_v) = _t->get_voltage(); break;
        case 6: *reinterpret_cast< float*>(_v) = _t->get_current(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}

QT_INIT_METAOBJECT const QMetaObject ChargeManage::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ChargeManage.data,
    qt_meta_data_ChargeManage,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *ChargeManage::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ChargeManage::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ChargeManage.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ChargeManage::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    
#ifndef QT_NO_PROPERTIES
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 7;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 7;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 7;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 7;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 7;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 7;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
