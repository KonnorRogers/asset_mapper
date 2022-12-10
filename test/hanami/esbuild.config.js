// @ts-check

const AssetMapperManifest = require("../../packages/asset-mapper-esbuild").default
const path = require("path");
const process = require("process");
const esbuild = require("esbuild");
const fs = require("fs")
const glob = require("glob")

const outdir = path.join(process.cwd(), "public/esbuild-builds")
const entrypointRoot = path.join(process.cwd(), "app", "assets", "javascript", "entrypoints")

/** @type {Record<string, string>} */
const entryPoints = {}

glob.sync(`${entrypointRoot}/**/*.{js,ts}`).forEach((file) => {
  const { dir, base } = path.parse(path.relative(entrypointRoot, file))
  // strip the ".js" extension for keys.
  const key = path.join(dir, base)
  entryPoints[key] = file
});

;(async () => {
  fs.rmSync(outdir, { recursive: true, force: true })
  /** @type {import("esbuild").BuildResult}  */
  await esbuild.build({
    entryPoints,
    // entryPoints: {
    //   application: path.join(entrypointRoot, "application.js")
    // },
    format: "esm",
    splitting: true,
    bundle: true,
    sourcemap: true,
    outdir,
    plugins: [AssetMapperManifest({
      entrypointRoot,
      outputRoot: outdir
    })],
  });
})();
