import archiver from "archiver";
import { createWriteStream } from "fs";
import { readFile } from "fs/promises";
import { join, resolve } from "path";

const { version } = JSON.parse(await readFile(resolve("package.json")));

const source = resolve("package");
const output = createWriteStream(
  resolve(`resources-monitor-${version}.plasmoid`)
);

// Create archive
const archive = archiver("zip", {
  zlib: { level: 9 }, // Sets the compression level.
});
archive
  .directory(join(source, "contents"), "contents")
  .file(join(source, "metadata.json"), { name: "metadata.json" })
  .pipe(output)
  .on("error", (err) => {
    throw err;
  });
archive.finalize();
