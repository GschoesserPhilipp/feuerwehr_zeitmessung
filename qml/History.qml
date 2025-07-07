import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
anchors.fill: parent

ListModel {
       id: errorModel
       ListElement {
           zeitstempel: "2025-07-03 14:23:10"
           zeit: "14:23"
           gruppenname: "Gruppe 1"
           fehleranzahl: 3
       }
       ListElement {
           zeitstempel: "2025-07-03 13:10:55"
           zeit: "13:10"
           gruppenname: "Gruppe 1"
           fehleranzahl: 1
       }
       ListElement {
           zeitstempel: "2025-07-02 09:05:30"
           zeit: "09:05"
           gruppenname: "Gruppe 1"
           fehleranzahl: 2
       }
   }

ListView {
    anchors.fill: parent
    model: errorModel
    delegate: Rectangle {
        width: ListView.view.width
        height: 80
        color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"
        border.color: "#cccccc"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 16

            ColumnLayout {
                Layout.preferredWidth: 250
                spacing: 4

                Text {
                    text: zeitstempel
                    font.bold: true
                    font.pointSize: 14
                    color: "#000000"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 100
                spacing: 4

                Text {
                    text: "Zeit: " + zeit
                    font.pointSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: "Gruppe: " + gruppenname
                    font.pointSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: "Anzahl: " + fehleranzahl
                    font.pointSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}

}
