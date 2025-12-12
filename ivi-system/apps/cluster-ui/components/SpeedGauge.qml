import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "../themes"
import "../helpers"

Item {
    id: root
    width: 450; height: 450
    property real value: 0
    property real maxValue: 260
    
    // Background Arc
    Canvas {
        id: dialCanvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width/2; var cy = height/2;
            var r = width/2 - 20;

            // Gradient Stroke
            var grad = ctx.createLinearGradient(width, height, 0, 0); // Diagonal
            grad.addColorStop(0, "#0055ff");
            grad.addColorStop(1, "#00ffff");

            ctx.beginPath();
            ctx.arc(cx, cy, r, Math.PI*0.8, Math.PI*2.2);
            ctx.lineWidth = 4;
            ctx.strokeStyle = grad;
            ctx.stroke();

            // Ticks
            var start = Math.PI*0.8; 
            var span = Math.PI*1.4; // 252 deg
            var steps = 13; // 20kmh steps
            for(var i=0; i<=steps; i++) {
                var a = start + (i/steps)*span;
                var x1 = cx + Math.cos(a)*(r-15);
                var y1 = cy + Math.sin(a)*(r-15);
                var x2 = cx + Math.cos(a)*(r-5);
                var y2 = cy + Math.sin(a)*(r-5);
                
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.lineWidth = 3;
                ctx.strokeStyle = "white";
                ctx.stroke();

                // Text
                var val = i*20;
                var tx = cx + Math.cos(a)*(r-40);
                var ty = cy + Math.sin(a)*(r-40);
                ctx.fillStyle = "white";
                ctx.font = "20px Roboto";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText(val, tx, ty);
            }
        }
    }

    // Needle
    Item {
        anchors.fill: parent
        property real angle: 144 + (root.value / root.maxValue) * 252
        rotation: angle
        Behavior on rotation {
            NumberAnimation { duration: 250; easing.type: Easing.InOutCubic }
        }
        
        Rectangle {
            width: 150; height: 4
            color: "#ff0000"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -75
            antialiasing: true
        }
    }

    // Large Digital Speed
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 40
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.value)
            font.pixelSize: 64
            font.bold: true
            font.family: "Eurostile"
            color: "white"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "km/h"
            font.pixelSize: 20
            color: "#aaaaaa"
        }
    }
}
