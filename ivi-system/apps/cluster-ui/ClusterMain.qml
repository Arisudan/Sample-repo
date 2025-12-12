import QtQuick
import QtQuick.Controls
import "components"
import "themes"

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "ASTER Premium Cluster"
    color: "#000000" // Deep black

    ClusterTheme { id: theme }

    // Top Bar
    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        z: 10
    }

    // Main Content Area
    Row {
        anchors.centerIn: parent
        spacing: 60
        
        // LEFT: RPM Gauge & Gear
        Item {
            width: 450; height: 450
            
            RpmGauge {
                id: rpmGauge
                anchors.centerIn: parent
                value: clusterClient.engineRpm
                maxValue: 8000
            }
            
            // Integrated Gear Indicator (Left of RPM or inside? Design showed distinct left stack)
            GearIndicator {
                anchors.left: parent.left
                anchors.leftMargin: -100 // Shifted to far left of screen relative to this group
                anchors.verticalCenter: parent.verticalCenter
                currentGear: clusterClient.gear 
            }
        }

        // CENTER: Dynamic View (Car or Map)
        Item {
            width: 300
            height: 350
            anchors.verticalCenter: parent.verticalCenter
            
            // Map View (Active when Nav is Active)
            NavigationView {
                anchors.fill: parent
                visible: clusterClient.navActive
            }

            // Car View (Default)
            CarIllustration {
                anchors.fill: parent
                visible: !clusterClient.navActive
                leftSignal: clusterClient.leftIndicator
                rightSignal: clusterClient.rightIndicator
            }
        }

        // RIGHT: Speed Gauge
        Item {
             width: 450; height: 450
             SpeedGauge {
                id: speedGauge
                anchors.centerIn: parent
                value: clusterClient.vehicleSpeed
                maxValue: 260
             }
        }
    }

    // Bottom Status Bar
    WarningIcons {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.8
    }
}
