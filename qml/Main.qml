import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCore
import feuerwehr_zeitmessung 1.0
import QtQuick.Controls.Material

ApplicationWindow {
    visible: true
    width: 460
    height: 740
    title: qsTr("Bluetooth LE Scanner")

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    property int globalElapsedMs: 0
    property real imageOpacity: 0.2
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

        onCurrentIndexChanged: {
               if (currentIndex === 1) { // Index der Counter-Seite
                   bleHandler.requestGroups()
               }
           }

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
            icon.source: "qrc:/feuerwehr_zeitmessung/images/connect.svg"
            icon.color: "white"
        }
        TabButton {

            icon.source: "qrc:/feuerwehr_zeitmessung/images/timer.svg"
            icon.color: "white"
        }

        TabButton {

            icon.source: "qrc:/feuerwehr_zeitmessung/images/error_list.svg"
            icon.color: "white"
        }

        TabButton {

            icon.source: "qrc:/feuerwehr_zeitmessung/images/list.svg"
            icon.color: "white"
        }

    }

}
