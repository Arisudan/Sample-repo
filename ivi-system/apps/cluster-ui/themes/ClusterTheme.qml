import QtQuick

QtObject {
    property color backgroundMain: "black"
    property color gaugeGlow: "#00aaff"
    property color needleColor: "#ff0000"
    property color textPrimary: "#ffffff"
    property color textSecondary: "#aaaaaa"
    property color accent: "#00aaff"
    property color warning: "#ffcc00"
    property color error: "#ff4444"
    property color success: "#44ff44"
    
    // Gradient definitions can be handled via components using these colors
    property font fontMain: Qt.font({family: "Roboto", pointSize: 14, weight: Font.Medium})
    property font fontEuro: Qt.font({family: "Eurostile", pointSize: 14, weight: Font.Bold})
}
