import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter

Item {
    id: root

    // Aliases
    readonly property alias textContainer: textContainer
    readonly property alias sensorsModel: sensorsModel

    // Graph properties
    property var colors: [undefined, undefined, undefined] // Common graph settins
    property var sensorsType: [] // Present because is graph settings

    // Thresholds properties
    property int thresholdIndex: -1 // Sensor index used for threshold
    property var thresholds: [] // ONLY USED FOR CONFIG (graph settings)! | See "realThresholds"
    property var realThresholds: [] // fomart: [warning, critical]
    readonly property color thresholdWarningColor: textContainer._resolveColor(Plasmoid.configuration.warningColor)
    readonly property color thresholdCriticalColor: textContainer._resolveColor(Plasmoid.configuration.criticalColor)

    // Labels
    GraphText {
        id: textContainer
        enabled: Plasmoid.configuration.displayment != 'never'
        anchors.fill: parent
        z: 1
        hintColors: root.colors

        onShowValues: _update()
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

    property var _update: _defaultUpdate
    function _defaultUpdate() {
        for (let i = 0; i < sensorsModel.sensors.length; i++) {
            const value = sensorsModel.getData(i);
            // Skip not founded sensor
            if (typeof value === 'undefined') {
                continue;
            }
            root._insertChartData(i, value);

            // Update label
            if (textContainer.enabled && textContainer.valueVisible) {
                _updateLabel(i, value);
            }
        }
    }

    function _updateLabel(index, value) {
        // Retrieve label need to update and data
        const label = textContainer.getLabel(index);
        if (typeof label === "undefined" || !label.enabled) {
            return;
        }

        // Hide can't be zero label
        if (!textContainer.labelsVisibleWhenZero[index] && value === 0) {
            label.text = '';
            label.visible = false;
        } else {
            // Handle threshold value
            if (index === thresholdIndex && realThresholds.length > 0) {
                if (value >= realThresholds[1]) {
                    label.color = thresholdCriticalColor;
                } else if (value >= realThresholds[0]) {
                    label.color = thresholdWarningColor;
                } else {
                    label.color = textContainer.getTextColor(index);
                }
            }

            // Show value on label
            label.text = _formatValue(index, value);
            label.visible = true;
        }
    }

    property var _formatValue: _defaultFormatValue
    function _defaultFormatValue(index, value) {
        return Formatter.Formatter.formatValueShowNull(value, sensorsModel.getData(index, Sensors.SensorDataModel.Unit));
    }
}
