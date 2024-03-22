import archiver from "archiver";
import { createWriteStream } from "fs";
import { resolve } from "path";
import { version } from "../package.json";

const source = resolve(__dirname, "../package");
const output = createWriteStream(
  resolve(__dirname, `../resourcesMonitor-fork-${version}.plasmoid`)
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
