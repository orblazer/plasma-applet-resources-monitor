import QtQuick 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "./functions.js" as Functions

Item {
  id: sensorData

  // Config
  readonly property bool _memoryUseAllocated: plasmoid.configuration.memoryUseAllocated
  readonly property var networkDialect: Functions.getNetworkDialectInfo(plasmoid.configuration.networkUnit)
  readonly property var ignoredNetworkInterfaces: plasmoid.configuration.ignoredNetworkInterfaces
  readonly property double networkReceivingTotal: plasmoid.configuration.networkReceivingTotal
  readonly property double networkSendingTotal: plasmoid.configuration.networkSendingTotal

  readonly property alias sensors: sensors
  QtObject {
    id: sensors

    // Cpu sensor
    readonly property string _cpuSystem: "cpu/system/"
    readonly property string averageClock: _cpuSystem + "AverageClock"
    readonly property string totalLoad: _cpuSystem + "TotalLoad"

    // Memory sensor
    readonly property string _memPhysical: "mem/physical/"
    readonly property string memFree: _memPhysical + "free"
    readonly property string memApplication: _memPhysical + (_memoryUseAllocated ? "allocated" : "application")
    readonly property string memUsed: _memPhysical + "used"
    readonly property string _swap: "mem/swap/"
    readonly property string swapUsed: _swap + "used"
    readonly property string swapFree: _swap + "free"

    // Network sensor
    readonly property string networkReceiver: "network/receiver"
    readonly property string networkTransmitter: "network/transmitter"
    property var receiverNetworkList: []
    property var transmitterNetworkList: []
  }

  // Utils functions
  function hasData(key) {
      if (key === sensors.networkReceiver || key === sensors.networkTransmitter) {
        return true
      }

      if (typeof dataSource.data[key] === 'undefined') return false
      if (typeof dataSource.data[key].value === 'undefined') return false
      return true
  }
  function getData(key) {
      if (key === sensors.networkReceiver) {
        return _getNetworkData(sensors.receiverNetworkList)
      }
      else if (key === sensors.networkTransmitter) {
        return _getNetworkData(sensors.transmitterNetworkList)
      }
      return _getData(key)
  }
  function _getData(key) {
    if (typeof dataSource.data[key] === 'undefined') {
      return 0
    }
    var value = parseInt(dataSource.data[key].value)
    return isNaN(value) ? 0 : value
  }
  function _getNetworkData(sensors = []) {
    var total = 0
    var i, sensor
    for (i = 0; i < sensors.length; i++) {
      sensor = sensors[i]
      // Connect source if is disconnect
      if (!isConnectedSource(sensor)) {
          dataSource.connectSource(sensor)
      }

      total += _getData(sensor)
    }
    return total * networkDialect.KiBDiff // Return convected in dialect
  }
  function getUnits(key) {
      if (key === sensors.networkReceiver || key === sensors.networkTransmitter) {
        return networkDialect.name
      }

      if (typeof dataSource.data[key] === 'undefined') return ''
      if (typeof dataSource.data[key].units === 'undefined') return ''
      return dataSource.data[key].units
  }

  // CPU
  readonly property real cpuTotalLoad: getData(sensors.totalLoad)
  readonly property real cpuTotalLoadRatio: cpuTotalLoad / sensors.maxCpuLoad
  readonly property real cpuTotalLoadPercent: cpuTotalLoadRatio * 100

  // Memory
  readonly property real memApps: getData(sensors.memApplication)
  readonly property real memUsed: getData(sensors.memUsed)
  readonly property real memFree: getData(sensors.memFree)
  readonly property real memTotal: memUsed + memFree

  function memPercentage(value) {
		var ratio = memTotal ? value / memTotal : 0
		return ratio * 100
	}

  // Swap
  readonly property real swapUsed: getData(sensors.swapUsed)
  readonly property real swapFree: getData(sensors.swapFree)
  readonly property real swapTotal: swapUsed + swapFree

  // Tick when data source changed
  Timer {
    id: timer
    repeat: true
    running: true
    interval: dataSource.interval
    onTriggered: sensorData.dataTick()
  }
  signal dataTick()

  // Data source
  property alias dataSource: dataSource
  PlasmaCore.DataSource {
    id: dataSource
    engine: "systemmonitor"
    interval: 2000000000

    readonly property var networkRegex: /^network\/interfaces\/(?!lo|bridge|usbus|bond)(.*)\/(transmitter|receiver)\/data$/

    connectedSources: [
      sensors.memFree, sensors.memUsed, sensors.swapFree
    ]

    onSourceAdded: {
      // Process network sensors
      var match = source.match(networkRegex)
      if (match) {
        // Skip ignored interface
        if (ignoredNetworkInterfaces.indexOf(match[1]) !== -1) {
          return
        }

        // Add if not seen before
        if (match[2] === "transmitter") {
          if (sensors.transmitterNetworkList.indexOf(source) === -1) {
            sensors.transmitterNetworkList.push(source)
          }
        } else {
          if (sensors.receiverNetworkList.indexOf(source) === -1) {
            sensors.receiverNetworkList.push(source)
          }
        }

        connectSource(source)
      }
    }

    function fitMemoryUsage(usage) {
        return Functions.getPercentUsage(usage, (parseFloat(dataSource.data[sensors.memFree].value) +
          parseFloat(dataSource.data[sensors.memUsed].value)))
    }

    function fitSwapUsage(usage) {
        return Functions.getPercentUsage(usage, (parseFloat(usage) +
          parseFloat(dataSource.data[sensors.swapFree].value)))
    }
  }

  // Sync sources with ignored network interfaces
  onIgnoredNetworkInterfacesChanged:  {
    var i, match, transmitterChangerd, receiverChanged
    var transmitterNetworkList = sensors.transmitterNetworkList
    var receiverNetworkList = sensors.receiverNetworkList
    for (i = 0; i < dataSource.sources.length; i++) {
      if (match = dataSource.sources[i].match(dataSource.networkRegex)) {
        var source = dataSource.sources[i]

        // Remove or skip ignored interfaces
        if (ignoredNetworkInterfaces.indexOf(match[1]) !== -1) {
          if (dataSource.connectedSources.indexOf(source) !== -1) {
            if(match[2] === "transmitter") {
              var index = transmitterNetworkList.indexOf(source)
              if (index !== -1) {
                transmitterChangerd = true
                transmitterNetworkList.splice(index, 1)
              }
            } else {
              var index = receiverNetworkList.indexOf(source)
              if (index !== -1) {
                transmitterChangerd = true
                transmitterNetworkList.splice(index, 1)
              }
            }
          }

          continue
        }

        // Add if not seen before
        if (match[2] === "transmitter") {
          if (transmitterNetworkList.indexOf(source) === -1) {
            transmitterChangerd = true
            transmitterNetworkList.push(source)
          }
        } else {
          if (receiverNetworkList.indexOf(source) === -1) {
            receiverChanged = true
            receiverNetworkList.push(source)
          }
        }

        dataSource.connectSource(source)
      }
    }

    if (transmitterChangerd) {
      sensors.transmitterNetworkList = transmitterNetworkList
    }
    if (receiverChanged) {
      sensors.receiverNetworkList = receiverNetworkList
    }
  }

  // Utils functions
  function isConnectedSource(key) {
    if (key === sensors.networkReceiver || key === sensors.networkTransmitter) {
        return true
    }

    return dataSource.connectedSources.indexOf(key) !== -1
  }
  function connectSource(key) {
    if (key === sensors.networkReceiver || key === sensors.networkTransmitter) {
        return
    }
    return dataSource.connectSource(key)
  }
}
