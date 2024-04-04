.pragma library

/**
 * @typedef {object} BinaryUnit
 * @property {"kilobyte"|"kilobit"|"kibibyte"} name The unit name
 * @property {string} symbol The symbol in unit symbol (n Bytes/Bits)
 * @property {string} kiloChar The kilo char
 * @property {number} byteDiff The difference with `byte`
 * @property {number} multiplier The multiplier amount (`1000` for metric and `1024` for binary)
 */

/**
 * Get the unit informations from they name
 * @param {BinaryUnit["name"]} name The unit name
 * @param {function} i18nc The "i18nc" function //? bypass QML limitation
 * @returns {BinaryUnit} The unit informations
 */
function getUnitInfo(name, i18nc = (_ = "", def = "") => def) {
  switch (name) {
    case "kilobyte":
      return {
        name: "kilobyte",
        symbol: i18nc("Bytes per second unit symbol", "Bps"),
        kiloChar: "k",
        byteDiff: 1,
        multiplier: 1000,
      };
    case "kilobit":
      return {
        name: "kilobit",
        symbol: i18nc("Bits per second unit symbol", "bps"),
        kiloChar: "k",
        byteDiff: 8,
        multiplier: 1000,
      };
    default:
      return {
        name: "kibibyte",
        symbol: i18nc("Bytes per second unit symbol", "iB/s"),
        kiloChar: "K",
        byteDiff: 1,
        multiplier: 1024,
      };
  }
}

/**
 * Convert value from bytes to the appropriate string representation using the binary unit.
 *
 * @param {number} value The value in byte/bit
 * @param {BinaryUnit} unit The unit informations
 * @param {object} locale The locale object (ref to: Qt.locale()) //? bypass QML limitation
 * @returns Converted value as a translated string including the units.
 */
function formatValue(value, unit, locale) {
  value = parseFloat(value);
  /* if (isNaN(parseInt(value))) {
    value = 0;
  } */

  // Remove "i" from "iB/s" in case of "kibibyte"
  let unitSymbol = unit.symbol;
  if (unit.name === "kibibyte" && value < unit.multiplier) {
    unitSymbol = unitSymbol.replace("i", "");
  }

  // Search unit conversion
  if (value >= unit.multiplier) {
    const sizes = ["", unit.kiloChar, "M", "G", "T", "P", "Z", "Y"];
    const sizeIndex = Math.floor(Math.log(value) / Math.log(unit.multiplier));

    return (
      Number(value / Math.pow(unit.multiplier, sizeIndex)).toLocaleString(
        locale,
        "f",
        1
      ) +
      " " +
      sizes[sizeIndex] +
      unitSymbol
    );
  }
  return Number(value).toLocaleString(locale, "f", 1) + " " + unitSymbol;
}
