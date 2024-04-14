import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nc("Config header", "Graphs")
        icon: 'office-chart-line-stacked'
        source: 'config/ConfigGraph.qml'
        includeMargins: false
    }
    ConfigCategory {
        name: i18nc("Config header", "Appearance")
        icon: 'preferences-desktop-color'
        source: 'config/ConfigAppearance.qml'
    }
    ConfigCategory {
        name: i18nc("Config header", "Misc")
        icon: 'preferences-system-other'
        source: 'config/ConfigMisc.qml'
    }
}
