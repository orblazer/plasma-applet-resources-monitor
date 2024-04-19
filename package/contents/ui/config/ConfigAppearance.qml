import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "./controls" as RMControls

KCM.AbstractKCM {
    // Make pages fill the whole view by default
    Kirigami.ColumnView.fillWidth: true

    // Chart
    property alias cfg_fillPanel: fillPanel.checked
    property alias cfg_historyAmount: historyAmount.realValue
    property alias cfg_customGraphWidth: graphWidth.customized
    property alias cfg_graphWidth: graphWidth.value
    property alias cfg_customGraphHeight: graphHeight.customized
    property alias cfg_graphHeight: graphHeight.value
    property alias cfg_graphSpacing: graphSpacing.value
    property alias cfg_graphFillOpacity: graphFillOpacity.value

    // Text
    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_fontScale: fontScale.value
    property string cfg_placement
    property string cfg_displayment

    // Colors
    // > Threshold
    property alias cfg_warningColor: warningColor.value
    property alias cfg_criticalColor: criticalColor.value

    //#region // HACK: Present to suppress errors (https://bugs.kde.org/show_bug.cgi?id=484541)
    property var cfg_graphs
    property var cfg_updateInterval
    property var cfg_clickAction
    property var cfg_clickActionCommand
    //#endregion

    // Tab bar
    header: PlasmaComponents.TabBar {
        id: bar

        PlasmaComponents.TabButton {
            icon.name: "office-chart-line-stacked"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Graphs")
        }
        PlasmaComponents.TabButton {
            icon.name: "dialog-text-and-font"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Text")
        }
        PlasmaComponents.TabButton {
            icon.name: "color-select"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Colors")
        }
    }

    Kirigami.ScrollablePage {
        anchors.fill: parent

        StackLayout {
            currentIndex: bar.currentIndex
            Layout.fillWidth: true

            // Charts
            Kirigami.FormLayout {
                QQC2.CheckBox {
                    id: fillPanel
                    text: i18n("Fill panel?")

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18nc("@info:tooltip", "This allow graphs to take all panel width/height")
                }

                RMControls.PredefinedSpinBox {
                    id: historyAmount
                    Kirigami.FormData.label: i18n("History amount:")
                    Layout.fillWidth: true
                    Layout.minimumWidth: predefinedChoices.currentIndex == 0 ? 300 : 0

                    predefinedChoices {
                        textRole: "label"
                        valueRole: "value"
                        model: [
                            {
                                "label": i18n("Custom"),
                                "value": -1
                            },
                            {
                                "label": i18n("Disabled"),
                                "value": 0
                            },
                            {
                                "label": "10",
                                "value": 10
                            },
                            {
                                "label": "20",
                                "value": 20
                            },
                            {
                                "label": "30",
                                "value": 30
                            },
                            {
                                "label": "40",
                                "value": 40
                            },
                            {
                                "label": "50",
                                "value": 50
                            }
                        ]
                    }

                    spinBox {
                        stepSize: 1
                        realFrom: 2
                    }
                }

                RMControls.CustomizableSize {
                    id: graphWidth
                    Kirigami.FormData.label: i18n("Width:")
                    Layout.fillWidth: true

                    spinBox {
                        from: 20
                        to: 1000
                    }
                }
                RMControls.CustomizableSize {
                    id: graphHeight
                    Kirigami.FormData.label: i18n("Height:")
                    Layout.fillWidth: true

                    spinBox {
                        from: 20
                        to: 1000
                    }
                }
                RMControls.SpinBox {
                    id: graphSpacing
                    Kirigami.FormData.label: i18n("Spacing:")
                    Layout.fillWidth: true
                    from: 1
                    to: 1000
                    suffix: " px"
                }
                RMControls.SpinBox {
                    id: graphFillOpacity
                    Kirigami.FormData.label: i18n("Fill opacity:")
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    suffix: "%"
                }
            }

            // Text
            Kirigami.FormLayout {
                QQC2.CheckBox {
                    id: enableShadows
                    text: i18n("Display outline?")
                }

                RMControls.SpinBox {
                    id: fontScale
                    Kirigami.FormData.label: i18n("Font scale:")
                    Layout.fillWidth: true
                    from: 1
                    to: 100
                    suffix: "%"
                }

                QQC2.ComboBox {
                    id: displayment
                    Kirigami.FormData.label: i18n("Text display:")
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
                            "label": i18nc("Text display", "On hover"),
                            "name": "hover"
                        },
                        {
                            "label": i18nc("Text display", "Hints when hover"),
                            "name": "hover-hints"
                        },
                        {
                            "label": i18nc("Text display", "Never"),
                            "name": "never"
                        }
                    ]

                    onActivated: cfg_displayment = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_displayment)
                }

                QQC2.ComboBox {
                    id: placement
                    Kirigami.FormData.label: i18n("Placement:")
                    Layout.fillWidth: true

                    currentIndex: -1
                    textRole: "label"
                    valueRole: "name"
                    model: [
                        {
                            "label": i18nc("Text placement", "Top left"),
                            "name": "top-left"
                        },
                        {
                            "label": i18nc("Text placement", "Top right"),
                            "name": "top-right"
                        },
                        {
                            "label": i18nc("Text placement", "Bottom left"),
                            "name": "bottom-left"
                        },
                        {
                            "label": i18nc("Text placement", "Bottom right"),
                            "name": "bottom-right"
                        }
                    ]

                    onActivated: cfg_placement = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(cfg_placement)
                }
            }

            // Colors
            Kirigami.FormLayout {
                // Thresholds
                Kirigami.Separator {
                    Kirigami.FormData.label: i18n("Threshold text colors")
                    Kirigami.FormData.isSection: true
                }

                RMControls.ColorSelector {
                    id: warningColor
                    Kirigami.FormData.label: i18n("Warning:")
                    dialogTitle: i18nc("Chart color", "Choose text color")
                }
                RMControls.ColorSelector {
                    id: criticalColor
                    Kirigami.FormData.label: i18n("Critical:")
                    dialogTitle: i18nc("Chart color", "Choose text color")
                }
            }
        }
    }
}
