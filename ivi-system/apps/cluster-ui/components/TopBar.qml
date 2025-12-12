import QtQuick
import QtQuick.Layouts

Item {
    width: parent.width
    height: 80
    
    // 1. Weather Left (Top Left of Screen)
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 60 // Shifted slightly inward
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 15
        
        // Sun Icon (Canvas)
        Canvas {
            width: 40; height: 40
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#FFCC00";
                
                // Core
                ctx.beginPath();
                ctx.arc(20, 20, 10, 0, Math.PI*2);
                ctx.fill();
                
                // Rays
                ctx.strokeStyle = "#FFCC00";
                ctx.lineWidth = 2;
                for(var i=0; i<8; i++) {
                   var a = (i/8)*Math.PI*2;
                   ctx.beginPath();
                   ctx.moveTo(20 + Math.cos(a)*14, 20 + Math.sin(a)*14);
                   ctx.lineTo(20 + Math.cos(a)*18, 20 + Math.sin(a)*18);
                   ctx.stroke();
                }
            }
        }
        
        // Temp
        Text {
            text: "22°C"
            font.pixelSize: 28
            font.family: "Roboto" // Clean sans-serif
            font.weight: Font.Light
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // 2. Center Branding (Glowing ASTER)
    Item {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: 150; height: 50
        
        Text {
            anchors.centerIn: parent
            text: "ASTER"
            color: "#FFFFFF"
            font.pixelSize: 24
            font.bold: true
            font.family: "Eurostile"
            font.letterSpacing: 4
            
            // Cyan Glow layer
            layer.enabled: true
            // Basic glow simulation if Effects module not linked
            Rectangle {
                 anchors.fill: parent
                 color: "transparent"
                 opacity: 0.5
            }
        }
        
        // Underline/Logo Accent (Blue Glow)
        Rectangle {
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 80; height: 2
            color: "#00E0FF"
            opacity: 0.7
        }
    }
    
    // 3. Time Right (Top Right)
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 12
        
        Text {
            id: timeText
            text: "10:09" // Static for exact match to image, or dynamic: Qt.formatTime(new Date(), "hh:mm")
            color: "white"
            font.pixelSize: 32
            font.family: "Roboto"
            font.weight: Font.Normal
        }
        
        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "AM"
                color: "#AAAAAA"
                font.pixelSize: 14
                font.bold: true
            }
            Text {
                text: "OCT 26"
                color: "#AAAAAA"
                font.pixelSize: 14
                font.bold: true
            }
        }
    }
}
