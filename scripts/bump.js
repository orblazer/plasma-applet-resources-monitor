import { readFile, writeFile } from "fs/promises";
import { resolve } from "path";
import { version } from "../package.json";

// Bump version in desktop file
const file = resolve(__dirname, "../package/metadata.json");
readFile(file, "utf-8").then((data) => {
  const jsonData = JSON.parse(data);
  jsonData.KPlugin.Version = version;
  writeFile(file, JSON.stringify(jsonData, undefined, 2), "utf-8");
});
