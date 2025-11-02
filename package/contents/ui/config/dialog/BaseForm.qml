import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../controls" as RMControls

// TODO: use tab bar
Kirigami.ScrollablePage {
    signal changed // Notify some settings as been changed

    required property var item
    property alias properties: propertiesLoader.sourceComponent

    property var colorsType: ["series", "text", "text"]
    property string _seriesColorTitle: i18nc("Chart color", "Choose series color")
    property string _textColorTitle: i18nc("Chart color", "Choose text color")

    ColumnLayout {
        anchors.centerIn: parent

        // Properties
        Loader {
            id: propertiesLoader
        }

        Kirigami.FormLayout {
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
