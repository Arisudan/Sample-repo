import QtQuick
import QtQuick.Window
import "components"
import "themes"

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "ASTER Premium Cluster"
    color: "#05070A" // Very dark blue/black background from image

    ClusterTheme { id: theme }

    // Background Gradient (Vignette)
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 0.5; color: "#06101A" }
            GradientStop { position: 1.0; color: "#000000" }
        }
    }

    // Top Bar (Weather, Brand, Time)
    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        z: 10
    }

    // Main Content Area
    Item {
        anchors.centerIn: parent
        width: 1100; height: 450
        
        // Center Stack Lines (Top and Bottom Blue Glow Lines from Image)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            width: 400; height: 2
            color: "#004488"
        }
         Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            width: 400; height: 2
            color: "#004488"
        }

        Row {
            anchors.centerIn: parent
            spacing: -20 // Gauges overlap the center stack slightly or sit tight

            // Left: RPM Gauge
            RpmGauge {
                width: 420; height: 420
                value: clusterClient.engineRpm
                maxValue: 8000
            }

            // Center Display (Map/Car)
            Item {
                width: 320; height: 350
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                
                NavigationView {
                    anchors.fill: parent
                    visible: clusterClient.navActive
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 500 } }
                }

                CarIllustration {
                    anchors.fill: parent
                    visible: !clusterClient.navActive
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 500 } }
                }
            }

            // Right: Speed Gauge
            SpeedGauge {
                width: 420; height: 420
                value: clusterClient.vehicleSpeed
                maxValue: 260
            }
        }
    }
    
    // Bottom Warning Icons
    WarningIcons {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    // Hidden Gear Indicator (Reference image doesn't show large vertical strip, likely subtle or integrated)
    // But requirement says "Vertical P R N D left". Keeping it but subtle.
    GearIndicator {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        scale: 0.8
        opacity: 0.6
    }
}
