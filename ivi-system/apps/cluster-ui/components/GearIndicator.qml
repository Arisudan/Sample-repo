import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 20
    property int currentGear: 0 // 0=P, 1=R, 2=N, 3+=D
    // Mapping: P=0, R=1, N=2, D=3,4,5...
    
    Repeater {
        model: ["P", "R", "N", "D"]
        delegate: Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            color: "transparent"
            border.color: {
                var isActive = false;
                if (index === 0 && currentGear === 0) isActive = true; // P
                if (index === 1 && currentGear === 1) isActive = true; // R
                if (index === 2 && currentGear === 2) isActive = true; // N
                if (index === 3 && currentGear >= 3)  isActive = true; // D
                return isActive ? "#666" : "#333"
            }
            border.width: 4
            radius: 10
            
            Text {
                anchors.centerIn: parent
                text: modelData
                font.pixelSize: 50
                font.bold: true
                color: {
                    var isActive = false;
                    if (index === 0 && currentGear === 0) isActive = true;
                    if (index === 1 && currentGear === 1) isActive = true; // R
                    if (index === 2 && currentGear === 2) isActive = true;
                    if (index === 3 && currentGear >= 3)  isActive = true;

                    if (isActive) {
                        if (modelData === "N") return "#00ff00"; // Green N
                        if (modelData === "R") return "#ff4444"; // Red R
                        return "white";
                    }
                    return "#555";
                }
            }
            
            // Glow effect for active
            layer.enabled: true
        }
    }
}
