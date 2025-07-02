import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: counter_rect
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    color: "transparent"

    function updateValue(value) {

        var minutes = Math.floor(value / 60000);
        var seconds = Math.floor((value % 60000) / 1000);
        var centiseconds = Math.floor((value % 1000) / 10);
        timeDisplay.text = minutes + ":" + (seconds < 10 ? "0" + seconds : seconds) + ":" + (centiseconds < 10 ? "0" + centiseconds : centiseconds);
    }


    Image {
        id: fireImage
        source: "images/fire.png"
        anchors.bottomMargin: 200
        anchors.centerIn: parent
        anchors.fill: parent
        opacity: imageOpacity
    }

    SoundEffect {
        id: startSound
        source: Qt.resolvedUrl("sound/angriffsbefehl.wav")
        onPlayingChanged: {
            if (!playing) {
                bleHandler.sendBool();
            }
        }
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
                    anchors.verticalCenter: parent.verticalCenter  // Standardtext
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
                displayText: "Gruppe auswählen"
            }

            Rectangle {
                Layout.rightMargin: 31
                height: 50
                width: 50
                radius: 100
                color: "transparent"
                border.color: "white"
                Image {
                    source: "images/add_group.svg"
                    height: 30
                    width: 30
                    anchors.centerIn: parent

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("add new group")
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
                if (startSound.status === SoundEffect.Ready) {
                    startSound.play();
                } else {
                    console.warn("Sound not ready");
                }
            }
        }
    }

}

