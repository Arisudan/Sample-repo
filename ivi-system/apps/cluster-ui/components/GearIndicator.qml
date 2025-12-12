import QtQuick
import QtQuick.Layouts

Column {
    spacing: 15
    width: 60
    
    Repeater {
        model: ["P", "R", "N", "D"]
        delegate: Rectangle {
            width: 50; height: 50
            radius: 10
            color: (clusterClient.gear === modelData) ? "#222" : "transparent"
            border.color: (clusterClient.gear === modelData) ? "#00E0FF" : "transparent"
            border.width: 2
            
            Text {
                anchors.centerIn: parent
                text: modelData
                font.bold: true
                font.pixelSize: 24
                color: {
                    if(clusterClient.gear !== modelData) return "#444";
                    if(modelData === "P") return "#00FF00";
                    if(modelData === "R") return "#FF0000";
                    return "white";
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: clusterClient.setGear(modelData)
            }
        }
    }
}
