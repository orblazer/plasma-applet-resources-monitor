import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import "./code/graphs.js" as GraphFns

PlasmoidItem {
    id: root

    property bool isVertical: {
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

    // Settings properties
    property var graphsModel: GraphFns.parse(Plasmoid.configuration.graphs)
    property string clickAction: Plasmoid.configuration.clickAction

    // Plasma configuration
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground
    Plasmoid.configurationRequired: !graphsModel || graphsModel.length === 0 // Check if graphs is valid and have some items
    preferredRepresentation: Plasmoid.configurationRequired ? compactRepresentation : fullRepresentation // Show graphs only if at least 1 is present, otherwise ask to configure
    Plasmoid.constraintHints: Plasmoid.configuration.fillPanel ? Plasmoid.CanFillArea : Plasmoid.NoHint// Allow widget to take all height/width

    // Margin for prevent "invsible" 0 and full lines when fill panel
    anchors.topMargin: Plasmoid.configuration.fillPanel ? 1 : 0
    anchors.bottomMargin: anchors.topMargin

    // Content
    compactRepresentation: Kirigami.Icon {
        Layout.preferredWidth: width
        Layout.preferredHeight: height

        source: Plasmoid.icon
        width: Kirigami.Units.iconSizes.smallMedium
        height: width
    }
    fullRepresentation: MouseArea {
        acceptedButtons: clickAction !== "none" ? Qt.LeftButton : Qt.NoButton

        // Propagate child size to parent
        Layout.preferredWidth: isVertical ? Kirigami.Units.iconSizes.small : graphView.implicitWidth + Kirigami.Units.smallSpacing
        Layout.preferredHeight: isVertical ? graphView.implicitHeight + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small

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
            onNewData: sourceName => disconnectSource(sourceName)
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
            isVertical: root.isVertical

            parentWidth: parent.width
            parentHeight: parent.height
        }
    }
}
