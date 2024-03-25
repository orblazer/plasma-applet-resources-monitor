import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import "./" as RMBaseGraph
import "../../functions.mjs" as Functions

Item {
    id: root

    signal chartDataChanged(int index)
    signal showValueInLabel
    signal labelChanged(PlasmaComponents.Label label, var value)

    // Aliases
    readonly property alias textContainer: textContainer
    readonly property alias sensorsModel: sensorsModel

    // Graph properties
    property var colors: [undefined, undefined, undefined] // Common graph settins
    property var sensorsType: [] // Present because is graph settins

    // Thresholds properties
    property int thresholdIndex: -1 // Sensor index used for threshold
    property var thresholds: [] // ONLY USED FOR CONFIG (graph settins)! | fomart: [warning, critical]
    property var realThresholds: [] // fomart: [warning, critical]
    readonly property color thresholdWarningColor: Functions.resolveColor(Plasmoid.configuration.warningColor)
    readonly property color thresholdCriticalColor: Functions.resolveColor(Plasmoid.configuration.criticalColor)

    // Labels
    RMBaseGraph.GraphText {
        id: textContainer
        enabled: Plasmoid.configuration.displayment != 'never'
        anchors.fill: parent
        z: 1
        labelColors: root.colors

        onShowValueInLabel: {
            // Update labels
            for (let i = 0; i < sensorsModel.sensors.length; i++) {
                _updateData(i);
            }

            // Emit signal
            root.showValueInLabel();
        }
    }

    // Retrieve data from sensors, and update labels
    Sensors.SensorDataModel {
        id: sensorsModel
        updateRateLimit: -1

        /**
         * Get the value and sensor ID from sensor
         * @param {number} column The sensors index
         * @returns The data value, formatted value and sensor id
         */
        function getValue(column) {
            if (!hasIndex(0, column)) {
                return undefined;
            }
            const indexVar = index(0, column);
            return {
                "sensorId": data(indexVar, Sensors.SensorDataModel.SensorId),
                "value": data(indexVar, Sensors.SensorDataModel.Value)
            };
        }

        /**
         * Get data from sensor
         * @param {number} column The sensor index
         * @param {number} role The role id
         * @returns The sensor data
         */
        function getData(column, role = Sensors.SensorDataModel.Value) {
            if (!hasIndex(0, column)) {
                return undefined;
            }
            return data(index(0, column), role);
        }
    }

    // Process functions
    property var _insertChartData: (column, value) => {} // NOTE: this is implemented by children
    property var _clear: () => {
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            _updateData(i);
        }
    }
    property var _update: () => {
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            const data = sensorsModel.getData(i);
            // Skip not founded sensor
            if (typeof data === 'undefined') {
                continue;
            }
            const value = root._insertChartData(i, data);

            // Update label
            if (textContainer.enabled && textContainer.valueVisible) {
                _updateData(i);
            }
        }
    }

    function _getLabel(index) {
        if (index === 0) {
            return textContainer.firstLineLabel;
        } else if (index === 1) {
            return textContainer.secondLineLabel;
        } else if (index === 2) {
            return textContainer.thirdLineLabel;
        }
        return undefined;
    }

    function _updateData(index) {
        // Retrieve label need to update
        const label = _getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }
        const data = sensorsModel.getValue(index);
        if (typeof data === 'undefined') {
            return;
        }

        // Hide can't be zero label
        if (!textContainer.labelsVisibleWhenZero[index] && data.value === 0) {
            label.text = '';
            label.visible = false;
        } else {
            // Handle threshold value
            if (index === thresholdIndex && realThresholds.length > 0) {
                if (data.value >= realThresholds[1]) {
                    label.color = thresholdCriticalColor;
                } else if (data.value >= realThresholds[0]) {
                    label.color = thresholdWarningColor;
                } else {
                    label.color = textContainer.getTextColor(index);
                }
            }

            // Show value on label
            label.text = _formatValue(index, data);
            label.visible = label.enabled;
        }
        labelChanged(label, data);
    }

    property var _formatValue: _defaultFormatValue
    function _defaultFormatValue(index, data) {
        return Formatter.Formatter.formatValueShowNull(data.value, sensorsModel.getData(index, Sensors.SensorDataModel.Unit));
    }
}
