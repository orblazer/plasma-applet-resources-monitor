import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import "../controls" as RMControls

/**
 * Settings format: {@link ../../code/graphs.js:64}
 */
BaseForm {
    id: root
    colorsType: ["text", "text", false]

    // Check if device has statistics (energy-rate, time)
    property bool hasStats: false
    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"
        connectedSources: ["upower -d"]

        readonly property string sanitizedDevice: root.item.device.replace(/:/g, "_")

        onNewData: (sourceName, data) => {
            if (sourceName !== "upower -d" || !data["stdout"])
                return;

            const block = data["stdout"].split("Device: ").find(d => d.includes(sanitizedDevice));
            if (!block)
                return;

            const match = block.match(/has statistics:\s+(\S+)/);
            root.hasStats = match?.[1] === "yes";
        }
    }

    properties: Kirigami.FormLayout {
        QQC2.TextField {
            id: textField
            text: root.item.title
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Title:")

            onTextChanged: {
                root.item.title = text;
                root.changed();
            }
        }

        // First line
        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("First line:")
            enabled: hasStats

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("Percentage"),
                    "value": "percentage"
                },
                {
                    "label": i18n("Energy rate (W)"),
                    "value": "energy-rate"
                },
                {
                    "label": i18n("Time (s)"),
                    "value": "time"
                },
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[0])
            onActivated: {
                root.item.sensorsType[0] = currentValue;
                root.changed();
            }

            QQC2.ToolTip.text: i18nc("@info:tooltip", "This device doesn't have statistics, only percentage is available.")
            QQC2.ToolTip.visible: hovered && !enabled
        }
    }

    appearanceProperties: Kirigami.FormLayout {
        QQC2.CheckBox {
            text: i18n("Hide when absent/disconnected ?")
            checked: root.item.sensorsType[1]
            onClicked: {
                root.item.sensorsType[1] = checked;
                root.changed();
            }
        }

        QQC2.ComboBox {
            id: displayment
            Kirigami.FormData.label: i18n("Title when:")
            Layout.fillWidth: true

            currentIndex: -1
            textRole: "label"
            valueRole: "name"
            model: [
                {
                    "label": i18nc("Text display", "Always"),
                    "name": "always"
                },
                {
                    "label": i18nc("Text display", "Hints when hover"),
                    "name": "hints"
                },
                {
                    "label": i18nc("Text display", "Never"),
                    "name": "never"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.titleWhen)
            onActivated: {
                root.item.titleWhen = currentValue;
                root.changed();
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Threshold")
            Kirigami.FormData.isSection: true
        }
        RMControls.Thresholds {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Percentage:")

            values: root.item.thresholds
            onValuesChanged: {
                root.item.thresholds = values;
                root.changed();
            }

            decimals: 1
            stepSize: 1
            realFrom: 0.1
            realTo: 100
            suffix: "%"
        }
    }
}
