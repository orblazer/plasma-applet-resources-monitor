import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../controls" as RMControls

QtLayouts.ColumnLayout {
    property alias cfg_verticalLayout: verticalLayout.checked
    property alias cfg_historyAmount: historyAmount.value
    property alias cfg_customGraphWidth: graphWidth.checked
    property alias cfg_graphWidth: graphWidth.value
    property alias cfg_customGraphHeight: graphHeight.checked
    property alias cfg_graphHeight: graphHeight.value
    property alias cfg_graphMargin: graphMargin.value
    property alias cfg_graphFillOpacity: graphFillOpacity.value

    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value
    property string cfg_placement: ""
    property string cfg_displayment: ""

    property alias cfg_customCpuColor: cpuColor.checked
    property alias cfg_cpuColor: cpuColor.value
    property alias cfg_customRamColor: ramColor.checked
    property alias cfg_ramColor: ramColor.value
    property alias cfg_customSwapColor: swapColor.checked
    property alias cfg_swapColor: swapColor.value
    property alias cfg_customNetDownColor: netDownColor.checked
    property alias cfg_netDownColor: netDownColor.value
    property alias cfg_customNetUpColor: netUpColor.checked
    property alias cfg_netUpColor: netUpColor.value
    property alias cfg_customWarningColor: warningColor.checked
    property alias cfg_warningColor: warningColor.value
    property alias cfg_customCriticalColor: criticalColor.checked
    property alias cfg_criticalColor: criticalColor.value

    property color primaryColor: theme.highlightColor
    property color positiveColor: theme.positiveTextColor
    property color neutralColor: theme.neutralTextColor
    property color negativeColor: theme.negativeTextColor

    PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            tab: graphPage
            text: i18n("Graph")
        }
        PlasmaComponents.TabButton {
            tab: textPage
            iconSource: "dialog-text-and-font"
            text: i18n("Text")
        }
        PlasmaComponents.TabButton {
            tab: colorsPage
            iconSource: "preferences-desktop-color"
            text: i18n("Colors")
        }
    }

    PlasmaComponents.TabGroup {
        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.fillHeight: true

        // Graph
        Kirigami.FormLayout {
            id: graphPage
            wideMode: true

            QtControls.CheckBox {
                id: verticalLayout
                text: i18n("Vertical layout")
            }

            RMControls.SpinBox {
                id: historyAmount
                Kirigami.FormData.label: i18n("History amount:")
                QtLayouts.Layout.fillWidth: true
                from: 2
            }

            RMControls.CustomizableSize {
                id: graphWidth
                Kirigami.FormData.label: i18n("Width:")
                QtLayouts.Layout.fillWidth: true
                from: 1
                to: 1000
            }
            RMControls.CustomizableSize {
                id: graphHeight
                Kirigami.FormData.label: i18n("Height:")
                QtLayouts.Layout.fillWidth: true
                from: 1
                to: 1000
            }
            RMControls.SpinBox {
                id: graphMargin
                Kirigami.FormData.label: i18n("Margin:")
                QtLayouts.Layout.fillWidth: true
                from: 1
                to: 1000

                textFromValue: function (value, locale) {
                    return valueToText(value, locale) + " px";
                }
            }
            RMControls.SpinBox {
                id: graphFillOpacity
                Kirigami.FormData.label: i18n("Fill opacity:")
                QtLayouts.Layout.fillWidth: true
                from: 1
                to: 100

                textFromValue: function (value, locale) {
                    return valueToText(value, locale) + "%";
                }
            }
        }

        // Text
        Kirigami.FormLayout {
            id: textPage
            wideMode: true

            QtControls.CheckBox {
                id: enableShadows
                text: i18n("Drop shadows")
            }

            RMControls.SpinBox {
                id: fontScale
                Kirigami.FormData.label: i18n("Font scale:")
                QtLayouts.Layout.fillWidth: true
                from: 1
                to: 100

                textFromValue: function (value, locale) {
                    return valueToText(value, locale) + "%";
                }
            }

            QtControls.ComboBox {
                id: displayment
                Kirigami.FormData.label: i18n("Text displayment:")
                textRole: "label"
                model: [{
                        "label": i18n("Always"),
                        "name": "always"
                    }, {
                        "label": i18n("On hover"),
                        "name": "hover"
                    }, {
                        "label": i18n("Hints when hover"),
                        "name": "hover-hints"
                    }]
                onCurrentIndexChanged: cfg_displayment = model[currentIndex]["name"]

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i]["name"] === plasmoid.configuration.displayment) {
                            displayment.currentIndex = i;
                        }
                    }
                }
            }

            QtControls.ComboBox {
                id: placement
                Kirigami.FormData.label: i18n("Placement:")
                textRole: "label"
                model: [{
                        "label": i18n("Top left"),
                        "name": "top-left"
                    }, {
                        "label": i18n("Top right"),
                        "name": "top-right"
                    }, {
                        "label": i18n("Bottom left"),
                        "name": "bottom-left"
                    }, {
                        "label": i18n("Bottom right"),
                        "name": "bottom-right"
                    }]
                onCurrentIndexChanged: cfg_placement = model[currentIndex]["name"]

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i]["name"] === plasmoid.configuration.placement) {
                            placement.currentIndex = i;
                        }
                    }
                }
            }
        }

        // Colors
        Kirigami.FormLayout {
            id: colorsPage

            RMControls.ColorSelector {
                id: cpuColor
                Kirigami.FormData.label: i18n("CPU:")

                dialogTitle: i18n("Choose CPU graph color")
                defaultColor: primaryColor
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing * 2
                color: "transparent"
            }
            PlasmaComponents.Label {
                text: i18n("Memory graph colors")
                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
            }
            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            RMControls.ColorSelector {
                id: ramColor
                Kirigami.FormData.label: i18n("Physical:")

                dialogTitle: i18n("Choose physical memory graph color")
                defaultColor: primaryColor
            }
            RMControls.ColorSelector {
                id: swapColor
                Kirigami.FormData.label: i18n("Swap:")

                dialogTitle: i18n("Choose swap memory graph color")
                defaultColor: positiveColor
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing * 2
                color: "transparent"
            }
            PlasmaComponents.Label {
                text: i18n("Network graph colors")
                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
            }
            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            RMControls.ColorSelector {
                id: netDownColor
                Kirigami.FormData.label: i18n("Receiving:")

                dialogTitle: i18n("Choose network receiving graph color")
                defaultColor: primaryColor
            }
            RMControls.ColorSelector {
                id: netUpColor
                Kirigami.FormData.label: i18n("Sending:")

                dialogTitle: i18n("Choose network sending graph color")
                defaultColor: positiveColor
            }

            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing * 2
                color: "transparent"
            }
            PlasmaComponents.Label {
                text: i18n("Threshold text colors")
                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
            }
            // Separator
            Rectangle {
                height: Kirigami.Units.largeSpacing
                color: "transparent"
            }

            RMControls.ColorSelector {
                id: warningColor
                Kirigami.FormData.label: i18n("Warning status:")

                dialogTitle: i18n("Choose text color when the value is in warning status")
                defaultColor: neutralColor
            }
            RMControls.ColorSelector {
                id: criticalColor
                Kirigami.FormData.label: i18n("Critical status:")

                dialogTitle: i18n("Choose text color when the value is in critical status")
                defaultColor: negativeColor
            }
        }
    }
}
