import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle {
    id: list_rect
    anchors.fill: parent
    color: "transparent"

    property alias connectedText: connectedText

    Rectangle {
        id: rectangle1
        y: 118
        height: 149
        color: "#4a4a4a"
        radius: 7
        opacity: 0.7
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.leftMargin: 18

        Column {
            id: column1
            anchors.fill: parent
            topPadding: 19
            spacing: 23

            Text {
                id: connectedText
                text: qsTr("Verbunden mit:")
                anchors.left: parent.left
                font.pixelSize: 15
                height: 40
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: 16
            }

            Button {
                id: disconnectButton
                text: qsTr("Trennen")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                implicitHeight: 50
                onClicked: bleHandler.disconnectFromDevice()
            }
        }
    }


    Rectangle {
        id: buttonContainer
        opacity: 0.7
        color: "#4a4a4a"
        radius: 7
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: rectangle1.bottom
        anchors.bottomMargin: 10
        anchors.topMargin: 18
        anchors.rightMargin: 18
        anchors.leftMargin: 18

        RowLayout {
            id: row
            y: 0
            height: 58
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            spacing: 10

            Button {
                id: scanButton
                text: qsTr("Start Scanning")
                implicitHeight: 50
                Layout.fillWidth: true
                onClicked: {
                    console.log("Start scanning clicked")
                    if (permission.status === Qt.PermissionStatus.Undetermined) {
                        console.log("Requesting permission")
                        permission.request()
                    } else if (permission.status === Qt.PermissionStatus.Granted) {
                        console.log("Starting scan...")
                        bleHandler.startScan()
                        busyIndicator.running = true;
                    } else {
                        console.log("Bluetooth permission denied")
                        Device.update = "Bluetooth permission denied"
                    }
                }
            }

            Button {
                id: stopButton
                text: qsTr("Stop Scanning")
                implicitHeight: 50
                Layout.fillWidth: true
                onClicked: {
                    bleHandler.stopScan()
                    busyIndicator.running = false;
                }
            }
        }

        ListView {
            id: deviceList
            y: 100
            anchors.left: parent.left
            anchors.right: parent.right
            model: bleHandler.devicesList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            anchors.top: row.bottom
            anchors.bottom: parent.bottom


            delegate: Rectangle {
                width: deviceList.width
                height: 50
                color: index % 2 === 0 ? "#4a4a4a" : "#707070"
                opacity: 0.6

                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        text: modelData.name
                        color: "#ffffff"
                    }
                    Text {
                        text: modelData.address
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Verbinde mit:", modelData.address)
                        bleHandler.connectToDevice(modelData.address)
                        busyIndicator.running = false;
                        connectedText.text = "Connected to: " + modelData.name
                    }
                }
            }
        }

        BusyIndicator {
            id: busyIndicator
            x: 254
            width: 170
            height: 118
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            running: false
            z: -1
        }
    }

    // ListView für die Geräte

    // Bild (optional)
    Image {
        id: image
        x: 18
        y: 12
        width: 100
        height: 100
        source: "images/fire.png"
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        anchors.fill: parent
        opacity: imageOpacity
        z: -1
    }

    // Text oberhalb des Layouts
    Text {
        id: text1
        y: 12
        width: 310
        height: 100
        color: "#ffffff"
        text: qsTr("Feuerwehr Zeitmessung")
        font.pixelSize: 25
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
