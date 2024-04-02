/**
 * Version of graphs
 * @constant
 */
const VERSION = 1; //? Bump when some settings changes in graphs structure

/**
 * @typedef {object} CpuGraph
 * @property {number} _v The version of graph
 * @property {"cpu"} type The graph type
 * @property {[string, string, string]} colors The graph colors (ref: usage, clock, temperature)
 * @property {[("usage"|"system"|"user"), ("none"|"classic"|"ecores"), boolean]} sensorsType The sensors type (ref: usage, clock, temperature)
 * @property {[number, number]} thresholds The temperature thresholds
 * @property {"average"|"minimum"|"maximum"} clockAggregator The clock aggregator
 * @property {number} eCoresCount The e-cores count
 */
/**
 * @typedef {object} MemoryGraph
 * @property {number} _v The version of graph
 * @property {"memory"} type The graph type
 * @property {[string, string]} colors The graph colors (ref: color, swap)
 * @property {[("physical"|"physical-percent"|"application"|"application-percent"), ("none"|"swap"|"swap-percent"|"memory-percent")]} sensorsType The sensors type (ref: memory, swap)
 * @property {[number, number]} thresholds The usage thresholds
 */
/**
 * @typedef {object} GpuGraph
 * @property {number} _v The version of graph
 * @property {"gpu"} type The graph type
 * @property {[string, string, string]} colors The graph colors (ref: usage, memory, temperature)
 * @property {[("none"|"memory"|"memory-percent"), boolean]} sensorsType The sensors type (ref: memory, temperature)
 * @property {[number, number]} thresholds The temperature thresholds
 * @property {string} device The device index (eg. gpu0, gpu1)
 */
/**
 * @typedef {object} NetworkGraph
 * @property {number} _v The version of graph
 * @property {"network"} type The graph type
 * @property {[string, string]} colors The graph colors (ref: receiving, sending)
 * @property {[boolean, ("kibibyte"|"kilobit|"kilobyte")]} sensorsType The sensors type (ref: swap Rx/Tx, dialect)
 * @property {[number, number]} uplimits The uplimit (ref: chart1, chart2)
 * @property {string[]} ignoredInterfaces The ignored network interfaces
 */
/**
 * @typedef {object} DiskGraph
 * @property {number} _v The version of graph
 * @property {"disk"} type The graph type
 * @property {[string, string]} colors The graph colors (ref: read, write)
 * @property {[boolean]} sensorsType The sensors type (ref: swap r/w)
 * @property {[number, number]} uplimits The uplimit (ref: chart1, chart2)
 * @property {string} device The disk id (eg. sda, sdc), it also could be `all`
 */

/** @typedef {CpuGraph|MemoryGraph|GpuGraph|NetworkGraph|DiskGraph} Graph */
/**
 * @typedef {object} GraphInfo
 * @property {string|(string)=>string} name The graph name
 * @property {string} icon the graph icon
 */

/**
 * Parse json string to graph array
 * @param {string} raw The raw graphs value (in json string)
 * @param {boolean} convertOld Convert old  graphs to new version
 * @returns {Graph[]} The parsed graph
 */
function parse(raw, convertOld = false) {
  /** @type {Graph[]} */
  const graphs = JSON.parse(raw);

  // Check if versions is identic or if is empty (skip conversion in that cases)
  if (graphs.length === 0 || graphs[0]._v === VERSION) {
    return graphs;
  }

  if (!convertOld) {
    return graphs.filter((v) => v._v === VERSION);
  }

  // Mark first item as changed
  if (graphs[0]._v !== VERSION) {
    graphs[0]._changed = true;
  }

  // Handle conversion
  return graphs.map((v) => {
    v._v = VERSION;
    return v;
  });
}

/**
 * Stringify the graphs array
 * @param {Graph[]} graphs The graphs array
 * @returns {string} The stringified array
 */
function stringify(graphs) {
  if (graphs.length > 0 && graphs[0]._changed) {
    delete graphs[0]._changed;
  }

  return JSON.stringify(graphs);
}

/**
 * Create new graph with given type and device
 * @param {Graph["type"]} type The graph type
 * @param {string} [device] The device
 * @returns {Graph} The created graph
 */
function create(type, device) {
  /** @type {Graph} */
  let item = {
    _v: VERSION,
    type,
  };

  // Fill default value
  switch (type) {
    case "cpu":
      item.colors = ["highlightColor", "textColor", "textColor"];
      item.sensorsType = ["usage", "clock", false];
      item.thresholds = [85, 105];
      item.clockAggregator = "average";
      item.eCoresCount = "";
      break;
    case "memory":
      item.colors = ["highlightColor", "negativeTextColor"];
      item.sensorsType = ["physical", "swap"];
      item.thresholds = [70, 90];
      break;
    case "gpu":
      item.colors = ["highlightColor", "positiveTextColor", "textColor"];
      item.sensorsType = ["memory", false];
      item.thresholds = [70, 90];
      break;
    case "network":
      item.colors = ["highlightColor", "positiveTextColor"];
      item.sensorsType = [false, "kibibyte"];
      item.uplimits = [100000, 100000];
      item.ignoredInterfaces = [];
      break;
    case "disk":
      item.colors = ["highlightColor", "positiveTextColor"];
      item.sensorsType = [false];
      item.uplimits = [200000, 200000];
      break;
    default:
      throw new Error(`${type} is not valid graph type`);
  }

  // Fill device
  if (type === "gpu" || type === "disk") {
    if (!device?.trim()) {
      throw new Error(`Device is required for ${type} graph`);
    }
    item.device = device;
  }

  return item;
}

/**
 * Retrieve graph informations (name and icon)
 * @param {Graph["type"]} type The graph
 * @returns {GraphInfo|null} The informations
 */
function getInfo(type) {
  switch (type) {
    case "cpu":
      return {
        name: i18nc("Chart name", "CPU"),
        icon: "cpu-symbolic",
      };
    case "memory":
      return {
        name: i18nc("Chart name", "Memory"),
        icon: "memory-symbolic",
      };
    case "gpu":
      return {
        name: (name) => i18nc("Chart name", "GPU [%1]", name),
        icon: "freon-gpu-temperature-symbolic",
      };
    case "network":
      return {
        name: i18nc("Chart name", "Network"),
        icon: "network-wired-symbolic",
      };
    case "disk":
      return {
        name: (name) => i18nc("Chart name", "Disk I/O [%1]", name),
        icon: "drive-harddisk-symbolic",
      };
    default:
      console.error(`${type} is not valid graph type`);
      return null;
  }
}
