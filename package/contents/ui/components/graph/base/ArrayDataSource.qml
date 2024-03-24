import QtQuick
import org.kde.quickcharts as Charts

Charts.ArraySource {
    property int maximumHistory: -1

    onMaximumHistoryChanged: {
        if (maximumHistory != -1) {
            if (array.length === 0) {
                array = Array(maximumHistory).fill(0);
            }
            _update(false);
        }
    }

    function clear() {
        array = maximumHistory === -1 ? [] : Array(maximumHistory).fill(0);
        // Emit update
        dataChanged();
    }
    function insertValue(value) {
        array = [value, ...array];
        _update();
    }

    function _update() {
        // Reorder array
        while (array.length > 0 && array.length > maximumHistory) {
            array = array.slice(0, -1);
        }

        // Emit update
        dataChanged();
    }

    Component.onCompleted: {
        array = maximumHistory === -1 ? [] : Array(maximumHistory).fill(0);
    }
}
