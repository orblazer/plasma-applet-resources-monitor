import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import "./controls" as RMControls

KCM.SimpleKCM {
    id: root

    // Config properties
    property alias cfg_updateInterval: updateInterval.realValue
    property alias cfg_clickApplication: applicationDialog.currentUrl

    // Retrieve available applications
    AvailableApplicationsProxy {
        id: availableApplications

        onLoaded: {
            const index = findByUrl(cfg_clickApplication);
            if (index !== -1) {
                appSelector.application = get(index);
            }
        }
    }

    Kirigami.FormLayout {
        RMControls.SpinBox {
            id: updateInterval
            Kirigami.FormData.label: i18n("Update interval:")
            Layout.fillWidth: true

            decimals: 1
            realFrom: 0.1
            realTo: 3600.0
            stepSize: decimalToInt(0.1)

            textFromValue: (value, locale) => i18n("%1 seconds", formatValue(value, locale))
        }

        // Click action
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Click action")
            Kirigami.FormData.isSection: true
        }
        QQC2.ComboBox {
            id: clickAction
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("Chart config", "Type:")

            model: [i18n("Disabled"), i18n("Application")]

            Component.onCompleted: {
                if (cfg_clickApplication == "") {
                    currentIndex = 0
                } else {
                    currentIndex = 1
                }
            }
            onActivated: {
                if (currentIndex == 1) {
                    cfg_clickApplication = "file:///usr/share/applications/org.kde.plasma-systemmonitor.desktop"
                } else {
                    cfg_clickApplication = ""
                }
            }
        }

        // > Button
        QQC2.Button {
            id: appSelector
            visible: clickAction.currentIndex == 1
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("Chart config", "Application:")
            onClicked: applicationDialog.open()

            property var application

            text: application ? application.name : i18nc("@title:window", "Choose application...")
            icon.name: application?.icon

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18nc("@info:tooltip", "Click to select another application")
        }
    }

    // Application dialog
    RMControls.AppSelectorDialog {
        id: applicationDialog
        sourceModel: availableApplications

        width: root.width - Kirigami.Units.gridUnit * 4
        height: root.height - Kirigami.Units.gridUnit * 4

        onSelected: item => {
            appSelector.application = item;
            cfg_clickApplication = item.url;
        }
    }

    //#region // HACK: Present to suppress errors (https://bugs.kde.org/show_bug.cgi?id=494417 / https://invent.kde.org/plasma/plasma-desktop/-/merge_requests/2913)
    property var cfg_abbreviate
    property var cfg_abbreviateDefault
    property var cfg_autoFontAndSize
    property var cfg_autoFontAndSizeDefault
    property var cfg_boldText
    property var cfg_boldTextDefault
    property var cfg_clickApplicationDefault
    property var cfg_criticalColor
    property var cfg_criticalColorDefault
    property var cfg_displayment
    property var cfg_displaymentDefault
    property var cfg_enableShadows
    property var cfg_enableShadowsDefault
    property var cfg_fillPanel
    property var cfg_fillPanelDefault
    property var cfg_fontFamily
    property var cfg_fontFamilyDefault
    property var cfg_fontSize
    property var cfg_fontSizeDefault
    property var cfg_fontStyleName
    property var cfg_fontStyleNameDefault
    property var cfg_fontWeight
    property var cfg_fontWeightDefault
    property var cfg_graphFillOpacity
    property var cfg_graphFillOpacityDefault
    property var cfg_graphSpacing
    property var cfg_graphSpacingDefault
    property var cfg_graphs
    property var cfg_graphsDefault
    property var cfg_historyAmount
    property var cfg_historyAmountDefault
    property var cfg_italicText
    property var cfg_italicTextDefault
    property var cfg_keepFontSize
    property var cfg_keepFontSizeDefault
    property var cfg_placement
    property var cfg_placementDefault
    property var cfg_textColor
    property var cfg_textColorDefault
    property var cfg_updateIntervalDefault
    property var cfg_warningColor
    property var cfg_warningColorDefault
    //#endregion
}
