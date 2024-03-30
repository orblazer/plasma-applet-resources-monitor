/**
 * @typedef {object} BinaryUnit
 * @property {string} name The name
 * @property {string} suffix The suffix
 * @property {string} kiloChar The char for "kilo"
 * @property {number} byteDiff The difference with `byte`
 * @property {number} multiplier The multiplier amount (`1000` for metric and `1024` for binary)
 */
/**
 * @typedef {Object.<string, [number, number]>} TransferData The transfer data with format `{"<ifname>": [rx, tx]}`
 */

/**
 * Command retrieve all interface speed with following format (one line per interface and rx/tx in bytes) :
 * - `<ifname>,<rx>,<tx>`
 */
var NET_DATA_SOURCE =
  "awk -v OFS=, 'NR > 2 { print substr($1, 1, length($1)-1), $2, $10 }' /proc/net/dev";

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
        byteDiff: 1,
        multiplier: 1000,
      };
    case "kilobit":
      return {
        name: "kilobit",
        suffix: i18nc("kilobit suffix", "bps"),
        kiloChar: "k",
        byteDiff: 8,
        multiplier: 1000,
      };
    default:
      return {
        name: "kibibyte",
        suffix: i18nc("kibibyte suffix", "iB/s"),
        kiloChar: "K",
        byteDiff: 1,
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

  const sizes = ["", dialect.kiloChar, "M", "G", "T", "P", "Z", "Y"];
  // Search unit conversion
  const unit = Math.floor(Math.log(value) / Math.log(dialect.multiplier));

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
 *
 * @param {string} data The raw transfer data output by {@link NET_DATA_SOURCE}
 * @returns {TransferData} The parsed transfer data
 */
function parseTransferData(data) {
  const transferData = {};
  for (const line of data.trim("\n").split("\n")) {
    const [name, rx, tx] = line.split(",");
    // Skip some interfaces
    if (/^(?:lo|bridge|usbus|bond)(.*)$/.test(name)) {
      continue;
    }
    transferData[name] = [rx, tx];
  }
  return transferData;
}

/**
 * Calculate speed data in kilobytes for {@link duration}
 * @param {TransferData} prevTransferData The transfer data at X moment (in bytes)
 * @param {TransferData} nextTransferData The transfer data at X+{@link duration} moment (in bytes)
 * @param {number} duration The duration elapsed between {@link prevTransferData} and {@link nextTransferData}
 * @returns {TransferData} The speed data for {@link duration}, returned in kilobytes
 */
function calcSpeedData(prevTransferData, nextTransferData, duration) {
  const speedData = {};
  for (const key in nextTransferData) {
    if (prevTransferData && key in prevTransferData) {
      const prev = prevTransferData[key];
      const next = nextTransferData[key];
      speedData[key] = [
        ((next[0] - prev[0]) * 1000) / duration,
        ((next[1] - prev[1]) * 1000) / duration,
      ];
    }
  }
  return speedData;
}
