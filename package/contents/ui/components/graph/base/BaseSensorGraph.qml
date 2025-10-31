import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import org.kde.kirigami as Kirigami
import "../../" as RMComponents

Item {
    id: root

    // Aliases
    readonly property alias textContainer: textContainer
    readonly property alias sensorsModel: sensorsModel

    // Graph properties
    property var colors: [undefined, undefined, undefined] // Common graph settings
    property var sensorsType: [] // Present because is graph settings

    // Thresholds properties
    property var thresholds: [] // ONLY USED FOR CONFIG (graph settings)! | See "textContainer.thresholds"

    // Labels
    RMComponents.TextContainer {
        id: textContainer
        enabled: Plasmoid.configuration.displayment != 'never'
        z: 1
        hintColors: root.colors
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
            if (textContainer.enabled) {
                textContainer.setValue(i, value, _formatValue(i, value));
            }
        }
    }

    property var _formatValue: _defaultFormatValue
    function _defaultFormatValue(index, value) {
        return Formatter.Formatter.formatValueShowNull(value, sensorsModel.getData(index, Sensors.SensorDataModel.Unit));
    }

    /**
     * Resolve color when is name based
     * @param {string} color The color value
     * @returns The color color
     */
    function _resolveColor(color) {
        if (!color) {
            return Kirigami.Theme.textColor;
        } else if (color.startsWith("#")) {
            return color;
        }
        return Kirigami.Theme[color] ?? Kirigami.Theme.textColor;
    }
}
