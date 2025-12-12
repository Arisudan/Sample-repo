import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 15
    width: 60
    property string currentGear: "P"

    Repeater {
        model: ["P", "R", "N", "D"]
        delegate: Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 50; height: 50
            radius: 10
            color: (modelData === currentGear) ? "#333" : "transparent"
            border.color: (modelData === currentGear) ? "#00aaff" : "transparent"
            border.width: 2
            
            Text {
                anchors.centerIn: parent
                text: modelData
                color: (modelData === currentGear) ? "white" : "#666"
                font.bold: true
                font.pixelSize: 28
            }
            
            MouseArea {
                anchors.fill: parent
                 acceptedButtons: Qt.LeftButton
                onClicked: {
                    console.log("QML Clicked Gear: " + modelData)
                    clusterClient.setGear(modelData)
                }
            }
        }
    }
}
