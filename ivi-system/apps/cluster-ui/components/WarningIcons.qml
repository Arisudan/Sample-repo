import QtQuick
import QtQuick.Layouts

Item {
    width: 1000
    height: 80
    
    RowLayout {
        anchors.centerIn: parent
        spacing: 40

        // Left Arrow
        Text {
            text: "⬅️"
            font.pixelSize: 40
            color: clusterClient.leftIndicator ? "#00ff00" : "#333"
            MouseArea {
                 anchors.fill: parent
                 onClicked: clusterClient.toggleLeftIndicator()
            }
        }

        // Icons Frame
        Row {
            spacing: 25
            
            // Seatbelt
            Text { 
                text: "❌" 
                color: clusterClient.seatbelt ? "#333" : "red" 
                font.pixelSize: 32 
            }
            
            // Battery
            Text { 
                text: "🔋" 
                color: clusterClient.battery ? "red" : "#333" // Only show if issue
                font.pixelSize: 32 
            }
            
            // Engine
            Text { 
                text: "🔧" 
                color: clusterClient.engineWarn ? "yellow" : "#333"
                font.pixelSize: 32 
            }
            
            // Brake
            Text {
                text: "(P)"
                color: clusterClient.handbrake ? "red" : "#333"
                font.pixelSize: 32
                font.bold: true
            }

            // High Beam
            Text {
                text: "💡" // Placeholder for high beam
                color: clusterClient.highBeam ? "blue" : "#333"
                font.pixelSize: 32
            }
        }

        // Right Arrow
        Text {
            text: "➡️"
            font.pixelSize: 40
            color: clusterClient.rightIndicator ? "#00ff00" : "#333"
            MouseArea {
                 anchors.fill: parent
                 onClicked: clusterClient.toggleRightIndicator()
            }
        }
    }
}
