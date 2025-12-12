import QtQuick

QtObject {
    property color bgMain: "#000000"
    property color glowCyan: "#00E0FF"
    property color glowBlue: "#0055FF"
    property color needleRed: "#E60000"
    property color textWhite: "#FFFFFF"
    property color textGray: "#AAAAAA"
    property color warningRed: "#FF3333"
    property color warningAmber: "#FFCC00"
    
    // Gradients can be constructed in-place, but palettes are consistent here.
    property font fontMain: Qt.font({family: "Roboto", pixelSize: 18, weight: Font.Normal})
    property font fontDigit: Qt.font({family: "Eurostile", pixelSize: 24, weight: Font.Bold})
}
