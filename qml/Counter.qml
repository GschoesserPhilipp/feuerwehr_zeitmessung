import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: counter_rect
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    color: "transparent"

    property var groupList: []

    function updateValue(value) {

        var minutes = Math.floor(value / 60000);
        var seconds = Math.floor((value % 60000) / 1000);
        var centiseconds = Math.floor((value % 1000) / 10);
        timeDisplay.text = minutes + ":" + (seconds < 10 ? "0" + seconds : seconds) + ":" + (centiseconds < 10 ? "0" + centiseconds : centiseconds);
    }

    Popup {
        id: addGroupPopup
        modal: true
        focus: true
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: 300
        height: 250
        background: Rectangle {
            color: "#333"
            radius: 10
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Text {
                text: "Neue Gruppe hinzufügen"
                font.pixelSize: 18
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: newGroupName
                placeholderText: "Gruppenname eingeben"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "Abbrechen"
                    onClicked: {
                        newGroupName.clear();
                        addGroupPopup.close()
                    }
                }

                Button {
                    text: "Hinzufügen"
                    enabled: newGroupName.text.length > 0
                    onClicked: {
                        if (groupBox.model.indexOf(newGroupName.text) !== -1) {
                            messageDialog.title = "Fehler"
                            messageDialog.text = "Die Gruppe existiert bereits!"
                            messageDialog.open()
                        } else {
                            bleHandler.writeGroupName(newGroupName.text)

                            messageDialog.title = "Meldung"
                            messageDialog.text = "Gruppe hinzugefügt: " + newGroupName.text
                            messageDialog.open()

                            newGroupName.clear()
                            addGroupPopup.close()
                        }
                    }
                }
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: ""
        text: ""

    }


    Image {
        id: fireImage
        source: "qrc:/feuerwehr_zeitmessung/images/fire.png"
        anchors.bottomMargin: 200
        anchors.centerIn: parent
        anchors.fill: parent
        opacity: imageOpacity
    }


    ColumnLayout {

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 10
        anchors.bottomMargin: 22
        anchors.rightMargin: 10
        anchors.leftMargin: 10


        Rectangle {
            id: rectangle1
            width: 320
            height: 320
            color:"#2d2d2d"
            radius: 200
            Layout.topMargin: 127
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            opacity: 0.7

            Rectangle {
                id: rectangle2
                color:"#4d4d4d"
                radius: 200
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 10
                opacity: 0.7

                Text {
                    id: timeDisplay
                    x: 31
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 60
                    z: 1
                    anchors.horizontalCenterOffset: 0
                    color: "#ffffff"
                    text: "00:00:00"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }


        RowLayout{

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 30
            height: 50
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            ComboBox {
                id:groupBox
                implicitHeight: 50
                Layout.fillWidth: true
                displayText: currentIndex === -1 ? "Gruppe wählen" : currentText
                model: groupList
                onActivated: function(index) {
                    groupBox.currentIndex = index;
                }
                onPressedChanged: if (pressed) {

                                      bleHandler.requestGroups()
                                  }
            }

            Rectangle {
                Layout.rightMargin: 31
                height: 50
                width: 50
                radius: 100
                color: "transparent"
                border.color: "white"
                Image {
                    source: "qrc:/feuerwehr_zeitmessung/images/add_group.svg"
                    height: 30
                    width: 30
                    anchors.centerIn: parent

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addGroupPopup.open()
                    }
                }
            }
        }

        Button {
            id: startButton
            text: qsTr("Start")
            Layout.fillWidth: true
            implicitHeight: 100

            onClicked: {
                bleHandler.sendBool();

            }
        }
    }

    Connections {
        target: bleHandler
        onGroupsReceived: function(value) {
            console.log("Gruppen empfangen:", value)

            var parsed = JSON.parse(value);
            if (parsed && parsed.groups) {
                groupList = parsed.groups;
                console.log("Parsed Gruppen:", groupList);
            } else {
                console.log("Ungültiges JSON oder kein groups-Feld");
                groupList = [];
            }
        }
    }

}
