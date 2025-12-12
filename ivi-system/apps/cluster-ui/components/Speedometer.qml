import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root
    width: 450
    height: 450
    property real value: 0
    property real maxValue: 260
    
    Canvas {
        id: dialCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2;
            var cy = height / 2;
            var radius = width / 2 - 20;

            var startAngle = Math.PI * 0.8; 
            var endAngle = Math.PI * 2.2;   
            
            // 1. Blue Halo Gradient
            var grad = ctx.createLinearGradient(width, height, 0, 0);
            grad.addColorStop(0, "#0000ff");
            grad.addColorStop(0.5, "#00ffff");
            grad.addColorStop(1, "#0000ff");
            
            ctx.beginPath();
            ctx.arc(cx, cy, radius, startAngle, endAngle);
            ctx.lineWidth = 4;
            ctx.strokeStyle = grad;
            ctx.shadowColor = "#00ffff";
            ctx.shadowBlur = 20;
            ctx.stroke();
            ctx.shadowBlur = 0;

            // 2. Ticks
            // 0 - 260
            var totalTicks = 52; // every 5 kmh
            var step = (endAngle - startAngle) / totalTicks;
            
            for (var i = 0; i <= totalTicks; i++) {
                var angle = startAngle + i * step;
                var speedVal = (i / totalTicks) * 260;
                
                var isMajor = (speedVal % 20 === 0);
                
                var outerR = radius - 10;
                var innerR = outerR - (isMajor ? 15 : 8);

                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle) * outerR, cy + Math.sin(angle) * outerR);
                ctx.lineTo(cx + Math.cos(angle) * innerR, cy + Math.sin(angle) * innerR);
                ctx.lineWidth = isMajor ? 3 : 1;
                ctx.strokeStyle = isMajor ? "#ffffff" : "#aaaaaa";
                ctx.stroke();
                
                // Numbers
                if (isMajor) {
                    var numR = innerR - 25;
                    var tx = cx + Math.cos(angle) * numR;
                    var ty = cy + Math.sin(angle) * numR;
                    
                    ctx.fillStyle = "white";
                    ctx.font = "bold 20px Eurostile";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(Math.round(speedVal).toString(), tx, ty);
                }
            }
        }
    }

    // Center Digital Readout
    Item {
        anchors.centerIn: parent
        width: 150; height: 150
        
        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -30
            text: "🌿 Echo"
            color: "#00ff00"
            font.pixelSize: 18
            opacity: 0.8
        }
        
        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 50
            text: "km/h" // Was mm/s in one image, sticking to km/h
            color: "white" 
            font.pixelSize: 24
            font.bold: true
            font.family: "Eurostile"
        }
    }

    // Needle
    Item {
        id: needleContainer
        anchors.fill: parent
        property real angle: 144 + (root.value / root.maxValue) * 252
        rotation: angle
        Behavior on angle {
            SpringAnimation { spring: 2.0; damping: 0.2; epsilon: 0.1 }
        }

        Rectangle {
            width: 160; height: 4
            color: "#ff0000"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -80
            antialiasing: true
             layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#ff0000"
                shadowBlur: 1.0
            }
        }
    }
    
    // Center Cap
    Rectangle {
        width: 40; height: 40
        radius: 20
        color: "#1a1a1a"
        border.color: "#333"
        border.width: 2
        anchors.centerIn: parent
        Rectangle {
            width: 20; height: 20
            radius: 10
            color: "#444"
            anchors.centerIn: parent
        }
    }
}
