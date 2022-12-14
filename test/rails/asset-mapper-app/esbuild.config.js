// @ts-check

const AssetMapperManifest = require("../../../packages/asset-mapper-esbuild").default
const path = require("path");
const process = require("process");
const esbuild = require("esbuild");
const fs = require("fs")

const entrypointRoot = path.join(process.cwd(), "app", "javascript")
const outdir = path.join(process.cwd(), "public/esbuild-builds")

;(async () => {
  fs.rmSync(outdir, { recursive: true, force: true })
  /** @type {import("esbuild").BuildResult}  */
  await esbuild.build({
    entryPoints: {
      application: path.join(process.cwd(), "app/javascript/application.js"),
      assets: path.join(process.cwd(), "app/javascript/assets.js")
    },
    format: "esm",
    splitting: true,
    bundle: true,
    sourcemap: true,
    outdir,
    plugins: [
      AssetMapperManifest({
        entrypointRoot,
        outputRoot: outdir
      })
    ],
  });
})();
