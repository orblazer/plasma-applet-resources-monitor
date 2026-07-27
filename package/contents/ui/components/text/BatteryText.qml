import QtQuick
import org.kde.plasma.plasmoid
import org.kde.ksysguard.formatter as Formatter
import org.kde.kirigami as Kirigami
import "./base" as RMBase
import "../sensors" as RMSensors
import "../../code/formatter.js" as RMFormatter

RMBase.BaseSensorText {
    id: root
    objectName: "BatteryText"
    sensor.enabled: false // Disable base sensor due to use custom one
    visible: sensorsType[1] ? powerInfo.isPresent : true

    // Configure minimum width
    sensorsFormat: [powerInfo.unit]
    customWidth: textMetics.width
    TextMetrics {
        id: textMetics
        font.family: (Plasmoid.configuration.autoFontAndSize || Plasmoid.configuration.fontFamily.length === 0) ? Kirigami.Theme.defaultFont.family : Plasmoid.configuration.fontFamily
        font.weight: Plasmoid.configuration.autoFontAndSize ? Kirigami.Theme.defaultFont.weight : Plasmoid.configuration.fontWeight
        font.italic: Plasmoid.configuration.autoFontAndSize ? Kirigami.Theme.defaultFont.italic : Plasmoid.configuration.italicText
        font.pixelSize: fontSize == -1 ? (Plasmoid.configuration.autoFontAndSize ? 3 * Kirigami.Theme.defaultFont.pixelSize : _pointToPixel(Plasmoid.configuration.fontSize)) : _pointToPixel(fontSize)
        text: Plasmoid.configuration.abbreviate ? "20.5m" : i18nc("Time: minutes", "%1 minutes", "20.5")
    }

    // Settings
    property string device: "" // Device index (eg: gpu0, gpu1)
    property var thresholds: []

    // Text options
    textContainer {
        thresholdIndex: sensorsType[0] === "percentage" ? 1 : -1
        thresholds: root.thresholds // No change needed, simply map it
        thresholdInverted: true
    }

    // Custom sensor
    RMSensors.PowerInfo {
        id: powerInfo
        device: root.device
        metric: root.sensorsType[0]
    }

    _update: () => {
        const value = powerInfo.value;
        let formattedValue;
        if (powerInfo.metric === "time") {
            formattedValue = formatSeconds(value, Plasmoid.configuration.abbreviate);
        } else {
            if (Plasmoid.configuration.abbreviate) {
                formattedValue = RMFormatter.formatInAbbreviate(value, powerInfo.unit, Qt.locale());
            } else {
                formattedValue = Formatter.Formatter.formatValueShowNull(value, powerInfo.unit);
            }
        }

        let icon = "";
        if (powerInfo.isPlugged) {
            icon = "🗲\u2009";
        }

        textContainer.setValue(1, value, icon + formattedValue);
    }

    function formatSeconds(totalSeconds, abbreviate = false) {
        if (typeof totalSeconds === "undefined" || isNaN(totalSeconds) || totalSeconds <= 0) {
            return "N/A";
        }

        let days = totalSeconds / 86400; // 60 * 60 * 24
        if (days >= 1) {
            // round to 1 decimal (eg. "3.5d")
            days = days.toFixed(1);
            return abbreviate ? i18nc("Time: days", "%1d", days) : i18nc("Time: days", "%1 days", days);
        }

        let hours = totalSeconds / 3600; // 60 * 60
        if (hours >= 1) {
            // round to 1 decimal (eg. "1.5h")
            hours = hours.toFixed(1);
            return abbreviate ? i18nc("Time: hours", "%1h", hours) : i18nc("Time: hours", "%1 hours", hours);
        }

        let minutes = totalSeconds / 60;
        if (minutes >= 1) {
            // round to 1 decimal (eg. "45m")
            minutes = minutes.toFixed(1);
            return abbreviate ? i18nc("Time: minutes", "%1m", minutes) : i18nc("Time: minutes", "%1 minutes", minutes);
        }

        let seconds = Math.round(totalSeconds);
        return abbreviate ? i18nc("Time: seconds", "%1s", seconds) : i18nc("Time: seconds", "%1 seconds", seconds);
    }
}
