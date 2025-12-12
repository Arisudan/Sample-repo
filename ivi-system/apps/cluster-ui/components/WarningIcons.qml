import QtQuick
import QtQuick.Shapes

Item {
    width: parent.width * 0.6
    height: 80
    
    Row {
        anchors.centerIn: parent
        spacing: 45

        // 1. Seatbelt (Red)
        Canvas {
            width: 40; height: 40
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "#FF3333";
                ctx.lineWidth = 3;
                ctx.lineCap = "round";
                ctx.beginPath();
                // Seat
                ctx.moveTo(10, 35); ctx.lineTo(10, 10); ctx.lineTo(30, 10); ctx.lineTo(30, 35);
                // Sash
                ctx.moveTo(10, 10); ctx.lineTo(30, 35);
                ctx.stroke();
                
                // Glow
                ctx.shadowColor = "#FF3333";
                ctx.shadowBlur = 10;
                ctx.stroke();
                ctx.shadowBlur = 0;
            }
            opacity: clusterClient.seatbelt ? 1.0 : 0.3
        }
        
        // 2. Battery (Yellow)
        Canvas {
            width: 45; height: 40
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "#FFCC00";
                ctx.lineWidth = 3;
                
                // Body
                ctx.strokeRect(5, 10, 35, 20);
                // Terminals
                ctx.fillStyle = "#FFCC00";
                ctx.fillRect(8, 5, 4, 5);
                ctx.fillRect(33, 5, 4, 5);
                
                // Symbols
                ctx.font = "bold 14px Arial";
                ctx.fillText("-", 10, 25);
                ctx.fillText("+", 25, 25);
                
                // Glow
                ctx.shadowColor = "#FFCC00";
                ctx.shadowBlur = 10;
                ctx.strokeRect(5, 10, 35, 20);
            }
            opacity: clusterClient.battery ? 1.0 : 0.3
        }
        
        // 3. Check Engine (Orange)
        Canvas {
            width: 50; height: 40
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "#FF6600";
                ctx.shadowColor = "#FF6600";
                ctx.shadowBlur = clusterClient.engineWarn ? 10 : 0;
                
                ctx.beginPath();
                ctx.moveTo(5, 15);
                ctx.lineTo(10, 10); ctx.lineTo(35, 10); ctx.lineTo(40, 15);
                ctx.lineTo(40, 30); ctx.lineTo(30, 35); ctx.lineTo(15, 35); ctx.lineTo(5, 30);
                ctx.closePath();
                ctx.fill();
                
                ctx.fillStyle = "black";
                ctx.font = "10px Arial";
                ctx.fillText("CHECK", 10, 25);
            }
            opacity: clusterClient.engineWarn ? 1.0 : 0.3
        }
        
        // 4. Low Beam (Green)
        Canvas {
            width: 45; height: 40
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "#00FF00";
                ctx.lineWidth = 3;
                ctx.shadowColor = "#00FF00";
                ctx.shadowBlur = 10;
                
                // Bulb shape
                ctx.beginPath();
                ctx.arc(35, 20, 10, Math.PI*0.5, Math.PI*1.5);
                ctx.stroke();
                
                // Beams (slanted down)
                ctx.beginPath();
                ctx.moveTo(25, 15); ctx.lineTo(5, 20);
                ctx.moveTo(25, 20); ctx.lineTo(5, 25);
                ctx.moveTo(25, 25); ctx.lineTo(5, 30);
                ctx.stroke();
            }
            opacity: clusterClient.fogLight ? 1.0 : 0.3 // Mapped to fog logic for demo
        }
        
        // 5. Bluetooth (Blue)
        Canvas {
            width: 30; height: 40
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = "#0055FF";
                ctx.lineWidth = 3;
                ctx.lineJoin = "round";
                ctx.lineCap = "round";
                ctx.shadowColor = "#0055FF";
                ctx.shadowBlur = 10;
                
                ctx.beginPath();
                ctx.moveTo(5, 10);
                ctx.lineTo(25, 30);
                ctx.lineTo(15, 40);
                ctx.lineTo(15, 0);
                ctx.lineTo(25, 10);
                ctx.lineTo(5, 30);
                ctx.stroke();
            }
            opacity: 1.0 // Always on connection
        }
    }
}
