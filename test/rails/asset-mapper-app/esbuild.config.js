// esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=assets
// @ts-check

//
/** @typedef BuildResult import("esbuild").BuildResult  */
(async () => {
  const path = require("path");
  const process = require("process");
  const esbuild = require("esbuild");
  const fsLib = require("fs");
  const fs = fsLib.promises;

  /** @type {import("esbuild").Plugin} **/
  let plugin = {
    name: "asset-mapper-manifest",

    setup(build) {
      build.initialOptions.metafile = true;

      // assume that the user wants to hash their files by default,
      // but don't override any hashing format they may have already set.
      ["entryNames", "assetNames", "chunkNames"].forEach((str) => {
      	if (build.initialOptions[str]) return

				if (str === "chunkNames") {
					build.initialOptions[str] = "chunks/[name]-[hash]"
					return
				}

				build.initialOptions[str] = "[dir]/[name]-[hash]"
      })

      build.onEnd(async (result) => {
        if (!result.metafile) {
          console.warn("No metafile found from ESBuild. No manifest generated.")
          return
        }

        if (!result.metafile.outputs) {
          console.warn("No inputs found. Make sure you are passing entrypoints to ESBuild.")
          return
        }

        /** @type Map<string, string> */
        const manifest = new Map();

				const outfileDir = build.initialOptions.outfile ? build.initialOptions.outfile : null
        const outdir = build.initialOptions.outdir || outfileDir || process.cwd()

				const outputRoot = "public/"
				const entrypointRoot = "app/javascript/"

        // Let's loop through all the various outputs
        for (const hashedPath in result.metafile.outputs) {
          const output = result.metafile.outputs[hashedPath];

          if (!output.entryPoint) {
            continue
          }

					// Replace the relative path. We don't need "/public"
					const entryPoint = output.entryPoint

          manifest.set(path.relative(entrypointRoot, entryPoint), path.relative(outputRoot, hashedPath))

          if (!output.cssBundle) continue

					const { dir, name } = path.parse(entryPoint)
          const cssBundle = path.join(dir, name + ".css")
          manifest.set(path.relative(entrypointRoot, cssBundle), path.relative(outputRoot, output.cssBundle))
        }

        const manifestFolder = path.resolve(outdir)
        await fs.mkdir(manifestFolder, { recursive: true })
        await fs.writeFile(path.join(manifestFolder, "asset-mapper-manifest.json"), JSON.stringify(Object.fromEntries(manifest), null, 2))
      });
    },
  };

  // const key = path.join(process.cwd(), "app", "javascript", "application.js")
  // const value = path.join(".", process.cwd(), "app", "javascript", "application.js")
  await esbuild.build({
    entryPoints: {
      application: path.join(process.cwd(), "app/javascript/application.js"),
    },
    format: "esm",
    splitting: true,
    bundle: true,
    sourcemap: true,
    loader: {
      ".png": "file",
      ".woff": "file",
      ".woff2": "file",
      ".svg": "file",
      ".webp": "file",
      ".jpeg": "file",
      ".jpg": "file",
      ".gif": "file",
      ".avif": "file",
      ".avi": "file",
      ".json": "file",
    },
    metafile: true,
    // absWorkingDir: process.cwd(),
    assetNames: "[dir]",
    outdir: path.join(process.cwd(), "public/esbuild-builds"),
    plugins: [plugin],
  });
})();
