import QtQuick

Item {
    width: 320
    height: 380
    
    // Fallback car shape matching the blue SUV in image
    Image {
        // If real asset exists
        source: "../assets/car_top_view.png"
        anchors.centerIn: parent
        width: 140; height: 260
        fillMode: Image.PreserveAspectFit
        visible: false // Using vector drawing below if image missing
    }

    Item {
        id: vectorCar
        width: 120; height: 220
        anchors.centerIn: parent
        
        // Body
        Rectangle {
            anchors.fill: parent
            radius: 30
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0033CC" }
                GradientStop { position: 1.0; color: "#001144" }
            }
            border.color: "#0055FF"
            border.width: 2
        }
        
        // Windshield
        Rectangle {
            width: 90; height: 60
            color: "#111"
            radius: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.topMargin: 50
        }
        
        // Roof
        Rectangle {
            width: 90; height: 70
            color: "#002288"
            anchors.centerIn: parent
        }
    }
    
    // Indicators
    property bool isActive: clusterClient.leftIndicator || clusterClient.rightIndicator
    
    // Glows
    Rectangle {
        visible: clusterClient.leftIndicator
        width: 10; height: 10; radius: 5
        color: "orange"
        anchors.left: vectorCar.left; anchors.top: vectorCar.top
        
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: clusterClient.leftIndicator
            NumberAnimation { from: 1; to: 0; duration: 400 }
            NumberAnimation { from: 0; to: 1; duration: 400 }
        }
    }
    
    Rectangle {
        visible: clusterClient.rightIndicator
        width: 10; height: 10; radius: 5
        color: "orange"
        anchors.right: vectorCar.right; anchors.top: vectorCar.top
         SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: clusterClient.rightIndicator
            NumberAnimation { from: 1; to: 0; duration: 400 }
            NumberAnimation { from: 0; to: 1; duration: 400 }
        }
    }
}
