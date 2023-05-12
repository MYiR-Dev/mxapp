import QtQuick 2.7
import QtQuick.Window 2.2
import ChargeManage 1.0
import Charge104 1.0
import QtQuick.Controls 2.0

Popup {
    id: charge_Wd
    modal: false
    padding: 0
    margins: 0
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    width: mainWnd.width
    height: mainWnd.height

    property int server_open_flag: 0//服务器是否打开
    property int client_connect_server_flag: 0//客户端是否连接成功
    property int client_connect_flag: 0//客户端是否需要连接服务端

    Loader{
        id:home_screen
        visible: true
        anchors.fill: parent
        property var first_sign_flag: 0
        property var sign_flag: 0
        property var amount: 0
        source: "qrc:/WinHomeScreen.qml"
    }

    Loader{
        id:recharge_select
        visible: false
        anchors.fill: parent
        source: "qrc:/WinRechargeSelect.qml"
        property var recharge_num: 0
        Connections{
            target: recharge_select.item
            onRecharge_amount:{
                recharge_select.recharge_num=value
            }
        }
    }

    Loader{
        id:pay_interface
        visible: false
        anchors.fill: parent
        source: "qrc:/WinPayInterface.qml"
    }

    Loader{
        id:charge_scheme
        visible: false
        anchors.fill: parent
        source: "qrc:/WinChargeScheme.qml"
        property var fee_flag: 0
        property var time_flag: 0
        property var choose_scheme: 0
        property var choose_fee: 0
        property var quick_flag: 0
    }
    Loader{
        id:charge_monitor
        visible: false
        anchors.fill: parent
        source: "qrc:/WinChargeMonitor.qml"
    }

    Loader{
        id:close_account
        visible: false
        anchors.fill: parent
        source: "qrc:/WinCloseAccount.qml"
        property var actual_time: 0
        property var electricity: 0
        property var charge_fee: 0
        property var service_fee: 0
        property var total_fee: 0
        Connections{
            target: charge_monitor.item
            onCloseAccount:{
                close_account.actual_time=charge_time
                close_account.electricity=electricity
                close_account.charge_fee=charge_fee
                close_account.service_fee=service_fee
                close_account.total_fee=total_fee
            }
        }
    }
}
