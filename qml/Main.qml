import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCore
import Ble 1.0
import QtQuick.Controls.Material

ApplicationWindow {
    visible: true
    width: 460 //Screen.width
    height: 740 //Screen.height
    title: qsTr("Bluetooth LE Scanner")

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    property string globalGroupName: ""
    property int globalElapsedMs: 0
    property var imageOpacity: 0.2
    property bool connected: false


    // === BLE Permission Handling ===
    BluetoothPermission {
        id: permission
        communicationModes: BluetoothPermission.Access

        onStatusChanged: {
            if (status === Qt.PermissionStatus.Denied) {
                console.log("Bluetooth permission required")
            }
        }
    }

    BleHandler {
        id: bleHandler
        onValueReceived:  {
            console.log(value)
            counter_rect.updateValue(value);
            globalElapsedMs = value;
        }

        onConnected: {
            console.log("Erfolgreich verbunden!")
            deviceList.connectedText.text = "Connected to: " + selectedDeviceName
        }

        onDisconnected: {
            deviceList.connectedText.text = "Disconnected"
        }

    }


    SwipeView {
        id: swipeView
        width: parent.width
        height: parent.height
        currentIndex: tabBar.currentIndex


        Item {
            width: swipeView.width
            height: swipeView.height
            DeviceList {
                id: deviceList
                width: parent.width
                height: parent.height
                anchors.top: parent.top
            }
        }

        Item {
            width: swipeView.width
            height: swipeView.height
            Counter {
                id: counter_rect
                width: parent.width
            }

        }

        Item {
            width: swipeView.width
            height: swipeView.height
            ErrorList {
            }

        }

        Item {
            width: swipeView.width
            height: swipeView.height
            History {
            }
        }

    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            icon.source: "images/connect.svg"
            icon.color: "white"
        }
        TabButton {

            icon.source: "images/timer.svg"
            icon.color: "white"
        }

        TabButton {

            icon.source: "images/error_list.svg"
            icon.color: "white"
        }

        TabButton {

            icon.source: "images/list.svg"
            icon.color: "white"
        }

    }

}
