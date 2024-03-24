/**
 * This contains selectable kirigami colors
 * ? This is for allowing access to `kirigami.Theme` (bypass QML limitation)
 */
const _kirigamiTheme = {
  textColor: "",
  highlightedTextColor: "",
  linkColor: "",
  visitedLinkColor: "",
  negativeTextColor: "",
  neutralTextColor: "",
  positiveTextColor: "",
  backgroundColor: "",
  highlightColor: "",
};
export function init(kirigamiTheme) {
  Object.keys(_kirigamiTheme).forEach(
    (key) => (_kirigamiTheme[key] = kirigamiTheme[key])
  );
}

/**
 * @typedef {object} BinaryUnit
 * @property {string} name The name
 * @property {string} suffix The suffix
 * @property {string} kiloChar The char for "kilo"
 * @property {number} KiBDiff The difference with `kibibyte`
 * @property {number} multiplier The multiplier amount (`1000` for metric and `1024` for binary)
 */

/**
 * Get the binary unit from they name
 * @param {string} dialect The binary unit name
 * @param {function} i18nc The "i18nc" function //? bypass QML limitation
 * @returns {BinaryUnit} The binary unit
 */
export function getNetworkDialectInfo(
  dialect,
  i18nc = (_ = "", def = "") => def
) {
  switch (dialect) {
    case "kilobyte":
      return {
        name: "kilobyte",
        suffix: i18nc("kilobyte suffix", "Bps"),
        kiloChar: "k",
        KiBDiff: 1.024,
        multiplier: 1024,
      };
    case "kilobit":
      return {
        name: "kilobit",
        suffix: i18nc("kilobit suffix", "bps"),
        kiloChar: "k",
        KiBDiff: 8,
        multiplier: 1024,
      };
    default:
      return {
        name: "kibibyte",
        suffix: i18nc("kibibyte suffix", "iB/s"),
        kiloChar: "K",
        KiBDiff: 1,
        multiplier: 1024,
      };
  }
}

/**
 * Convert value from bytes to the appropriate string representation using the binary unit dialect.
 *
 * @param {number} value The value in byte/bit
 * @param {BinaryUnit} dialect The binary unit standard to use
 * @param {number} [precision=1] Number of places after the decimal point to use.
 * @returns Converted value as a translated string including the units.
 */
export function formatByteValue(value, dialect, precision = 1) {
  if (value === 0 || isNaN(parseInt(value))) {
    return "0 " + dialect.suffix.replace("i", "");
  } else if (dialect.name === "kibibyte" && value <= dialect.multiplier) {
    return "0 " + dialect.suffix.replace("i", "");
  }

  var sizes = ["", dialect.kiloChar, "M", "G", "T", "P", "Z", "Y"];

  // Search unit conversion
  var unit = Math.floor(Math.log(value) / Math.log(dialect.multiplier));

  // Bytes/Bits, no rounding
  precision = precision < 0 ? 0 : precision;
  if (unit === 0) {
    precision = 0;
  }

  return (
    parseFloat(
      (value / Math.pow(dialect.multiplier, unit)).toFixed(precision)
    ) +
    " " +
    sizes[unit] +
    dialect.suffix
  );
}

/**
 * Resolve color when is name based
 * @param {string} color The color value
 * @returns The color color
 */
export function resolveColor(color) {
  if (color.startsWith("#")) {
    return color;
  }
  return _kirigamiTheme[color] || _kirigamiTheme.textColor;
}
