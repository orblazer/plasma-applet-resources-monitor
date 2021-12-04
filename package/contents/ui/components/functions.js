/**
 * Get the usage int percent
 * @param {number} current The current usage
 * @param {number} max The maximum usage
 * @returns The percent of usage
 */
function getPercentUsage(current, max) {
  var x = current / max;
  return isNaN(x) ? 0 : Math.min(x, 1);
}

function getNetworkUnit(type) {
  switch (type) {
    case "kilobyte":
      return {
        suffix: i18nc("kilobyte suffix", "Bps"),
        KiBDiff: 1.024,
        multiplier: 1024,
      };
    case "kilobit":
      return {
        suffix: i18nc("kilobit suffix", "bps"),
        KiBDiff: 8.192,
        multiplier: 1024,
      };
    default:
      return {
        suffix: i18nc("kibibyte suffix", "iB/s"),
        KiBDiff: 1,
        multiplier: 1024,
      };
  }
}

function getSpeedOptions(type) {
  var unit = getNetworkUnit(type);

  return [
    {
      label: i18n("Custom"),
      value: -1.0,
    },
    {
      label: "100 K" + unit.suffix,
      value: 100 * unit.KiBDiff,
      rawValue: 0.1,
    },
    {
      label: "1 M" + unit.suffix,
      value: 1000 * unit.KiBDiff,
      rawValue: 1.0,
    },
    {
      label: "10 M" + unit.suffix,
      value: 10000 * unit.KiBDiff,
      rawValue: 10.0,
    },
    {
      label: "100 M" + unit.suffix,
      value: 100000 * unit.KiBDiff,
      rawValue: 100.0,
    },
    {
      label: "1 G" + unit.suffix,
      value: 1000000 * unit.KiBDiff,
      rawValue: 1000.0,
    },
    {
      label: "2.5 G" + unit.suffix,
      value: 2500000 * unit.KiBDiff,
      rawValue: 2500.0,
    },
    {
      label: "5 G" + unit.suffix,
      value: 5000000 * unit.KiBDiff,
      rawValue: 5000.0,
    },
    {
      label: "10 G" + unit.suffix,
      value: 10000000 * unit.KiBDiff,
      rawValue: 10000.0,
    },
  ];
}

function humanReadableNetworkSpeed(kibibytes, decimals = 2, type = "kibibyte") {
  var unit = getNetworkUnit(type);

  if (kibibytes === 0 || isNaN(parseInt(kibibytes))) {
    return 0 + " " + unit.suffix.replace("i", "");
  }

  // Convert from kibibyte to right unit
  var value = kibibytes * 1024 * unit.KiBDiff;

  decimals = decimals < 0 ? 0 : decimals;
  var sizes = [
    unit.suffix,
    (type === "kibibyte" ? "K" : "k") + unit.suffix,
    "M" + unit.suffix,
    "G" + unit.suffix,
    "T" + unit.suffix,
    "P" + unit.suffix,
    "Z" + unit.suffix,
    "Y" + unit.suffix,
  ];

  var i = Math.floor(Math.log(value) / Math.log(unit.multiplier));
  return (
    parseFloat((value / Math.pow(unit.multiplier, i)).toFixed(decimals)) +
    " " +
    sizes[i]
  );
}
