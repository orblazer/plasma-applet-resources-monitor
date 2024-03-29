import archiver from "archiver";
import { createWriteStream } from "fs";
import { readFile } from "fs/promises";
import { resolve } from "path";

const { version } = JSON.parse(await readFile(resolve("package.json")));

const source = resolve("package");
const output = createWriteStream(
  resolve(`resourcesMonitor-fork-${version}.plasmoid`)
);

// Create archive
const archive = archiver("zip");
archive
  .directory(source, false)
  .pipe(output)
  .on("error", (err) => {
    throw err;
  });
archive.finalize();
