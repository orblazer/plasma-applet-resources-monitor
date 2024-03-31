import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    // Margin for prevent "invsible" 0 and full lines
    anchors.topMargin: 1
    anchors.bottomMargin: 1

    readonly property int graphVersion: 1 //? Bump when some settings changes in "graphs" structure
    readonly property bool isVertical: {
        switch (Plasmoid.formFactor) {
        case PlasmaCore.Types.Planar:
        case PlasmaCore.Types.MediaCenter:
        case PlasmaCore.Types.Application:
        default:
            if (root.height > root.width) {
                return true;
            } else {
                return false;
            }
        case PlasmaCore.Types.Vertical:
            return true;
        case PlasmaCore.Types.Horizontal:
            return false;
        }
    }
    readonly property double initGraphSize: (isVertical ? root.width : root.height)

    // Settings properties
    property double fontScale: (Plasmoid.configuration.fontScale / 100)
    property var graphsModel: (JSON.parse(Plasmoid.configuration.graphs) || []).filter(v => v._v === graphVersion)
    property string clickAction: Plasmoid.configuration.clickAction

    // Plasma configuration
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.configurationRequired: graphsModel.length === 0 // Check if graphs is valid and have some items
    preferredRepresentation: Plasmoid.configurationRequired ? compactRepresentation : fullRepresentation // Show graphs only if at least 1 is present, otherwise ask to configure
    Plasmoid.constraintHints: Plasmoid.CanFillArea // Allow widget to take all height/width

    // Content
    fullRepresentation: MouseArea {
        acceptedButtons: clickAction !== "none" ? Qt.LeftButton : Qt.NoButton

        // Calculate widget size
        Layout.fillWidth: isVertical
        Layout.minimumWidth: isVertical ? 0 : graphView.itemWidth
        Layout.preferredWidth: graphView.width

        Layout.fillHeight: !isVertical
        Layout.minimumHeight: !isVertical ? 0 : graphView.itemHeight
        Layout.preferredHeight: graphView.height

        // Click action
        Loader {
            id: appLauncher
            active: clickAction === "application"
            source: "./components/AppLauncher.qml"

            function run(url) {
                if (status === Loader.Ready) {
                    item.openUrl(url);
                }
            }
        }
        //? NOTE: This is hacky way for replace "Kio.KRun" due to limitation of access to C++ in widget without deploying package
        //? This have a some limitation due to cannot open applications with `kioclient exec`, `kstart --application` or `xdg-open`.
        Plasma5Support.DataSource {
            id: runner
            engine: "executable"
            connectedSources: []
            onNewData: disconnectSource(sourceName)
        }

        onClicked: {
            if (Plasmoid.configuration.clickActionCommand !== "") {
                if (clickAction === "application") {
                    appLauncher.run(Plasmoid.configuration.clickActionCommand);
                } else {
                    runner.connectSource(Plasmoid.configuration.clickActionCommand);
                }
            }
        }

        // Render
        GraphLayout {
            id: graphView
            model: graphsModel
            updateInterval: Plasmoid.configuration.updateInterval * 1000

            spacing: Plasmoid.configuration.graphSpacing
            flow: isVertical ? Flow.TopToBottom : Flow.LeftToRight

            itemWidth: _getCustomConfig("graphWidth", Math.round(initGraphSize * (isVertical ? 1 : 1.4)))
            itemHeight: _getCustomConfig("graphHeight", initGraphSize)
            fontPixelSize: Math.round(isVertical ? (itemHeight / 1.4 * fontScale) : (itemHeight * fontScale))
        }
    }

    function _getCustomConfig(property, fallback) {
        if (Plasmoid.configuration[`custom${property.charAt(0).toUpperCase() + property.slice(1)}`]) {
            return Plasmoid.configuration[property];
        }
        return fallback;
    }
}
