import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root
    property real speed: 0
    property real rpm: 0
    property int gear: 0

    width: 1280
    height: 480 // Ultrawide or standard

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#050510"
        gradient: Gradient {
             GradientStop { position: 0.0; color: "#101018" }
             GradientStop { position: 1.0; color: "#000000" }
        }
    }

    // Left: RPM Gauge
    Item {
        id: rpmGauge
        width: 400; height: 400
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        
        Text {
            anchors.centerIn: parent
            text: Math.round(root.rpm)
            color: "white"
            font.pixelSize: 60
            font.bold: true
        }
        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 50
            text: "RPM"
            color: "#888"
            font.pixelSize: 20
        }

        // Simple Gauge Ring
        Shape {
            anchors.fill: parent
            ShapePath {
                strokeColor: "#333"
                strokeWidth: 20
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"
                PathAngleArc {
                    centerX: 200; centerY: 200
                    radiusX: 180; radiusY: 180
                    startAngle: 135
                    sweepAngle: 270
                }
            }
            ShapePath {
                strokeColor: "#00aaff"
                strokeWidth: 20
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"
                PathAngleArc {
                    centerX: 200; centerY: 200
                    radiusX: 180; radiusY: 180
                    startAngle: 135
                    sweepAngle: 270 * (root.rpm / 8000)
                }
            }
        }
    }

    // Center: Gear & Speed
    Item {
        id: centerConsole
        anchors.centerIn: parent
        width: 300; height: 300
        
        Text {
            anchors.centerIn: parent
            text: Math.round(root.speed)
            color: "white"
            font.pixelSize: 100
            font.bold: true
            font.family: "Inter"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            text: "km/h"
            color: "#888"
            font.pixelSize: 24
        }
        
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            spacing: 20
            Repeater {
                model: ["P", "R", "N", "D"]
                Text {
                    text: modelData
                    color: {
                        if (root.gear == 0 && modelData == "P") return "#00ff00"
                        if (root.gear == 0 && modelData == "N") return "#888" // overlap logic simplified
                        // Mapping: 0=P, 1-6=D, handle R later if needed
                        if (root.gear > 0 && modelData == "D") return "#00ff00"
                        return "#444"
                    }
                    font.pixelSize: 32
                    font.bold: true
                }
            }
        }
    }
}
