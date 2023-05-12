/****************************************************************************
** Meta object code from reading C++ file 'qiec104.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "qiec104.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qiec104.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_QIec104_t {
    QByteArrayData data[18];
    char stringdata0[329];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_QIec104_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_QIec104_t qt_meta_stringdata_QIec104 = {
    {
QT_MOC_LITERAL(0, 0, 7), // "QIec104"
QT_MOC_LITERAL(1, 8, 21), // "signal_dataIndication"
QT_MOC_LITERAL(2, 30, 0), // ""
QT_MOC_LITERAL(3, 31, 8), // "iec_obj*"
QT_MOC_LITERAL(4, 40, 3), // "obj"
QT_MOC_LITERAL(5, 44, 9), // "numpoints"
QT_MOC_LITERAL(6, 54, 37), // "signal_interrogationActConfIn..."
QT_MOC_LITERAL(7, 92, 37), // "signal_interrogationActTermIn..."
QT_MOC_LITERAL(8, 130, 18), // "signal_tcp_connect"
QT_MOC_LITERAL(9, 149, 21), // "signal_tcp_disconnect"
QT_MOC_LITERAL(10, 171, 31), // "signal_commandActRespIndication"
QT_MOC_LITERAL(11, 203, 18), // "slot_tcpdisconnect"
QT_MOC_LITERAL(12, 222, 15), // "slot_tcpconnect"
QT_MOC_LITERAL(13, 238, 19), // "slot_tcpreadytoread"
QT_MOC_LITERAL(14, 258, 13), // "slot_tcperror"
QT_MOC_LITERAL(15, 272, 28), // "QAbstractSocket::SocketError"
QT_MOC_LITERAL(16, 301, 11), // "socketError"
QT_MOC_LITERAL(17, 313, 15) // "slot_keep_alive"

    },
    "QIec104\0signal_dataIndication\0\0iec_obj*\0"
    "obj\0numpoints\0signal_interrogationActConfIndication\0"
    "signal_interrogationActTermIndication\0"
    "signal_tcp_connect\0signal_tcp_disconnect\0"
    "signal_commandActRespIndication\0"
    "slot_tcpdisconnect\0slot_tcpconnect\0"
    "slot_tcpreadytoread\0slot_tcperror\0"
    "QAbstractSocket::SocketError\0socketError\0"
    "slot_keep_alive"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_QIec104[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      11,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       6,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    2,   69,    2, 0x06 /* Public */,
       6,    0,   74,    2, 0x06 /* Public */,
       7,    0,   75,    2, 0x06 /* Public */,
       8,    0,   76,    2, 0x06 /* Public */,
       9,    0,   77,    2, 0x06 /* Public */,
      10,    1,   78,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      11,    0,   81,    2, 0x0a /* Public */,
      12,    0,   82,    2, 0x08 /* Private */,
      13,    0,   83,    2, 0x08 /* Private */,
      14,    1,   84,    2, 0x08 /* Private */,
      17,    0,   87,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3, QMetaType::UInt,    4,    5,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 3,    4,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 15,   16,
    QMetaType::Void,

       0        // eod
};

void QIec104::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<QIec104 *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->signal_dataIndication((*reinterpret_cast< iec_obj*(*)>(_a[1])),(*reinterpret_cast< uint(*)>(_a[2]))); break;
        case 1: _t->signal_interrogationActConfIndication(); break;
        case 2: _t->signal_interrogationActTermIndication(); break;
        case 3: _t->signal_tcp_connect(); break;
        case 4: _t->signal_tcp_disconnect(); break;
        case 5: _t->signal_commandActRespIndication((*reinterpret_cast< iec_obj*(*)>(_a[1]))); break;
        case 6: _t->slot_tcpdisconnect(); break;
        case 7: _t->slot_tcpconnect(); break;
        case 8: _t->slot_tcpreadytoread(); break;
        case 9: _t->slot_tcperror((*reinterpret_cast< QAbstractSocket::SocketError(*)>(_a[1]))); break;
        case 10: _t->slot_keep_alive(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 9:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QAbstractSocket::SocketError >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (QIec104::*)(iec_obj * , unsigned  );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QIec104::signal_dataIndication)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (QIec104::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QIec104::signal_interrogationActConfIndication)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (QIec104::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QIec104::signal_interrogationActTermIndication)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (QIec104::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QIec104::signal_tcp_connect)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (QIec104::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QIec104::signal_tcp_disconnect)) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (QIec104::*)(iec_obj * );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QIec104::signal_commandActRespIndication)) {
                *result = 5;
                return;
            }
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject QIec104::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_QIec104.data,
    qt_meta_data_QIec104,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *QIec104::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *QIec104::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_QIec104.stringdata0))
        return static_cast<void*>(this);
    if (!strcmp(_clname, "iec104_class"))
        return static_cast< iec104_class*>(this);
    return QObject::qt_metacast(_clname);
}

int QIec104::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
    return _id;
}

// SIGNAL 0
void QIec104::signal_dataIndication(iec_obj * _t1, unsigned  _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void QIec104::signal_interrogationActConfIndication()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void QIec104::signal_interrogationActTermIndication()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void QIec104::signal_tcp_connect()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void QIec104::signal_tcp_disconnect()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void QIec104::signal_commandActRespIndication(iec_obj * _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
