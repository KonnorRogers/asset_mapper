// @ts-check
const esbuild = require("esbuild")
const fs = require("fs")

const watch = process.argv.includes("--watch")

/** @type {import("esbuild").BuildOptions} */
const options = {
  entryPoints: {
    index: "src/index.js",
  },
  watch,
  bundle: false,
  sourcemap: true,
  treeShaking: false
}

;(async () => {
  fs.rmSync("dist", { recursive: true, force: true });

  try {
    await Promise.allSettled([
      esbuild.build({
        ...options,
        format: "esm",
        outdir: "dist/esm"
      }),
      esbuild.build({
        ...options,
        format: "cjs",
        outdir: "dist/cjs"
      })
    ])
  } catch(e) { throw e }

  console.log("Finished build")
})()
