import QtQuick
import QtQuick.Layouts

Item {
    height: 80
    width: parent.width
    
    // Background gradient mask
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#aa000000" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    // Left: Weather + Temp
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.verticalCenter: parent.verticalCenter
        spacing: 15
        Text {
            text: clusterClient.coolantTemp > 100 ? "Use Caution" : "Fair" 
            color: "#aaaaaa"
            font.pixelSize: 18
        }
        Text {
            text: Math.round(clusterClient.coolantTemp/4) + "°C" // Mock temp mapping
            color: "white"
            font.pixelSize: 22
            font.bold: true
        }
        Text { text: "☁️"; font.pixelSize: 24 }
    }

    // Center: Logo
    Item {
        anchors.centerIn: parent
        width: 100
        height: 60
        Rectangle {
            anchors.centerIn: parent
            width: 80; height: 30
            radius: 15
            color: "#1a1a1a"
            border.color: "#333"
            Text {
                anchors.centerIn: parent
                text: "ASTER"
                color: "#00aaff"
                font.bold: true
                font.letterSpacing: 2
                font.pixelSize: 14
            }
        }
    }

    // Right: Time
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatTime(new Date(), "hh:mm")
        color: "white"
        font.pixelSize: 24
        font.bold: true
    }
}
