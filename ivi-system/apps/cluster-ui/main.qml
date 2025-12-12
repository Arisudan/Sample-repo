import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "components"

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "ASTER Cluster"
    color: "black"

    // Backend Bindings
    property real speedVal: carData ? carData.speed : 0
    property real rpmVal: carData ? carData.rpm : 0
    property int gearVal: carData ? carData.gear : 0
    property double fuelLevel: carData ? carData.fuel : 50 // %
    property double tempLevel: carData ? carData.temp : 90 // C

    // Top Bar
    Item {
        id: topBar
        width: parent.width
        height: 80
        anchors.top: parent.top
        z: 10
        
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#111" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Left: Weather 
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15
            Text { text: "☁️"; font.pixelSize: 32; color: "white" }
            Text { text: Math.round(tempLevel/10 + 3) + " °C"; font.pixelSize: 28; color: "white"; font.bold: true; font.family: "Eurostile" }
        }

        // Center: BRANDING "ASTER"
        Item {
            anchors.centerIn: parent
            width: 80; height: 80
            Rectangle {
                anchors.fill: parent
                radius: width/2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333" }
                    GradientStop { position: 1.0; color: "#000" }
                }
                border.color: "#666"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "ASTER"
                    color: "white"
                    font.bold: true
                    font.font.family: "Eurostile"
                    font.pixelSize: 14 
                }
            }
             MultiEffect {
                source: parent
                anchors.fill: parent
                shadowEnabled: true
                shadowColor: "#00aaff"
                shadowBlur: 0.5
            }
        }

        // Right: Time 
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(new Date(), "hh:mm")
            color: "white"
            font.pixelSize: 28
            font.bold: true
            font.family: "Eurostile"
        }
    }

    // MAIN CONTENT
    Row {
        anchors.centerIn: parent
        spacing: 40

        // LEFT SIDE: RPM + TEMP
        Column {
            spacing: 10
            RpmGauge {
                width: 450; height: 450 
                value: rpmVal
                maxValue: 8000
            }
            // Temp Bar
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Text { text: "C"; color: "white"; font.bold: true }
                ProgressBar {
                    width: 300
                    value: (tempLevel - 50) / 100 // 50 to 150 C range
                    background: Rectangle { color: "#333"; radius: 5; height: 8 }
                    contentItem: Item {
                        Rectangle {
                            width: parent.width * parent.value
                            height: 8
                            radius: 5
                            color: value > 0.8 ? "red" : "#00aaff"
                        }
                    }
                }
                Text { text: "H"; color: "white"; font.bold: true }
            }
        }

        // CENTER: MAP + CAR
        NavigationDisplay {
            width: 250
            height: 250
            anchors.verticalCenter: parent.verticalCenter
        }

        // RIGHT SIDE: SPEED + FUEL
        Column {
            spacing: 10
            Speedometer {
                width: 450; height: 450
                value: speedVal
                maxValue: 260
            }
            // Fuel Bar
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Text { text: "E"; color: "white"; font.bold: true }
                ProgressBar {
                    width: 300
                    value: fuelLevel / 100
                    background: Rectangle { color: "#333"; radius: 5; height: 8 }
                    contentItem: Item {
                        Rectangle {
                            width: parent.width * parent.value
                            height: 8
                            radius: 5
                            color: value < 0.2 ? "red" : "#00ff00"
                        }
                    }
                }
                Text { text: "F"; color: "white"; font.bold: true }
            }
        }
    }

    // Gear Indicator (Vertical Left)
    GearIndicator {
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
    }

    // Bottom Bar (Icon Array & Arrows)
    WarningIcons {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
