import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width: 480; height: 480
    property real value: 0
    property real maxValue: 260
    
    // 1. Background Arc (Gradient Canvas)
    Canvas {
        id: dialCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width/2; var cy = height/2;
            var r = width/2 - 20;
            
            // Outer Ring - Blue/Cyan Gradient
            var grad = ctx.createLinearGradient(0, height, width, 0);
            grad.addColorStop(0, "#0033CC"); // Dark Blue
            grad.addColorStop(1, "#00E0FF"); // Cyan
            
            ctx.beginPath();
            ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25); // 270 deg span (135 to 405)
            ctx.lineWidth = 6;
            ctx.lineCap = "round";
            ctx.strokeStyle = grad;
            ctx.shadowBlur = 10;
            ctx.shadowColor = "#00E0FF";
            ctx.stroke();
            ctx.shadowBlur = 0; // Reset
            
            // Inner Tick Marks
            // 0 - 260. Steps: 20 -> 13 major steps.
            var startA = Math.PI*0.75;
            var span = Math.PI*1.5;
            
            for(var i=0; i<=260; i+=10) {
                var factor = i/260;
                var angle = startA + factor * span;
                
                var isMajor = (i % 20 === 0);
                var innerR = r - (isMajor ? 25 : 15);
                var outerR = r - 5;
                
                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle)*innerR, cy + Math.sin(angle)*innerR);
                ctx.lineTo(cx + Math.cos(angle)*outerR, cy + Math.sin(angle)*outerR);
                ctx.lineWidth = isMajor ? 3 : 1;
                ctx.strokeStyle = "#FFFFFF";
                ctx.stroke();
                
                // Text
                if(isMajor) {
                    var textR = r - 50;
                    var tx = cx + Math.cos(angle)*textR;
                    var ty = cy + Math.sin(angle)*textR;
                    ctx.fillStyle = "white";
                    ctx.font = "bold 20px Roboto";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(i.toString(), tx, ty);
                }
            }
        }
    }
    
    // 2. Needle
    Item {
        anchors.fill: parent
        // Mapping: 0 -> 135 deg, 260 -> 405 deg. Span 270.
        property real angle: 135 + (root.value / root.maxValue) * 270
        rotation: angle
        
        Behavior on rotation {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        
        Rectangle {
            width: 180; height: 4
            color: "#E60000"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -90
            antialiasing: true
            
            // Glow effect
            layer.enabled: true
            // Basic glow simulated by rectangle shadow if effects unavailable, 
            // but standard QtQuick primitives work best.
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "#FF3333"
                border.width: 1
                opacity: 0.5
            }
        }
    }

    // 3. Center Digital Readout
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.value)
            font.pixelSize: 64
            font.bold: true
            font.family: "Eurostile" // Or Roboto
            color: "white"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "km/h"
            font.pixelSize: 18
            color: "#AAAAAA"
        }
    }
    
    // 4. Cap
    Rectangle {
        width: 30; height: 30
        radius: 15
        color: "#111"
        border.color: "#333"
        border.width: 2
        anchors.centerIn: parent
    }
}
