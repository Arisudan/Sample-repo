import QtQuick
import QtQuick.Controls

Window {
    width: 1024
    height: 600
    visible: true
    title: "Media Player"
    color: "#121212"

    Column {
        anchors.centerIn: parent
        spacing: 20

        // Album Art
        Rectangle {
            width: 300; height: 300
            color: "#333"
            radius: 10
            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/album_placeholder.png"
            }
        }

        Text {
            text: "Blinding Lights"
            font.pixelSize: 24
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: "The Weeknd"
            font.pixelSize: 18
            color: "#888"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Controls
        Row {
            spacing: 40
            anchors.horizontalCenter: parent.horizontalCenter
            Button { text: "Prev" }
            Button { 
                text: "Play" 
                background: Rectangle { color: "#1DB954"; radius: 30 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Button { text: "Next" }
        }
    }
}
