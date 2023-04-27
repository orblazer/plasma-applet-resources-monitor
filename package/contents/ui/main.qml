/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.7
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kio 1.0 as Kio
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.ksysguard.sensors 1.0 as Sensors
import "./components" as RMComponents
import "./components/functions.js" as Functions

Item {
    id: main

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property color primaryColor: theme.highlightColor
    property color normalColor: theme.textColor
    property color positiveColor: theme.positiveTextColor
    property color neutralColor: theme.neutralTextColor
    property color negativeColor: theme.negativeTextColor

    // Settings properties
    property bool verticalLayout: plasmoid.configuration.verticalLayout
    property string actionService: plasmoid.configuration.actionService

    property bool showCpuMonitor: plasmoid.configuration.showCpuMonitor
    property bool showCpuClock: plasmoid.configuration.showClock
    property bool showCpuTemp: plasmoid.configuration.showCpuTemperature
    property bool showRamMonitor: plasmoid.configuration.showRamMonitor
    property bool showMemoryInPercent: plasmoid.configuration.memoryInPercent
    property bool showSwapGraph: plasmoid.configuration.memorySwapGraph
    property bool showNetMonitor: plasmoid.configuration.showNetMonitor
    property double fontScale: (plasmoid.configuration.fontScale / 100)

    property int thresholdWarningCpuTemp: plasmoid.configuration.thresholdWarningCpuTemp
    property int thresholdCriticalCpuTemp: plasmoid.configuration.thresholdCriticalCpuTemp
    property int thresholdWarningMemory: plasmoid.configuration.thresholdWarningMemory
    property int thresholdCriticalMemory: plasmoid.configuration.thresholdCriticalMemory

    // Colors settings properties
    property color cpuColor: plasmoid.configuration.customCpuColor ? plasmoid.configuration.cpuColor : primaryColor
    property color cpuTemperatureColor: plasmoid.configuration.customCpuTemperatureColor ? plasmoid.configuration.cpuTemperatureColor : normalColor
    property color ramColor: plasmoid.configuration.customRamColor ? plasmoid.configuration.ramColor : primaryColor
    property color swapColor: plasmoid.configuration.customSwapColor ? plasmoid.configuration.swapColor : positiveColor
    property color netDownColor: plasmoid.configuration.customNetDownColor ? plasmoid.configuration.netDownColor : primaryColor
    property color netUpColor: plasmoid.configuration.customNetUpColor ? plasmoid.configuration.netUpColor : positiveColor
    property color warningColor: plasmoid.configuration.customWarningColor ? plasmoid.configuration.warningColor : neutralColor
    property color criticalColor: plasmoid.configuration.customCriticalColor ? plasmoid.configuration.criticalColor : negativeColor

    // Component properties
    property int containerCount: (showCpuMonitor ? 1 : 0) + (showRamMonitor ? 1 : 0) + (showNetMonitor ? 1 : 0)
    property int itemMargin: plasmoid.configuration.graphMargin
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    property double initWidth: vertical ? (verticalLayout ? parentWidth : (parentWidth - itemMargin) / 2) : (verticalLayout ? (parentHeight - itemMargin) / 2 : parentHeight)
    property double itemWidth: plasmoid.configuration.customGraphWidth ? plasmoid.configuration.graphWidth : (initWidth * (verticalLayout ? 1 : 1.5))
    property double itemHeight: plasmoid.configuration.customGraphHeight ? plasmoid.configuration.graphHeight : initWidth
    property double fontPixelSize: verticalLayout ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale)
    property double widgetWidth: !verticalLayout ? (itemWidth * containerCount + itemMargin * containerCount) : itemWidth
    property double widgetHeight: verticalLayout ? (itemHeight * containerCount + itemMargin * containerCount) : itemHeight

    Layout.preferredWidth: widgetWidth
    Layout.maximumWidth: widgetWidth
    Layout.preferredHeight: widgetHeight
    Layout.maximumHeight: widgetHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    anchors.fill: parent

    Kio.KRun {
        id: kRun
    }

    // Bind settigns change
    onFontPixelSizeChanged: {
        for (var monitor of [cpuGraph, ramGraph, netGraph]) {
            monitor.firstLineLabel.font.pixelSize = fontPixelSize;
            monitor.secondLineLabel.font.pixelSize = fontPixelSize;
            monitor.thirdLineLabel.font.pixelSize = fontPixelSize;
        }
    }

    onShowCpuClockChanged: {
        if (!showCpuClock) {
            cpuGraph.secondLineLabel.visible = false;
        }
    }
    onShowCpuTempChanged: {
        if (!showCpuTemp) {
            cpuGraph.thirdLineLabel.visible = false;
        }
    }

    onShowMemoryInPercentChanged: {
        if (ramGraph.maxMemory[0] <= 0 && ramGraph.maxMemory[1] <= 0) {
            return;
        }
        if (showMemoryInPercent) {
            ramGraph.uplimits = [100, 100];
        } else {
            ramGraph.uplimits = ramGraph.maxMemory;
        }
        ramGraph.updateSensors();
    }

    onShowSwapGraphChanged: {
        if (ramGraph.maxMemory[0] >= 0 && ramGraph.maxMemory[1] >= 0) {
            ramGraph.updateSensors();
        }
    }

    onThresholdWarningMemoryChanged: {
        maxMemoryQueryModel.enabled = true;
    }
    onThresholdCriticalMemoryChanged: {
        maxMemoryQueryModel.enabled = true;
    }

    // Graphs
    RMComponents.SensorGraph {
        id: cpuGraph
        sensors: ["cpu/all/usage"]
        colors: [cpuColor]

        visible: showCpuMonitor
        width: itemWidth
        height: itemHeight

        label: "CPU"
        labelColor: cpuColor
        secondLabel: showCpuClock ? i18n("⏲ Clock") : ""
        thirdLabel: showCpuTemp ? i18n("🌡️ Temp.") : ""
        thirdLabelColor: cpuTemperatureColor

        yRange {
            from: 0
            to: 100
        }

        function getCpuTempColor(value) {
            if (value >= thresholdCriticalCpuTemp) {
                return criticalColor;
            } else if (value >= thresholdWarningCpuTemp) {
                return warningColor;
            } else {
                return cpuTemperatureColor;
            }
        }

        // Display first core frequency
        onDataTick: {
            if (!textContainer.valueVisible) {
                return;
            }
            if (showCpuClock) {
                secondLineLabel.text = cpuFrequencySensor.formattedValue;
                secondLineLabel.visible = true;
            }
            if (showCpuTemp) {
                thirdLineLabel.text = cpuTempSensor.formattedValue;
                thirdLineLabel.color = getCpuTempColor(cpuTempSensor.value);
                thirdLineLabel.visible = true;
            }
        }
        Sensors.Sensor {
            id: cpuFrequencySensor
            enabled: showCpuClock
            sensorId: "cpu/all/averageFrequency"
        }
        Sensors.Sensor {
            id: cpuTempSensor
            enabled: showCpuTemp
            sensorId: "cpu/all/averageTemperature"
        }
        onShowValueWhenMouseMove: {
            if (showCpuClock) {
                secondLineLabel.text = cpuFrequencySensor.formattedValue;
                secondLineLabel.visible = true;
            }
            if (showCpuTemp) {
                thirdLineLabel.text = cpuTempSensor.formattedValue;
                thirdLineLabel.color = getCpuTempColor(cpuTempSensor.value);
                thirdLineLabel.visible = true;
            }
        }
    }

    RMComponents.TwoSensorsGraph {
        id: ramGraph
        colors: [ramColor, swapColor]
        thresholdColors: [warningColor, criticalColor]
        secondLabelWhenZero: false

        visible: showRamMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: showCpuMonitor && !verticalLayout ? itemWidth + itemMargin : 0
        anchors.top: parent.top
        anchors.topMargin: showCpuMonitor && verticalLayout ? itemWidth + itemMargin : 0

        label: "RAM"
        labelColor: ramColor
        secondLabel: showSwapGraph ? "Swap" : ""
        secondLabelColor: swapColor

        // Get max y of graph
        property var maxMemory: [-1, -1]
        Sensors.SensorDataModel {
            id: maxMemoryQueryModel
            sensors: ["memory/physical/total", "memory/swap/total"]
            enabled: true

            onDataChanged: {
                // Update values
                var value = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
                if (!isNaN(value) && ramGraph.maxMemory[topLeft.column] === -1) {
                    ramGraph.maxMemory[topLeft.column] = value;
                }

                // Update graph Y range and sensors
                if (ramGraph.maxMemory[0] >= 0 && ramGraph.maxMemory[1] >= 0) {
                    enabled = false;
                    if (!showMemoryInPercent) {
                        ramGraph.uplimits = ramGraph.maxMemory;
                        ramGraph.thresholds[0] = [ramGraph.maxMemory[0] * (thresholdWarningMemory / 100.0), ramGraph.maxMemory[0] * (thresholdCriticalMemory / 100.0)];
                    } else {
                        ramGraph.thresholds[0] = [thresholdWarningMemory, thresholdCriticalMemory];
                    }
                    ramGraph.updateSensors();
                }
            }
        }

        // Set the color of Swap
        onShowValueWhenMouseMove: {
            secondLineLabel.color = swapColor;
        }

        function updateSensors() {
            var suffix = showMemoryInPercent ? "Percent" : "";
            if (showSwapGraph) {
                sensors = ["memory/physical/used" + suffix, "memory/swap/used" + suffix];
            } else {
                sensors = ["memory/physical/used" + suffix];
            }
        }
    }

    RMComponents.NetworkGraph {
        id: netGraph

        colors: [netDownColor, netUpColor]

        visible: showNetMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: (showCpuMonitor && !verticalLayout ? itemWidth + itemMargin : 0) + (showRamMonitor && !verticalLayout ? itemWidth + itemMargin : 0)
        anchors.top: parent.top
        anchors.topMargin: (showCpuMonitor && verticalLayout ? itemWidth + itemMargin : 0) + (showRamMonitor && verticalLayout ? itemWidth + itemMargin : 0)

        label: i18n("⇘ Down")
        labelColor: netDownColor
        secondLabel: i18n("⇗ Up")
        secondLabelColor: netUpColor
    }

    // Click action
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            kRun.openService(actionService);
        }
    }
}
