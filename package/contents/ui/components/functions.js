/**
 * Get the usage int percent
 * @param {number} current The current usage
 * @param {number} max The maximum usage
 * @returns The percent of usage
 */
function getPercentUsage(current, max) {
  var x = current / max
  return isNaN(x) ? 0 : Math.min(x, 1)
}

function humanReadableBits(value) {
  if (isNaN(parseInt(value))) {
    return ''
  }

  if (value < 1000) {
    return Math.max(value, 0) + ' bps'
  }

  var i = -1
  var byteUnits = [' kbps', ' Mbps', ' Gbps', ' Tbps', 'Pbps', 'Ebps', 'Zbps', 'Ybps']
  do {
    value = value / 1000
    i++
  } while (value > 1000)


  return (Math.round(Math.max(value, 0) * 10) / 10) + byteUnits[i]
}
