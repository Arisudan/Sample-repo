import QtQuick
import QtQuick.Layouts

Item {
    width: 250 // Reduced width to fit
    height: 250
    // Mock Map for Navigation
    
    Rectangle {
        anchors.fill: parent
        color: "#111"
        radius: 125 // Circular mask effect if needed, but lets keep it rectangular or integrated
        clip: true
        border.color: "#333"
        border.width: 2

        // Map Grid Pattern
        Grid {
            columns: 10
            rows: 10
            anchors.centerIn: parent
            Repeater {
                model: 100
                Rectangle {
                    width: 25; height: 25
                    color: (index % 2 == 0) ? "#1a1a1a" : "#222"
                }
            }
        }
        
        // Roads
        PathView {
             // Simplified geometry to look like a map
        }
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#555";
                ctx.lineWidth = 4;
                ctx.beginPath();
                ctx.moveTo(125, 250);
                ctx.lineTo(125, 125);
                ctx.lineTo(200, 50);
                ctx.stroke();
                
                // Blue route
                ctx.strokeStyle = "#00aaff";
                ctx.lineWidth = 3;
                ctx.beginPath();
                ctx.moveTo(125, 250);
                ctx.lineTo(125, 125);
                ctx.stroke();
            }
        }
    }
    
    // 3D Car Model (Top View)
    Image {
        id: carImg
        source: "qrc:/assets/car_top_view.png" // We need to ensure this asset exists or simulate it
        width: 60
        height: 100
        anchors.centerIn: parent
        smooth: true
        
        // Blinker overlay
        Rectangle {
            id: leftBlink
            width: 10; height: 10
            color: "orange"
            x: 0; y: 10
            visible: carData && carData.leftTurn
        }
        Rectangle {
            id: rightBlink
            width: 10; height: 10
            color: "orange"
            x: parent.width - 10; y: 10
            visible: carData && carData.rightTurn
        }
    }
    
    // Fallback if image missing
    Rectangle {
        width: 50; height: 90
        color: "#0055aa" // Blue car
        radius: 10
        anchors.centerIn: parent
        visible: carImg.status != Image.Ready
    }
}
