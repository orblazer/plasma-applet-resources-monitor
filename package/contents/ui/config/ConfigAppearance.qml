import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import Qt.labs.platform as Platform
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "./controls" as RMControls

KCM.AbstractKCM {
    id: appearancePage
    // Make pages fill the whole view by default
    Kirigami.ColumnView.fillWidth: true

    // Chart
    property alias cfg_fillPanel: fillPanel.checked
    property alias cfg_historyAmount: historyAmount.realValue
    property alias cfg_graphSpacing: graphSpacing.value
    property alias cfg_graphFillOpacity: graphFillOpacity.value

    // Text
    property alias cfg_enableShadows: enableShadows.checked
    property alias cfg_autoFontAndSize: autoFontAndSizeRadioButton.checked
    // boldText and fontStyleName are not used
    // However, they are necessary to remember the exact font style chosen.
    // Otherwise, when the user open the font dialog again, the style will be lost.
    property alias cfg_fontFamily: fontDialog.fontChosen.family
    property alias cfg_boldText: fontDialog.fontChosen.bold
    property alias cfg_italicText: fontDialog.fontChosen.italic
    property alias cfg_fontWeight: fontDialog.fontChosen.weight
    property alias cfg_fontStyleName: fontDialog.fontChosen.styleName
    property alias cfg_fontSize: fontDialog.fontChosen.pointSize
    property string cfg_placement
    property string cfg_displayment

    // Colors
    property alias cfg_textColor: textColor.value
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

                // Font settings
                QQC2.ButtonGroup {
                    buttons: [autoFontAndSizeRadioButton, manualFontAndSizeRadioButton]
                }
                ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.FormData.label: i18nc("@label:group", "Text display:")
                    Kirigami.FormData.buddyFor: autoFontAndSizeRadioButton

                    QQC2.RadioButton {
                        id: autoFontAndSizeRadioButton
                        text: i18nc("@option:radio", "Automatic")
                    }

                    QQC2.Label {
                        text: i18nc("@label", "Text will follow the system font and expand to fill the available space.")
                        Layout.leftMargin: autoFontAndSizeRadioButton.indicator.width + autoFontAndSizeRadioButton.spacing
                        textFormat: Text.PlainText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        font: Kirigami.Theme.smallFont
                    }
                }
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.RadioButton {
                        id: manualFontAndSizeRadioButton
                        text: i18nc("@option:radio setting for manually configuring the font settings", "Manual")
                        checked: !cfg_autoFontAndSize
                        onClicked: {
                            if (cfg_fontFamily === "") {
                                fontDialog.fontChosen = Kirigami.Theme.defaultFont
                            }
                        }
                    }

                    QQC2.Button {
                        text: i18nc("@action:button", "Choose Style…")
                        icon.name: "settings-configure"
                        enabled: manualFontAndSizeRadioButton.checked
                        onClicked: {
                            fontDialog.open()
                            fontDialog.currentFont = fontDialog.fontChosen
                        }
                    }

                }

                ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        visible: manualFontAndSizeRadioButton.checked
                        Layout.leftMargin: manualFontAndSizeRadioButton.indicator.width + manualFontAndSizeRadioButton.spacing
                        text: i18nc("@info %1 is the font size, %2 is the font family", "%1pt %2", cfg_fontSize, fontDialog.fontChosen.family)
                        textFormat: Text.PlainText
                        font: fontDialog.fontChosen
                    }
                    QQC2.Label {
                        visible: manualFontAndSizeRadioButton.checked
                        Layout.leftMargin: manualFontAndSizeRadioButton.indicator.width + manualFontAndSizeRadioButton.spacing
                        text: i18nc("@info", "Note: size may be reduced if the panel is not thick enough.")
                        textFormat: Text.PlainText
                        font: Kirigami.Theme.smallFont
                    }
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
                RMControls.ColorSelector {
                    id: textColor
                    Kirigami.FormData.label: i18n("Default color:")
                    dialogTitle: i18nc("Chart color", "Choose text color")
                }

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

    Platform.FontDialog {
        id: fontDialog
        // title: i18nc("@title:window", "Choose a Font")
        modality: Qt.WindowModal
        parentWindow: appearancePage.Window.window

        property font fontChosen: null
        onAccepted: {
            fontChosen = font
        }
    }
}
