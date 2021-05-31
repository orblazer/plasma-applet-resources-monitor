const fs = require('fs/promises')
const { resolve } = require('path')
const { version } = require('../package.json')

// Bump version in desktop file
const file = resolve(__dirname, '../package/metadata.desktop')
fs.readFile(file, 'utf-8').then((data) => {
  const updated = data.replace(/X-KDE-PluginInfo-Version=\d+\.\d+\.\d+/, 'X-KDE-PluginInfo-Version=' + version)
  fs.writeFile(file, updated, 'utf-8')
})
