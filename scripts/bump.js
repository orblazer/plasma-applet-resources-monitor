const fs = require("fs/promises");
const { resolve } = require("path");
const { version } = require("../package.json");

// Bump version in desktop file
const file = resolve(__dirname, "../package/metadata.json");
fs.readFile(file, "utf-8").then((data) => {
  const jsonData = JSON.parse(data);
  jsonData.KPlugin.Version = version;
  fs.writeFile(file, JSON.stringify(jsonData, undefined, 2), "utf-8");
});
