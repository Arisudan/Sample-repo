import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning

Window {
    width: 1024
    height: 600
    visible: true
    title: "Navigation"

    Plugin {
        id: mapPlugin
        name: "mapboxgl" // or "osm"
        // PluginParameter { name: "mapboxgl.access_token"; value: "YOUR_TOKEN_HERE" }
    }

    Map {
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(37.7749, -122.4194) // SF
        zoomLevel: 14

        MapQuickItem {
            coordinate: parent.center
            sourceItem: Image {
                source: "qrc:/icons/car_marker.png"
                width: 32; height: 32
            }
        }
    }

    // Search Bar
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 400; height: 50
        color: "#AA000000"
        radius: 10
        anchors.topMargin: 20
        
        TextInput {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            leftPadding: 20
            color: "white"
            text: "Search Destination..."
        }
    }
}
