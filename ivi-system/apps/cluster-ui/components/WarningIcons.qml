import QtQuick
import QtQuick.Layouts

Item {
    width: 1280
    height: 80
    
    RowLayout {
        anchors.fill: parent
        spacing: 40
        anchors.leftMargin: 40
        anchors.rightMargin: 40

        // Left Arrow
        Text {
            text: "⬅️"
            font.pixelSize: 40
            color: blinkerLeft ? "#00ff00" : "#222"
            property bool blinkerLeft: false // Bind later
        }

        // Warning Group 1
        Row {
            spacing: 20
            Text { text: "(!)"; color: "yellow"; font.pixelSize: 30; font.bold: true } // ABS/Brake
            Text { text: "🔋"; color: "red"; font.pixelSize: 30 }
            Text { text: "🔧"; color: "orange"; font.pixelSize: 30 } // Engine
        }

        Item { Layout.fillWidth: true }

        // CENTER BRANDING (Bottom)
        Text {
            text: "ASTER" // Replaces WAFDUNIX
            color: "#00aaff"
            font.pixelSize: 24
            font.bold: true
            font.letterSpacing: 2
        }

        Item { Layout.fillWidth: true }

        // Warning Group 2
        Row {
            spacing: 20
            Text { text: "❌"; color: "red"; font.pixelSize: 30 } // Seatbelt mock
            Text { text: "(P)"; color: "yellow"; font.pixelSize: 30; font.bold: true }
            Text { text: "💡"; color: "green"; font.pixelSize: 30 }
        }

        // Right Arrow
        Text {
            text: "➡️"
            font.pixelSize: 40
            color: blinkerRight ? "#00ff00" : "#222"
            property bool blinkerRight: false
        }
    }
}
