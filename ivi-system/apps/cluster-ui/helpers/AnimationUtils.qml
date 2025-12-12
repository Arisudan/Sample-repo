import QtQuick

QtObject {
    function ease(val, target, factor) {
        return val + (target - val) * factor
    }
}
