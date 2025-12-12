import QtQuick

Item {
    width: 320
    height: 380
    
    // Background Container
    Rectangle {
        anchors.fill: parent
        color: "#1A0F33" // Deep purple-ish dark map background
        radius: 20
        border.color: "#00E0FF"
        border.width: 1
        clip: true
        
        // 1. Grid (Tron style)
        Grid {
            columns: 8; rows: 8
            anchors.centerIn: parent
            width: parent.width * 1.5; height: parent.height * 1.5 // Oversized for movement
            rotation: 15 // Slight tilt? No, clean grid.
            Repeater {
                model: 64
                Rectangle {
                    width: 60; height: 60
                    color: "transparent"
                    border.color: "#332266"
                    border.width: 1
                }
            }
        }
        
        // 2. Route Line (Neon Cyan)
        Canvas {
            id: routeCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.beginPath();
                // S-curve route
                ctx.moveTo(width/2, height);
                ctx.bezierCurveTo(width/2, height*0.6, width*0.7, height*0.4, width*0.7, 0);
                
                ctx.lineWidth = 10;
                ctx.strokeStyle = "#00E0FF";
                ctx.lineCap = "round";
                ctx.shadowColor = "#00E0FF";
                ctx.shadowBlur = 15;
                ctx.stroke();
                
                // Core line
                ctx.lineWidth = 4;
                ctx.strokeStyle = "#FFFFFF";
                ctx.shadowBlur = 0;
                ctx.stroke();
            }
        }
        
        // 3. Navigation Header
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 60
            color: "transparent"
            
            // Gradient Fade
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#aa000000" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Column {
                anchors.centerIn: parent
                Text {
                    text: "NAVIGATING TO:"
                    color: "#AAAAAA"
                    font.pixelSize: 10
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: clusterClient.destination
                    color: "#00E0FF"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // 4. Car Icon on Route
        Image {
            id: navCar
            // Fallback visualization if asset missing
            source: "qrc:/assets/car_icon_small.png"
            width: 40; height: 60
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 60 // Closer to bottom
            visible: false // Using Shape below
        }
        
        // Car Shape (Vector fallback)
        Item {
            width: 30; height: 50
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 60
            Rectangle {
                anchors.fill: parent
                color: "#111"
                border.color: "white"
                border.width: 2
                radius: 5
            }
            // Tail lights
            Rectangle { width: 6; height: 4; color: "red"; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.margins: 2 }
            Rectangle { width: 6; height: 4; color: "red"; anchors.bottom: parent.bottom; anchors.right: parent.right; anchors.margins: 2 }
        }

        // 5. ETA Footer
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 40
            color: "#80000000"
            Text {
                anchors.centerIn: parent
                text: "ETA: 10:25 AM - " + clusterClient.nextTurnDistance
                color: "white"
                font.pixelSize: 12
            }
        }
    }
}
