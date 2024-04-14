.pragma library

/**
 * Command retrieve all interface speed with following format (one line per interface and rx/tx in bytes) :
 * - `<ifname>,<rx>,<tx>`
 */
const NET_DATA_SOURCE =
  "awk -v OFS=, 'NR > 2 { print substr($1, 1, length($1)-1), $2, $10 }' /proc/net/dev";

/**
 * @typedef {Object.<string, [number, number]>} TransferData The transfer data with format `{"<ifname>": [rx, tx]}`
 */

/**
 *
 * @param {string} data The raw transfer data output by {@link NET_DATA_SOURCE}
 * @returns {TransferData} The parsed transfer data
 */
function parseTransferData(data) {
  const transferData = {};
  for (const line of data.trim("\n").split("\n")) {
    const [name, rx, tx] = line.split(",");
    // Skip loopback interface
    if (name === "lo") {
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
