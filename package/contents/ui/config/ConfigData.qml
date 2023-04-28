import QtQuick 2.2
import QtQuick.Controls 2.12 as QtControls
import QtQuick.Layouts 1.1 as QtLayouts
import org.kde.kirigami 2.6 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../components" as RMComponents
import "../controls" as RMControls
import "../components/functions.js" as Functions

PlasmaExtras.Representation {
    id: dataPage
    anchors.fill: parent

    signal configurationChanged

    readonly property var networkDialect: Functions.getNetworkDialectInfo(plasmoid.configuration.networkUnit)
    property double cfg_networkReceivingTotal: 0.0
    property double cfg_networkSendingTotal: 0.0
    property double cfg_diskReadTotal: 0.0
    property double cfg_diskWriteTotal: 0.0

    property double cfg_thresholdWarningCpuTemp: 0
    property double cfg_thresholdCriticalCpuTemp: 0
    property alias cfg_thresholdWarningMemory: thresholdWarningMemory.value
    property alias cfg_thresholdCriticalMemory: thresholdCriticalMemory.value
    property double cfg_thresholdWarningGpuTemp: 0
    property double cfg_thresholdCriticalGpuTemp: 0

    readonly property var networkSpeedOptions: [{
            "label": i18n("Custom"),
            "value": -1
        }, {
            "label": "100 " + networkDialect.kiloChar + networkDialect.suffix,
            "value": 100.0
        }, {
            "label": "1 M" + networkDialect.suffix,
            "value": 1000.0
        }, {
            "label": "10 M" + networkDialect.suffix,
            "value": 10000.0
        }, {
            "label": "100 M" + networkDialect.suffix,
            "value": 100000.0
        }, {
            "label": "1 G" + networkDialect.suffix,
            "value": 1000000.0
        }, {
            "label": "2.5 G" + networkDialect.suffix,
            "value": 2500000.0
        }, {
            "label": "5 G" + networkDialect.suffix,
            "value": 5000000.0
        }, {
            "label": "10 G" + networkDialect.suffix,
            "value": 10000000.0
        }]
    readonly property var diskSpeedOptions: [{
            "label": i18n("Custom"),
            "value": -1
        }, {
            "label": "10 MiB/s",
            "value": 10000.0
        }, {
            "label": "100 MiB/s",
            "value": 100000.0
        }, {
            "label": "200 MiB/s",
            "value": 200000.0
        }, {
            "label": "500 MiB/s",
            "value": 500000.0
        }, {
            "label": "1 GiB/s",
            "value": 1000000.0
        }, {
            "label": "2 GiB/s",
            "value": 2000000.0
        }, {
            "label": "5 GiB/s",
            "value": 5000000.0
        }, {
            "label": "10 GiB/s",
            "value": 10000000.0
        }]

    // Detect network interfaces
    RMComponents.NetworkInterfaceDetector {
        id: networkInterfaces
    }

    // Tab bar
    header: PlasmaExtras.PlasmoidHeading {
        location: PlasmaExtras.PlasmoidHeading.Location.Header
        PlasmaComponents.TabBar {
            id: bar
            currentIndex: swipeView.currentIndex

            position: PlasmaComponents.TabBar.Header
            anchors.fill: parent
            implicitHeight: contentHeight

            PlasmaComponents.TabButton {
                Accessible.onPressAction: clicked()
                icon.name: "preferences-system-network"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("Network")
                onClicked: {
                    swipeView.currentIndex = 0;
                }
            }
            PlasmaComponents.TabButton {
                Accessible.onPressAction: clicked()
                icon.name: "drive-harddisk"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("Disk I/O")
                onClicked: {
                    swipeView.currentIndex = 1;
                }
            }
            PlasmaComponents.TabButton {
                Accessible.onPressAction: clicked()
                icon.name: "dialog-warning"
                icon.height: PlasmaCore.Units.iconSizes.smallMedium
                text: i18n("Thresholds")
                onClicked: {
                    swipeView.currentIndex = 2;
                }
            }
        }
    }

    PlasmaComponents.SwipeView {
        id: swipeView
        anchors.fill: parent

        activeFocusOnTab: false
        clip: true

        // Network
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                wideMode: true

                // Network interfaces
                QtLayouts.GridLayout {
                    Kirigami.FormData.label: i18n("Network interfaces:")
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    Repeater {
                        model: networkInterfaces.model
                        QtControls.CheckBox {
                            readonly property string interfaceName: modelData
                            readonly property bool ignoredByDefault: {
                                return /^(docker|tun|tap)(\d+)/.test(interfaceName); // Ignore docker and tun/tap networks
                            }

                            text: interfaceName
                            checked: plasmoid.configuration.ignoredNetworkInterfaces.indexOf(interfaceName) == -1 && !ignoredByDefault
                            enabled: !ignoredByDefault

                            onClicked: {
                                var ignoredNetworkInterfaces = plasmoid.configuration.ignoredNetworkInterfaces.slice(0); // copy()
                                if (checked) {
                                    // Checking, and thus removing from the ignoredNetworkInterfaces
                                    var i = ignoredNetworkInterfaces.indexOf(interfaceName);
                                    ignoredNetworkInterfaces.splice(i, 1);
                                } else {
                                    // Unchecking, and thus adding to the ignoredNetworkInterfaces
                                    ignoredNetworkInterfaces.push(interfaceName);
                                }
                                plasmoid.configuration.ignoredNetworkInterfaces = ignoredNetworkInterfaces;
                                // To modify a StringList we need to manually trigger configurationChanged.
                                dataPage.configurationChanged();
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    height: Kirigami.Units.largeSpacing * 2
                    color: "transparent"
                }

                PlasmaComponents.Label {
                    text: i18n("Maximum transfer speed")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
                }

                // Separator
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }

                // Receiving speed
                QtControls.ComboBox {
                    id: networkReceivingTotal
                    Kirigami.FormData.label: i18n("Receiving:")
                    textRole: "label"
                    model: networkSpeedOptions

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current && current.value !== -1) {
                            customNetworkReceivingTotal.valueReal = current.value / 1000;
                        }
                    }

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["value"] === plasmoid.configuration.networkReceivingTotal) {
                                networkReceivingTotal.currentIndex = i;
                                return;
                            }
                        }
                        networkReceivingTotal.currentIndex = 0; // Custom
                    }
                }
                RMControls.SpinBox {
                    id: customNetworkReceivingTotal
                    Kirigami.FormData.label: i18n("Custom value:")
                    QtLayouts.Layout.fillWidth: true
                    decimals: 3
                    stepSize: 1
                    minimumValue: 0.001
                    visible: networkReceivingTotal.currentIndex === 0

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + " M" + networkDialect.suffix;
                    }

                    onValueChanged: {
                        var newValue = valueReal * 1000;
                        if (cfg_networkReceivingTotal !== newValue) {
                            cfg_networkReceivingTotal = newValue;
                            dataPage.configurationChanged();
                        }
                    }
                    Component.onCompleted: {
                        valueReal = parseFloat(plasmoid.configuration.networkReceivingTotal) / 1000;
                    }
                }

                // Separator
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }

                // Sending speed
                QtControls.ComboBox {
                    id: networkSendingTotal
                    Kirigami.FormData.label: i18n("Sending:")
                    textRole: "label"
                    model: networkSpeedOptions

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current && current.value !== -1) {
                            customNetworkSendingTotal.valueReal = current.value / 1000;
                        }
                    }

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["value"] === plasmoid.configuration.networkSendingTotal) {
                                networkSendingTotal.currentIndex = i;
                                return;
                            }
                        }
                        networkSendingTotal.currentIndex = 0; // Custom
                    }
                }
                RMControls.SpinBox {
                    id: customNetworkSendingTotal
                    Kirigami.FormData.label: i18n("Custom value:")
                    QtLayouts.Layout.fillWidth: true
                    decimals: 3
                    stepSize: 1
                    minimumValue: 0.001
                    visible: networkSendingTotal.currentIndex === 0

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + " M" + networkDialect.suffix;
                    }

                    onValueChanged: {
                        var newValue = valueReal * 1000;
                        if (cfg_networkSendingTotal !== newValue) {
                            cfg_networkSendingTotal = newValue;
                            dataPage.configurationChanged();
                        }
                    }
                    Component.onCompleted: {
                        valueReal = parseFloat(plasmoid.configuration.networkSendingTotal) / 1000;
                    }
                }
            }
        }

        // Disk I/O
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                wideMode: true

                PlasmaComponents.Label {
                    text: i18n("Maximum transfer speed")
                    font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
                }

                // Separator
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }

                // Read speed
                QtControls.ComboBox {
                    id: diskReadTotal
                    Kirigami.FormData.label: i18n("Read:")
                    textRole: "label"
                    model: diskSpeedOptions

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current && current.value !== -1) {
                            customDiskReadTotal.valueReal = current.value / 1000;
                        }
                    }

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["value"] === plasmoid.configuration.diskReadTotal) {
                                diskReadTotal.currentIndex = i;
                                return;
                            }
                        }
                        diskReadTotal.currentIndex = 0; // Custom
                    }
                }
                RMControls.SpinBox {
                    id: customDiskReadTotal
                    Kirigami.FormData.label: i18n("Custom value:")
                    QtLayouts.Layout.fillWidth: true
                    decimals: 3
                    stepSize: 1
                    minimumValue: 0.001
                    visible: diskReadTotal.currentIndex === 0

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + " MiB/s";
                    }

                    onValueChanged: {
                        var newValue = valueReal * 1000;
                        if (cfg_diskReadTotal !== newValue) {
                            cfg_diskReadTotal = newValue;
                            dataPage.configurationChanged();
                        }
                    }
                    Component.onCompleted: {
                        valueReal = parseFloat(plasmoid.configuration.diskReadTotal) / 1000;
                    }
                }

                // Separator
                Rectangle {
                    height: Kirigami.Units.largeSpacing
                    color: "transparent"
                }

                // Write speed
                QtControls.ComboBox {
                    id: diskWriteTotal
                    Kirigami.FormData.label: i18n("Write:")
                    textRole: "label"
                    model: diskSpeedOptions

                    onCurrentIndexChanged: {
                        var current = model[currentIndex];
                        if (current && current.value !== -1) {
                            customDiskWriteTotal.valueReal = current.value / 1000;
                        }
                    }

                    Component.onCompleted: {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i]["value"] === plasmoid.configuration.diskWriteTotal) {
                                diskWriteTotal.currentIndex = i;
                                return;
                            }
                        }
                        diskWriteTotal.currentIndex = 0; // Custom
                    }
                }
                RMControls.SpinBox {
                    id: customDiskWriteTotal
                    Kirigami.FormData.label: i18n("Custom value:")
                    QtLayouts.Layout.fillWidth: true
                    decimals: 3
                    stepSize: 1
                    minimumValue: 0.001
                    visible: diskWriteTotal.currentIndex === 0

                    textFromValue: function (value, locale) {
                        return valueToText(value, locale) + " MiB/s";
                    }

                    onValueChanged: {
                        var newValue = valueReal * 1000;
                        if (cfg_diskWriteTotal !== newValue) {
                            cfg_diskWriteTotal = newValue;
                            dataPage.configurationChanged();
                        }
                    }
                    Component.onCompleted: {
                        valueReal = parseFloat(plasmoid.configuration.diskWriteTotal) / 1000;
                    }
                }
            }
        }

        // Threshold
        Kirigami.ScrollablePage {
            Kirigami.FormLayout {
                wideMode: true

                QtLayouts.GridLayout {
                    QtLayouts.Layout.fillWidth: true
                    columns: 3
                    columnSpacing: Kirigami.Units.largeSpacing

                    PlasmaComponents.Label {
                        id: warningText
                        text: i18n("Warning")
                        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
                    }

                    // Separator
                    Rectangle {
                        width: thresholdWarningMemory.implicitWidth - warningText.contentWidth - Kirigami.Units.largeSpacing
                        color: "transparent"
                    }

                    PlasmaComponents.Label {
                        text: i18n("Critical")
                        font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.2
                    }
                }

                // CPU Temperature
                QtLayouts.GridLayout {
                    Kirigami.FormData.label: i18n("CPU Temperature:")
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    RMControls.SpinBox {
                        id: thresholdWarningCpuTemp
                        Kirigami.FormData.label: i18n("Warning")
                        QtLayouts.Layout.fillWidth: true
                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                        onValueChanged: {
                            if (cfg_thresholdWarningCpuTemp !== valueReal) {
                                cfg_thresholdWarningCpuTemp = valueReal;
                                dataPage.configurationChanged();
                            }
                        }
                        Component.onCompleted: {
                            valueReal = parseFloat(plasmoid.configuration.thresholdWarningCpuTemp);
                        }
                    }
                    RMControls.SpinBox {
                        id: thresholdCriticalCpuTemp
                        Kirigami.FormData.label: i18n("Critical")
                        QtLayouts.Layout.fillWidth: true
                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                        onValueChanged: {
                            if (cfg_thresholdCriticalCpuTemp !== valueReal) {
                                cfg_thresholdCriticalCpuTemp = valueReal;
                                dataPage.configurationChanged();
                            }
                        }
                        Component.onCompleted: {
                            valueReal = parseFloat(plasmoid.configuration.thresholdCriticalCpuTemp);
                        }
                    }
                }

                // Memory usage
                QtLayouts.GridLayout {
                    Kirigami.FormData.label: i18n("Physical Memory Usage:")
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    RMControls.SpinBox {
                        id: thresholdWarningMemory
                        Kirigami.FormData.label: i18n("Warning")
                        QtLayouts.Layout.fillWidth: true

                        textFromValue: function (value, locale) {
                            return value + " %";
                        }
                    }
                    RMControls.SpinBox {
                        id: thresholdCriticalMemory
                        Kirigami.FormData.label: i18n("Critical")
                        QtLayouts.Layout.fillWidth: true

                        textFromValue: function (value, locale) {
                            return value + " %";
                        }
                    }
                }

                // GPU Temperature
                QtLayouts.GridLayout {
                    Kirigami.FormData.label: i18n("GPU Temperature:")
                    QtLayouts.Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.largeSpacing

                    RMControls.SpinBox {
                        id: thresholdWarningGpuTemp
                        Kirigami.FormData.label: i18n("Warning")
                        QtLayouts.Layout.fillWidth: true
                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                        onValueChanged: {
                            if (cfg_thresholdWarningGpuTemp !== valueReal) {
                                cfg_thresholdWarningGpuTemp = valueReal;
                                dataPage.configurationChanged();
                            }
                        }
                        Component.onCompleted: {
                            valueReal = parseFloat(plasmoid.configuration.thresholdWarningGpuTemp);
                        }
                    }
                    RMControls.SpinBox {
                        id: thresholdCriticalGpuTemp
                        Kirigami.FormData.label: i18n("Critical")
                        QtLayouts.Layout.fillWidth: true
                        decimals: 1
                        stepSize: 1
                        minimumValue: 0.1
                        maximumValue: 120

                        textFromValue: function (value, locale) {
                            return valueToText(value, locale) + " °C";
                        }
                        onValueChanged: {
                            if (cfg_thresholdCriticalGpuTemp !== valueReal) {
                                cfg_thresholdCriticalGpuTemp = valueReal;
                                dataPage.configurationChanged();
                            }
                        }
                        Component.onCompleted: {
                            valueReal = parseFloat(plasmoid.configuration.thresholdCriticalGpuTemp);
                        }
                    }
                }
            }
        }
    }
}
