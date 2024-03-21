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
 * @returns {BinaryUnit} The binary unit
 */
function getNetworkDialectInfo(dialect) {
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
function formatByteValue(value, dialect, precision = 1) {
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
 * Get customizable config property, fallback to default value if is not customized.
 * @param {string} property The config property name
 * @param {object} fallback The fallback value
 */
function getCustomConfig(property, fallback) {
  if (
    plasmoid.configuration[
      `custom${property.charAt(0).toUpperCase() + property.slice(1)}`
    ]
  ) {
    return plasmoid.configuration[property];
  }
  return fallback;
}

/**
 * Get color, if the value not start with "#" its return the theme color. If property have no value i'ts fallback to "theme.textColor"
 * @param {string} property The config property name
 * @returns The color color
 */
function getColor(property) {
  const value = plasmoid.configuration[property];
  if (value.startsWith("#")) {
    return value;
  }
  return theme[value] || theme.textColor;
}
