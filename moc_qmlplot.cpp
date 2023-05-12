/****************************************************************************
** Meta object code from reading C++ file 'qmlplot.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "qmlplot.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qmlplot.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_CustomPlotItem_t {
    QByteArrayData data[8];
    char stringdata0[112];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_CustomPlotItem_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_CustomPlotItem_t qt_meta_stringdata_CustomPlotItem = {
    {
QT_MOC_LITERAL(0, 0, 14), // "CustomPlotItem"
QT_MOC_LITERAL(1, 15, 12), // "graphClicked"
QT_MOC_LITERAL(2, 28, 0), // ""
QT_MOC_LITERAL(3, 29, 21), // "QCPAbstractPlottable*"
QT_MOC_LITERAL(4, 51, 9), // "plottable"
QT_MOC_LITERAL(5, 61, 14), // "onCustomReplot"
QT_MOC_LITERAL(6, 76, 20), // "updateCustomPlotSize"
QT_MOC_LITERAL(7, 97, 14) // "initCustomPlot"

    },
    "CustomPlotItem\0graphClicked\0\0"
    "QCPAbstractPlottable*\0plottable\0"
    "onCustomReplot\0updateCustomPlotSize\0"
    "initCustomPlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_CustomPlotItem[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   34,    2, 0x08 /* Private */,
       5,    0,   37,    2, 0x08 /* Private */,
       6,    0,   38,    2, 0x08 /* Private */,

 // methods: name, argc, parameters, tag, flags
       7,    0,   39,    2, 0x02 /* Public */,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void,

       0        // eod
};

void CustomPlotItem::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<CustomPlotItem *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->graphClicked((*reinterpret_cast< QCPAbstractPlottable*(*)>(_a[1]))); break;
        case 1: _t->onCustomReplot(); break;
        case 2: _t->updateCustomPlotSize(); break;
        case 3: _t->initCustomPlot(); break;
        default: ;
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject CustomPlotItem::staticMetaObject = { {
    QMetaObject::SuperData::link<QQuickPaintedItem::staticMetaObject>(),
    qt_meta_stringdata_CustomPlotItem.data,
    qt_meta_data_CustomPlotItem,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *CustomPlotItem::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *CustomPlotItem::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CustomPlotItem.stringdata0))
        return static_cast<void*>(this);
    return QQuickPaintedItem::qt_metacast(_clname);
}

int CustomPlotItem::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QQuickPaintedItem::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 4)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 4;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
