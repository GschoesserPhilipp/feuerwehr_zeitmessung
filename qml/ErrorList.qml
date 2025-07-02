import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: errorListItem
    anchors.fill: parent


    ListModel {

        id: fehlerModel
        ListElement {
            name: "Frühstart 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Fallenlassen von Kupplungen je Stück 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Falsch abgelegte Reserveschläuche je Stück 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Liegengebliebenes oder verlorenes Gerät je Stück 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Schlecht ausgelegte Druckschläuche je Schlauch 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Schleifen ausgelegter Druckschläuche je Schlauch 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Unwirksam oder falsch angelegte Ventilleine 5s"
            value: 0
            time: 5
        }

        ListElement {
            name: "Falsche Endaufstellung je Fall 10s"
            value: 0
            time: 10
        }

        ListElement {
            name: "Falsches Arbeiten je Fall 10s"
            value: 0
            time: 10
        }

        ListElement {
            name: "Fehlerhafter oder nicht verständlicher Befehl je Fall 10s"
            value: 0
            time: 10
        }

        ListElement {
            name: "Nicht vorschriftsmäßig geöffnete Druckausgänge je Fall 10s"
            value: 0
            time: 10
        }

        ListElement {
            name: "Sprechen während der Arbeit je Fall 10s"
            value: 0
            time: 10
        }

        ListElement {
            name: "Unwirksam angelegte Saugschlauchleine 10s"
            value: 0
            time: 10
        }

        ListElement {
            name: "Offenes Kupplungspaar je Paar 20s"
            value: 0
            time: 20
        }

        ListElement {
            name: "Weglaufen von WTR bzw STR vor Angesaugt 20s"
            value: 0
            time: 20
        }

        ListElement {
            name: "5s"
            value: 0
            time: 0
        }
    }



    Image {
        id: image
        anchors.fill: parent
        source: "images/fire.png"
        fillMode: Image.PreserveAspectFit
        opacity: imageOpacity
    }

    Popup {
        id: pickerPopup
        modal: true
        focus: true
        width: 150
        height: 250
        anchors.centerIn: parent
        // Diese Properties sind NUR innerhalb pickerPopup gültig
        property int selectedValue: 1
        property int targetIndex: -1

        Column {
            anchors.centerIn: parent
            spacing: 10

            Rectangle {
                width: parent.width
                height: 150
                color: "transparent"
                clip: true

                ListView {
                    id: numberWheel
                    width: parent.width
                    height: parent.height
                    model: 6
                    orientation: ListView.Vertical
                    snapMode: ListView.SnapToItem
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    preferredHighlightBegin: height / 2 - 20
                    preferredHighlightEnd: height / 2 + 20

                    delegate: Item {
                        width: numberWheel.width
                        height: 40
                        Text {
                            text: index + 1
                            anchors.centerIn: parent
                            font.pixelSize: 20
                            color: numberWheel.currentIndex === index ? "black" : "gray"
                        }
                    }

                    onCurrentIndexChanged: pickerPopup.selectedValue = currentIndex + 1
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    y: numberWheel.height / 2 - 20
                    color: "#cccccc88"
                    border.color: "#999"
                    radius: 4
                }
            }

            Button {
                text: "Übernehmen"
                onClicked: {
                    if (pickerPopup.targetIndex >= 0) {
                        fehlerModel.setProperty(pickerPopup.targetIndex, "value", pickerPopup.selectedValue)
                        pickerPopup.close()
                        pickerPopup.selectedValue = 0
                        pickerPopup.targetIndex = 0
                        numberWheel.currentIndex = 0

                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15


        ListView {
            id: errorView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: fehlerModel
            clip: true
            spacing: 5
            delegate:
                Rectangle {
                width: parent.width
                height: 60
                color: index % 2 === 0 ? "#4a4a4a" : "#707070"
                opacity: 0.6
                radius: 7


                Text {
                    text: name + (value > 0 ? " (Wert: " + value + ")" : "")
                    color: "#ffffff"
                    anchors.centerIn: parent
                    font.pointSize: 12
                }


                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pickerPopup.targetIndex = index
                        pickerPopup.selectedValue = value > 0 ? value : 1
                        pickerPopup.open()
                    }
                }
            }


        }

        Popup {
            id: save_popup
            width: 300
            height: 100
            anchors.centerIn: parent

            contentItem: Text {
                text: "<font color='white'>Werte Erfolgreich gespeichert</font>"
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 18
                font.bold: true
            }
        }

        Timer {
            id: save_timer
            interval: 2000
            repeat: false
            onTriggered: save_popup.close()
        }


        Button {
            id: saveButton
            text: "Speichern"
            Layout.fillWidth: true
            height: 60
            onClicked: {
                var errors = 0;
                for (var i = 0; i < fehlerModel.count; ++i) {
                    errors += fehlerModel.get(i).value;
                    fehlerModel.setProperty(i, "value", 0);
                }
                dbHandler.saveDataToDb(globalElapsedMs, globalGroupName, errors)
                save_popup.open()
                save_timer.start()
            }
        }

        Button {
            id: clearButton
            text: "Clear"
            Layout.fillWidth: true
            height: 60
            onClicked: {
                for (var i = 0; i < fehlerModel.count; i++) {
                    fehlerModel.setProperty(i, "value", 0);
                }
            }
        }
    }

}
