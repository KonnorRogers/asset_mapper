// esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=assets
// @ts-check
//
const path = require("path");
const process = require("process");
const esbuild = require("esbuild");
const fsLib = require("fs");
const fs = fsLib.promises;

/**
 * @param {{ outputRoot?: string, entrypointRoot?: string }} [options={}] Plugin options.
 * @return {import("esbuild").Plugin}
 */
function AssetMapperManifest(options = {}) {
  if (options == null) options = {};

  let { outputRoot, entrypointRoot = "app/javascript" } = options;

  return {
    name: "asset-mapper-manifest",

    setup(build) {
      build.initialOptions.metafile = true;

  		if (!outputRoot) {
  			outputRoot = path.relative(process.cwd(), build.initialOptions.outdir || "")
  		}

      // assume that the user wants to hash their files by default,
      // but don't override any hashing format they may have already set.
      ;["entryNames", "assetNames", "chunkNames"].forEach((str) => {
        if (build.initialOptions[str]) return;

        if (str === "chunkNames") {
          build.initialOptions[str] = "chunks/[name]-[hash]";
          return;
        }

        build.initialOptions[str] = "[dir]/[name]-[hash]";
      });

      build.onEnd(async (result) => {
        if (!result.metafile) {
          console.warn(
            "No metafile found from ESBuild. No manifest generated."
          );
          return;
        }

        if (!result.metafile.outputs) {
          console.warn(
            "No inputs found. Make sure you are passing entrypoints to ESBuild."
          );
          return;
        }

        /** @type Map<string, string> */
        const manifest = new Map();

        const outfileDir = build.initialOptions.outfile
          ? build.initialOptions.outfile
          : null;
        const outdir =
          build.initialOptions.outdir || outfileDir || process.cwd();

        // Let's loop through all the various outputs
        for (const hashedPath in result.metafile.outputs) {
          const output = result.metafile.outputs[hashedPath];


          if (!output.entryPoint) {
            continue;
          }

          const entryPoint = output.entryPoint;

					let finalPath = hashedPath


					// Theres probably better ways to do this, but basically if we import an SVG
					// its final location will be: "thing.svg -> thing-[hash].js", this goes back through
					// the outputs and finds the correct SVG.
					// https://github.com/evanw/esbuild/issues/2731
					const loader = build.initialOptions.loader || {}
					const { ext } = path.parse(entryPoint)

					const isExternalFile = loader[ext] === "file"

					if (isExternalFile) {
						for (const key in result.metafile.outputs) {
							const val = result.metafile.outputs[key]
							const inputs = Object.keys(val.inputs)

							if (inputs.length !== 1) continue

							const asset = inputs[0]
							if (asset === entryPoint) {
								finalPath = key
								break
							}
						}
					}


          // Replace the relative paths. We don't need "/public" or "app/javascript"
          manifest.set(
            path.relative(entrypointRoot, entryPoint),
            path.relative(outputRoot, finalPath)
          );

          if (!output.cssBundle) continue;

          const { dir, name } = path.parse(entryPoint);
          const cssBundle = path.join(dir, name + ".css");
          manifest.set(
            path.relative(entrypointRoot, cssBundle),
            path.relative(outputRoot, output.cssBundle)
          );
        }

        const manifestFolder = path.resolve(outdir);
        await fs.mkdir(manifestFolder, { recursive: true });
        await fs.writeFile(
          path.join(manifestFolder, "asset-mapper-manifest.json"),
          JSON.stringify(Object.fromEntries(manifest), null, 2)
        );
      });
    },
  };
}

/** @typedef BuildResult import("esbuild").BuildResult  */
(async () => {
  // const key = path.join("application")
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
    },
    outdir: path.join(process.cwd(), "public/esbuild-builds"),
    plugins: [AssetMapperManifest()],
  });
})();
