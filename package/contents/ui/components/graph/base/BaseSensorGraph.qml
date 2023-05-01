import QtQuick 2.9
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.formatter 1.0 as Formatter
import "./" as RMBaseGraph

Item {
    id: root

    signal chartDataChanged(int index)
    signal showValueInLabel
    signal labelChanged(PlasmaComponents.Label label, var value)

    property var sensors: []

    // Aliases
    readonly property alias textContainer: textContainer
    readonly property alias sensorsModel: sensorsModel

    // Thresholds properties
    property var thresholds: [undefined, undefined, undefined]
    property color thresholdWarningColor: Plasmoid.configuration.customWarningColor ? Plasmoid.configuration.warningColor : theme.neutralTextColor
    property color thresholdCriticalColor: Plasmoid.configuration.customCriticalColor ? Plasmoid.configuration.criticalColor : theme.negativeTextColor

    // Labels
    RMBaseGraph.GraphText {
        id: textContainer
        anchors.fill: parent
        z: 1

        onShowValueInLabel: {
            // Update labels
            for (let i = 0; i < sensors.length; i++) {
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
        enabled: root.visible

        /**
         * Get the data from sensor
         * @param {number} column The sensors index
         * @returns The data value, formatted value and sensor id
         */
        function getData(column) {
            if (!hasIndex(0, column)) {
                return undefined;
            }
            const indexVar = index(0, column);
            const value = data(indexVar, Sensors.SensorDataModel.Value);
            const res = {
                "sensorId": data(indexVar, Sensors.SensorDataModel.SensorId),
                "value": value
            };
            return res;
        }

        /**
         * Get info from sensor
         * @param {number} column The sensor index
         * @param {number} role The role id
         * @returns The sensor info
         */
        function getInfo(column, role = Sensors.SensorDataModel.Value) {
            if (!hasIndex(0, column)) {
                return 0;
            }
            return data(index(0, column), role);
        }
    }
    onSensorsChanged: sensorsModel.sensors = sensors

    property var _insertChartData: (column, value) => {} // NOTE: this is implemented by children
    property var _clear: () => {
        for (let i = 0; i < sensors.length; i++) {
            _updateData(i);
        }
    }
    property var _update: () => {
        for (let i = 0; i < sensors.length; i++) {
            root._insertChartData(i, sensorsModel.getInfo(i));

            // Update label
            if (textContainer.valueVisible) {
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
        const data = sensorsModel.getData(index);

        // Fill label with dots if data is not ready
        if (typeof data === 'undefined') {
            label.text = '...';
        } else
        // Hide can't be zero label
        if (!textContainer.labelsVisibleWhenZero[index] && data.value === 0) {
            label.text = '';
            label.visible = false;
            return;
        } else {
            // Handle threshold value
            if (typeof thresholds[index] !== 'undefined') {
                if (data.value >= thresholds[index][1]) {
                    label.color = thresholdCriticalColor;
                } else if (data.value >= thresholds[index][0]) {
                    label.color = thresholdWarningColor;
                } else {
                    label.color = textContainer.getTextColor(index);
                }
            }

            // Show value on label
            label.text = _formatValue(index, data);
        }
        labelChanged(label, data);
    }

    function _defaultFormatValue(index, data) {
        return Formatter.Formatter.formatValueShowNull(data.value, sensorsModel.getInfo(index, Sensors.SensorDataModel.Unit));
    }

    property var _formatValue: _defaultFormatValue
}
