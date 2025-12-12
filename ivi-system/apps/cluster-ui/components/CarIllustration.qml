import QtQuick
import QtQuick.Layouts

Item {
    width: 250
    height: 300
    
    // Fallback car shape if image not provided or fails to load
    Rectangle {
        id: carBody
        width: 140
        height: 260
        anchors.centerIn: parent
        color: "#003366"
        radius: 30
        border.color: "#00aaff"
        border.width: 2
        
        // Roof
        Rectangle {
            width: 120; height: 140
            anchors.centerIn: parent
            color: "#001133"
            radius: 20
        }
        
        // Hood Lines
        Rectangle { width: 100; height: 2; color: "#00aaff"; anchors.top: parent.top; anchors.topMargin: 60; anchors.horizontalCenter: parent.horizontalCenter }
    }

    // Properties for signals
    property bool leftSignal: false
    property bool rightSignal: false

    // Left Blinker
    Rectangle {
        width: 10; height: 30
        color:  (leftSignal && blinkState) ? "orange" : "#333"
        anchors.right: carBody.left
        anchors.top: carBody.top
        anchors.topMargin: 40
    }
    Rectangle {
        width: 10; height: 30
        color: (leftSignal && blinkState) ? "orange" : "#333"
        anchors.right: carBody.left
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 40
    }

    // Right Blinker
    Rectangle {
        width: 10; height: 30
        color:  (rightSignal && blinkState) ? "orange" : "#333"
        anchors.left: carBody.right
        anchors.top: carBody.top
        anchors.topMargin: 40
    }
    Rectangle {
        width: 10; height: 30
        color: (rightSignal && blinkState) ? "orange" : "#333"
        anchors.left: carBody.right
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 40
    }

    // Blinker Timer
    property bool blinkState: false
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: blinkState = !blinkState
    }
}
