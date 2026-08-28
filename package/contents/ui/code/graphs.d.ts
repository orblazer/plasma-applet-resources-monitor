type ByteUnit = "kibibyte" | "kilobit" | "kilobyte";
type Thresholds = [number, number];

interface Base {
  /** The version of graph */
  _v: number;
  /** The graph size ([width, height], -1 = automatic) */
  sizes: [number, number];
  /** The font size */
  fontSize: number;
}

interface Titled {
  /** The title of graph */
  title: string;
  /** The option when title is displayed */
  titleWhen: "always" | "hints" | "never";
}

export interface CpuGraph extends Base {
  /** The graph type */
  type: "cpu";
  /** The graph colors (ref: usage, clock, temperature) */
  colors: [string, string, string];
  /** The sensors type (ref: usage, clock, temperature) */
  sensorsType: [
    "usage" | "system" | "user",
    "none" | "classic" | "ecores",
    boolean,
  ];
  /** The temperature thresholds */
  thresholds: Thresholds;
  /** The clock aggregator */
  clockAggregator: "average" | "minimum" | "maximum";
  /** The e-cores count */
  eCoresCount: number;
}
export interface CpuText extends Base, Titled {
  /** The graph type */
  type: "cpuText";
  /** The graph colors (ref: label, usage) */
  colors: [string, string];
  /** The sensors type (ref: usage) */
  sensorsType: ["usage" | "system" | "user" | "temperature"];
}

export interface MemoryGraph extends Base {
  /** The graph type */
  type: "memory";
  /** The graph colors (ref: color, swap) */
  colors: [string, string];
  /** The sensors type (ref: memory, swap) */
  sensorsType: [
    (
      | "physical"
      | "physical-percent"
      | "application"
      | "application-percent"
      | "swap"
      | "swap-percent"
    ),
    (
      | "none"
      | "physical"
      | "physical-percent"
      | "application"
      | "application-percent"
      | "swap"
      | "swap-percent"
    ),
  ];
  /** The usage thresholds */
  thresholds: Thresholds;
}
export interface MemoryText extends Base, Titled {
  /** The graph type */
  type: "memoryText";
  /** The graph colors (ref: label, usage) */
  colors: [string, string];
  /** The sensors type (ref: usage) */
  sensorsType: [
    "physical" | "physical-percent" | "application" | "application-percent",
  ];
}

export interface GpuGraph extends Base {
  /** The graph type */
  type: "gpu";
  /** The graph colors (ref: usage, memory, temperature) */
  colors: [string, string, string];
  /** The sensors type (ref: usage/memory, memory, temperature) */
  sensorsType: [
    "usage" | "memory" | "memory-percent",
    "none" | "memory" | "memory-percent",
    boolean,
  ];
  /** The temperature thresholds */
  thresholds: Thresholds;
  /** The device index (eg. gpu0, gpu1) */
  device: string;
}
export interface GpuText extends Base, Titled {
  /** The graph type */
  type: "gpuText";
  /** The graph colors (ref: label, usage) */
  colors: [string, string];
  /** The sensors type (ref: usage/memory) */
  sensorsType: ["usage" | "memory" | "memory-percent" | "temperature"];
  /** The device index (eg. gpu0, gpu1) */
  device: string;
}

export interface NetworkGraph extends Base {
  /** The graph type */
  type: "network";
  /** The graph colors (ref: receiving, sending) */
  colors: [string, string];
  /** The sensors type (ref: swap Rx/Tx, unit) */
  sensorsType: [boolean, ByteUnit];
  /** The uplimit (ref: chart1, chart2) */
  uplimits: [number, number];
  /** The ignored network interfaces */
  ignoredInterfaces: string[];
  /** Show labels icons (↓ / ↑) */
  icons: boolean;
}
export interface NetworkText extends Base {
  /** The graph type */
  type: "networkText";
  /** The graph colors (ref: receiving, sending) */
  colors: [string, string];
  /** The sensors type (ref: swap Rx/Tx, unit) */
  sensorsType: [boolean, ByteUnit];
  /** The ignored network interfaces */
  ignoredInterfaces: string[];
  /** Show labels icons (↓ / ↑) */
  icons: boolean;
}

export interface DiskGraph extends Base {
  /** The graph type */
  type: "disk";
  /** The graph colors (ref: read, write) */
  colors: [string, string];
  /** The sensors type (ref: swap r/w) */
  sensorsType: [boolean];
  /** The uplimit (ref: chart1, chart2) */
  uplimits: [number, number];
  /** The disk id (eg. sda, sdc), it also could be `all` */
  device: string;
  /** Show labels icons (R / W) */
  icons: boolean;
}
export interface DiskText extends Base, Titled {
  /** The graph type */
  type: "diskText";
  /** The graph colors (ref: label, usage) */
  colors: [string, string];
  /** The sensors type (ref: usage) */
  sensorsType: ["used" | "used-percent"];
  /** The disk id (eg. sda, sdc), it also could be `all` */
  device: string;
  /** Show labels icons (R / W) */
  icons: boolean;
}

export interface BatteryText extends Base, Titled {
  /** The graph type */
  type: "batteryText";
  /** The graph colors (ref: label, usage) */
  colors: [string, string];
  /** The sensors type (ref: type, hideWhenAbsent) */
  sensorsType: ["percentage" | "energy-rate" | "time", boolean];
  /** The device ID (eg. battery_BAT0) */
  device: string;
  /** The battery percentage thresholds */
  thresholds: Thresholds;
}

export interface Text extends Base {
  /** The graph type */
  type: "text";
  /** The text color */
  color: string;
  /** The text value */
  device: string;
  /** The text placement */
  placement: string;
}

export type GraphTypes = Graph["type"];
export type Graph =
  | CpuGraph
  | CpuText
  | MemoryGraph
  | MemoryText
  | GpuGraph
  | GpuText
  | NetworkGraph
  | NetworkText
  | DiskGraph
  | DiskText
  | BatteryText
  | Text;

type OmittedBaseKeys = "_v" | "type" | "sizes" | "fontSize";
type OmittedWithDevice = OmittedBaseKeys | "device";
export interface GraphDefaultsMap {
  cpu: Omit<CpuGraph, OmittedBaseKeys>;
  cpuText: Omit<CpuText, OmittedBaseKeys>;
  memory: Omit<MemoryGraph, OmittedBaseKeys>;
  memoryText: Omit<MemoryText, OmittedBaseKeys>;
  gpu: Omit<GpuGraph, OmittedWithDevice>;
  gpuText: Omit<GpuText, OmittedWithDevice>;
  network: Omit<NetworkGraph, OmittedBaseKeys>;
  networkText: Omit<NetworkText, OmittedBaseKeys>;
  disk: Omit<DiskGraph, OmittedWithDevice>;
  diskText: Omit<DiskText, OmittedWithDevice>;
  batteryText: Omit<BatteryText, OmittedWithDevice>;
  text: Omit<Text, "_v" | "type" | "sizes">; // fontSize conservé (fallback)
}

export interface DisplayInfoTemplate {
  /** The i18nc arguments (context, source text) */
  name: [string, string];
  /** The graph icon */
  icon: string;
  /** The fallback of graph icon */
  fallbackIcon: string;
  /** Whether the name accepts %1 = deviceName */
  withDeviceName?: boolean;
}
export interface DisplayInfo {
  type: GraphTypes;
  name: string;
  icon: string;
  fallbackIcon: string;
  section: string;
  /** The graph device (set to {@link type} if is not "gpu" or "disk" type) */
  device: string;
}
