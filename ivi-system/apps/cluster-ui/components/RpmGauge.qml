import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root
    width: 450
    height: 450
    property real value: 0
    property real maxValue: 8000
    
    // Outer Glow Ring (Blue/Cyan)
    Rectangle {
        anchors.fill: parent
        radius: width/2
        color: "transparent"
        border.color: "transparent" // We use canvas for complex gradient
    }

    Canvas {
        id: dialCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2;
            var cy = height / 2;
            var radius = width / 2 - 20;

            var startAngle = Math.PI * 0.8; // 144 deg
            var endAngle = Math.PI * 2.2;   // 396 deg
            
            // 1. Blue Halo Gradient
            var grad = ctx.createLinearGradient(0, height, width, 0);
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
            ctx.shadowBlur = 0; // Reset

            // 2. Ticks
            // 0 - 8000 (Let's say 40 big ticks?)
            var totalTicks = 80;
            var step = (endAngle - startAngle) / totalTicks;
            
            for (var i = 0; i <= totalTicks; i++) {
                var angle = startAngle + i * step;
                var rpmVal = (i / totalTicks) * 8000;
                
                var isRedline = (rpmVal >= 6500);
                var isMajor = (i % 10 === 0);
                
                var outerR = radius - 10;
                var innerR = outerR - (isMajor ? 15 : 8);

                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle) * outerR, cy + Math.sin(angle) * outerR);
                ctx.lineTo(cx + Math.cos(angle) * innerR, cy + Math.sin(angle) * innerR);
                ctx.lineWidth = isMajor ? 3 : 1;
                ctx.strokeStyle = isRedline ? "#ff0000" : (isMajor ? "#ffffff" : "#aaaaaa");
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
                    ctx.fillText((rpmVal/1000).toString(), tx, ty);
                }
            }
        }
    }

    // Center "Eco" Area
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
            text: "RPM"
            color: "#cc0000" // Red RPM text as in image
            font.pixelSize: 24
            font.bold: true
            font.family: "Eurostile"
        }
    }

    // Needle
    Item {
        id: needleContainer
        anchors.fill: parent
        
        // Rotation mapping
        // 0 -> startAngle (144 deg / 0.8 PI)
        // 8000 -> endAngle (396 deg / 2.2 PI)
        // Span = 252 deg
        property real angle: 144 + (root.value / root.maxValue) * 252
        
        rotation: angle
        Behavior on angle {
            // Smooth physics-based animation
            SpringAnimation { spring: 2.0; damping: 0.2; epsilon: 0.1 }
        }

        Rectangle {
            width: 160; height: 4
            color: "#ff0000"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -80 // Pivot at center
            antialiasing: true
            
            // Glow on needle
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
        
        // Simulating the metallic knob in image
        Rectangle {
            width: 20; height: 20
            radius: 10
            color: "#444"
            anchors.centerIn: parent
        }
    }
}
