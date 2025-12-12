import QtQuick

Item {
    width: 250
    height: 300
    
    Rectangle {
        anchors.fill: parent
        color: "#222"
        radius: 10
        border.color: "#444"
        clip: true
        
        // Mock Map Grid
        Grid {
            columns: 5; rows: 6
            spacing: 0
            anchors.fill: parent
            Repeater {
                model: 30
                Rectangle {
                    width: 50; height: 50
                    color: (index % 2 == 0) ? "#2a2a2a" : "#303030"
                }
            }
        }

        // Route Line
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#00aaff";
                ctx.lineWidth = 6;
                ctx.lineCap = "round";
                ctx.beginPath();
                ctx.moveTo(125, 250);
                ctx.lineTo(125, 150);
                ctx.lineTo(180, 80);
                ctx.stroke();
            }
        }
        
        // Navigation Arrow Overlay
        Rectangle {
            width: 60; height: 60
            color: "#000000"
            opacity: 0.8
            radius: 10
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            
            Text {
                anchors.centerIn: parent
                text: "↱"
                color: "white"
                font.pixelSize: 40
            }
        }
        
        // Next Turn Info
        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 80
            anchors.topMargin: 15
            text: "Main St"
            color: "white"
            font.bold: true
        }
        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 80
            anchors.topMargin: 35
            text: "200 m"
            color: "#00aaff"
            font.pixelSize: 12
        }
    }
}
