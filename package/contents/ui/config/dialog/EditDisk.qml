import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../../code/formatter.js" as Formatter
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:44}
 */
BaseForm {
    id: root

    readonly property var unit: Formatter.getUnitInfo("kibibyte", i18nc)
    readonly property var speedOptions: [
        {
            "label": i18n("Custom"),
            "value": -1
        },
        {
            "label": i18n("Automatic"),
            "value": 0.0
        },
        // Mega options (pow 2)
        _getOption(10, 2), _getOption(100, 2), _getOption(200, 2), _getOption(500, 2),
        // Giga options (pow 3)
        _getOption(1, 3), _getOption(2, 3), _getOption(5, 3), _getOption(10, 3)]

    QQC2.CheckBox {
        text: i18n("Swap first and second line")
        checked: item.sensorsType[0]
        onClicked: {
            item.sensorsType[0] = checked;
            root.changed();
        }
    }

    QQC2.CheckBox {
        text: i18n("Show icons (%1 / %2)", i18nc("Disk graph icon : Read", " R"), i18nc("Disk graph icon : Write", "W"))
        checked: item.icons
        onClicked: {
            item.icons = checked;
            root.changed();
        }
    }

    // Transfer speed
    Item {
        Kirigami.FormData.label: i18n("Maximum transfer speed")
        Kirigami.FormData.isSection: true
    }
    RMControls.PredefinedSpinBox {
        id: readSpeed
        Layout.fillWidth: true
        Kirigami.FormData.label: i18nc("Chart config", "Read:")
        factor: 1000

        realValue: item.uplimits[0]
        onRealValueChanged: {
            item.uplimits[0] = readSpeed.realValue;
            root.changed();
        }

        predefinedChoices {
            textRole: "label"
            valueRole: "value"
            model: speedOptions
        }

        spinBox {
            decimals: 3
            stepSize: 1
            realFrom: 0.001
            suffix: " M" + unit.symbol
        }
    }
    RMControls.PredefinedSpinBox {
        id: writeSpeed
        Layout.fillWidth: true
        Kirigami.FormData.label: i18nc("Chart config", "Write:")
        factor: 1000

        realValue: item.uplimits[1]
        onRealValueChanged: {
            item.uplimits[1] = writeSpeed.realValue;
            root.changed();
        }

        predefinedChoices {
            textRole: "label"
            valueRole: "value"
            model: speedOptions
        }

        spinBox {
            decimals: 3
            stepSize: 1
            realFrom: 0.001
            suffix: " M" + unit.symbol
        }
    }

    // Colors
    Kirigami.Separator {
        Kirigami.FormData.label: i18n("Colors")
        Kirigami.FormData.isSection: true
    }
    RMControls.ColorSelector {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("First line:")
        dialogTitle: i18nc("Chart color", "Choose series color")

        value: item.colors[0]
        onValueChanged: {
            item.colors[0] = value;
            root.changed();
        }
    }
    RMControls.ColorSelector {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Second Line:")
        dialogTitle: i18nc("Chart color", "Choose text color")

        value: item.colors[1]
        onValueChanged: {
            item.colors[1] = value;
            root.changed();
        }
    }

    // Utils function
    function _getOption(value, pow = 0) {
        return {
            label: Formatter.formatValue(value * Math.pow(unit.multiplier, Math.max(0, pow)), unit, Qt.locale()),
            value: value * Math.pow(1000, Math.max(0, pow - 1))
        };
    }
}
