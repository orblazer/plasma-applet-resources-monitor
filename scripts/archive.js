const fs = require('fs')
const { resolve } = require('path')
const archive = require('archiver')('zip')
const { version } = require('../package.json')

const source = resolve(__dirname, '../package')
const output = fs.createWriteStream(resolve(__dirname, `../resourcesMonitor-fork-${version}.zip`))

// Create archive
archive
  .directory(source, false)
  .pipe(output)
  .on('error', (err) => {
    throw err
  })
archive.finalize()
