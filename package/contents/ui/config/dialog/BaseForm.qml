import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.plasma.components as PlasmaComponents
import "../controls" as RMControls

ColumnLayout {
    id: root
    spacing: 0
    Layout.fillWidth: true
    Layout.fillHeight: true

    signal changed // Notify some settings as been changed

    required property var item
    property alias properties: propertiesLoader.sourceComponent
    property alias appearanceProperties: appearancePropsLoader.sourceComponent

    property var colorsType: ["series", "text", "text"]
    property string _seriesColorTitle: i18nc("Chart color", "Choose series color")
    property string _textColorTitle: i18nc("Chart color", "Choose text color")

    PlasmaComponents.TabBar {
        id: bar
        currentIndex: properties == null ? 1 : 0
        Layout.fillWidth: true

        PlasmaComponents.TabButton {
            enabled: properties != null
            icon.name: "preferences-system-other"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Settings")
        }
        PlasmaComponents.TabButton {
            icon.name: "preferences-desktop-color"
            icon.height: Kirigami.Units.iconSizes.smallMedium
            text: i18nc("Config header", "Appearance")
        }
    }

    Primitives.Separator {
        Layout.fillWidth: true
    }

    QQC2.ScrollView {
        id: scrollView
        Layout.fillWidth: true
        Layout.fillHeight: true

        background: Rectangle {
            color: Platform.Theme.alternateBackgroundColor
        }

        StackLayout {
            id: pages
            currentIndex: bar.currentIndex
            width: scrollView.availableWidth

            // Settings
            ColumnLayout {
                spacing: 0

                Loader {
                    id: propertiesLoader
                    Layout.fillWidth: true
                    Layout.margins: Platform.Units.gridUnit
                }
            }

            // Appearance
            ColumnLayout {
                spacing: 0

                Loader {
                    id: appearancePropsLoader
                    Layout.topMargin: Platform.Units.gridUnit
                    Layout.leftMargin: Platform.Units.gridUnit
                    Layout.rightMargin: Platform.Units.gridUnit

                    Layout.fillWidth: true
                    onLoaded: {
                        if (typeof item.twinFormLayouts != "undefined") {
                            item.twinFormLayouts = Qt.binding(() => ([appearance]));
                        }
                    }
                }

                Kirigami.FormLayout {
                    id: appearance
                    Layout.bottomMargin: Platform.Units.gridUnit
                    Layout.leftMargin: Platform.Units.gridUnit
                    Layout.rightMargin: Platform.Units.gridUnit

                    // Sizes
                    Kirigami.Separator {
                        Kirigami.FormData.label: i18n("Size")
                        Kirigami.FormData.isSection: true
                    }
                    RMControls.CustomizableSize {
                        id: graphWidth
                        Kirigami.FormData.label: i18n("Width:")
                        Layout.fillWidth: true
                        property bool isReady: false

                        Component.onCompleted: {
                            if (item.sizes[0] != -1) {
                                value = item.sizes[0];
                                customized = true;
                            } else {
                                customized = false;
                            }
                        }
                        onValueChanged: {
                            if (!isReady)
                                return;
                            console.log("value", value);
                            item.sizes[0] = value;
                            root.changed();
                        }
                        onCustomizedChanged: {
                            if (!isReady)
                                return;
                            item.sizes[0] = customized ? value : -1;
                            root.changed();
                        }

                        spinBox {
                            from: 20
                            to: 1000

                            onReady: isReady = true
                        }
                    }

                    RMControls.CustomizableSize {
                        id: graphHeight
                        Kirigami.FormData.label: i18n("Height:")
                        Layout.fillWidth: true
                        property bool isReady: false

                        Component.onCompleted: {
                            if (item.sizes[1] != -1) {
                                value = item.sizes[1];
                                customized = true;
                            } else {
                                customized = false;
                            }
                        }
                        onValueChanged: {
                            if (!isReady)
                                return;
                            console.log("value", value);
                            item.sizes[1] = value;
                            root.changed();
                        }
                        onCustomizedChanged: {
                            if (!isReady)
                                return;
                            item.sizes[1] = customized ? value : -1;
                            root.changed();
                        }

                        spinBox {
                            from: 20
                            to: 1000

                            onReady: isReady = true
                        }
                    }

                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        Kirigami.FormData.label: i18n("Font size:")

                        textRole: "label"
                        valueRole: "value"
                        model: [
                            {
                                label: i18n("Global"),
                                value: -1
                            },
                            ...[6, 7, 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72].map(value => ({
                                        label: String(value),
                                        value: value
                                    }))]

                        Component.onCompleted: currentIndex = indexOfValue(root.item.fontSize)
                        onActivated: {
                            root.item.fontSize = currentValue;
                            root.changed();
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
                        dialogTitle: colorsType[0] === "series" ? _seriesColorTitle : _textColorTitle

                        value: item.color ?? item.colors[0]
                        onValueChanged: {
                            if (item.color) {
                                item.color = value;
                            } else {
                                item.colors[0] = value;
                            }

                            root.changed();
                        }
                    }
                    RMControls.ColorSelector {
                        enabled: colorsType[1]
                        visible: enabled

                        Layout.fillWidth: true
                        Kirigami.FormData.label: i18n("Second Line:")
                        dialogTitle: colorsType[1] === "series" ? _seriesColorTitle : _textColorTitle

                        value: (item.colors && item.colors[1]) ?? ""
                        onValueChanged: {
                            item.colors[1] = value;
                            root.changed();
                        }
                    }
                    RMControls.ColorSelector {
                        enabled: colorsType[2]
                        visible: enabled

                        Layout.fillWidth: true
                        Kirigami.FormData.label: i18n("Third Line:")
                        dialogTitle: colorsType[2] === "series" ? _seriesColorTitle : _textColorTitle

                        value: (item.colors && item.colors[2]) ?? ""
                        onValueChanged: {
                            item.colors[2] = value;
                            root.changed();
                        }
                    }
                }
            }
        }
    }
}
