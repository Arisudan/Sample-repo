import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width: 480; height: 480
    property real value: 0
    property real maxValue: 8000
    
    Canvas {
        id: dialCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width/2; var cy = height/2;
            var r = width/2 - 20;
            
            // Outer Ring - Blue/Cyan Gradient
            var grad = ctx.createLinearGradient(width, height, 0, 0);
            grad.addColorStop(0, "#0033CC"); 
            grad.addColorStop(1, "#00E0FF");
            
            ctx.beginPath();
            ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25);
            ctx.lineWidth = 6;
            ctx.lineCap = "round";
            ctx.strokeStyle = grad;
            ctx.shadowBlur = 10;
            ctx.shadowColor = "#00E0FF";
            ctx.stroke();
            ctx.shadowBlur = 0;
            
            // Redline (6000-8000)
            // Factorstart = 6/8 = 0.75 of sweep. 
            // Sweep starts at 135 deg (0.75 PI), spans 270 (1.5PI).
            // Redline start angle = 0.75PI + 0.75 * 1.5PI = 1.875PI (337.5 deg)
            ctx.beginPath();
            ctx.arc(cx, cy, r, Math.PI * 1.875, Math.PI * 2.25);
            ctx.lineWidth = 6;
            ctx.strokeStyle = "#FF0000";
            ctx.stroke();

            // Ticks (0-8)
            var startA = Math.PI*0.75;
            var span = Math.PI*1.5;
            
            for(var i=0; i<=80; i+=2) { // 0, 200, ... 8000 (div 100)
                var val = i*100;
                var factor = val/8000;
                var angle = startA + factor * span;
                
                var isMajor = (val % 1000 === 0);
                var isRed = (val >= 6000);
                
                var innerR = r - (isMajor ? 25 : 15);
                var outerR = r - 5;
                
                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle)*innerR, cy + Math.sin(angle)*innerR);
                ctx.lineTo(cx + Math.cos(angle)*outerR, cy + Math.sin(angle)*outerR);
                ctx.lineWidth = isMajor ? 3 : 1;
                ctx.strokeStyle = isRed ? "#FF0000" : "#FFFFFF";
                ctx.stroke();
                
                if(isMajor) {
                    var textR = r - 50;
                    var tx = cx + Math.cos(angle)*textR;
                    var ty = cy + Math.sin(angle)*textR;
                    ctx.fillStyle = "white";
                    ctx.font = "bold 20px Roboto";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText((val).toString(), tx, ty);
                }
            }
        }
    }
    
    // Needle
    Item {
        anchors.fill: parent
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
        }
    }

    // Center Digital RPM
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.value)
            font.pixelSize: 32
            font.bold: true
            font.family: "Eurostile"
            color: "white"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "RPM"
            font.pixelSize: 18
            color: "#E60000" // Red label
        }
    }
    
    Rectangle {
        width: 30; height: 30
        radius: 15
        color: "#111"
        border.color: "#333"
        border.width: 2
        anchors.centerIn: parent
    }
}
