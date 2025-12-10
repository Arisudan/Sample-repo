import QtQuick
import QtQuick.Controls

Window {
    width: 1280
    height: 720
    visible: true
    title: "Cluster UI"
    color: "black"

    Dashboard {
        id: dashboard
        anchors.fill: parent
        speed: carData.speed
        rpm: carData.rpm
        gear: carData.gear
    }

    // Overlay for indicators
    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20
        anchors.topMargin: 20

        Image { source: "qrc:/icons/battery.png"; width: 32; height: 32; visible: true }
        // ... more icons
    }
}
