# Parcel 2

To get started with Parcel 2, if you haven't already, create a `package.json`.

```bash
yarn init
```

In our `package.json`, lets add a `build` command as well
as specify our `"sources"`.

```json
// package.json
{
  "targets": {
    "default": {
      "source": "app/javascript/entrypoints",
      "isLibrary": false,
      "distDir": "./public/parcels"
    }
  },
  "scripts": {
    "watch": "parcel watch",
    "build": "parcel build"
  }
}
```

This means all of our "entrypoints" should be located under
`app/javascript/entrypoints`

For example, you may have a
`app/javascript/entrypoints/application.js`

This file will be the file that is referenced when using a
`<script>` tag.

Next, we need to install the proper node dependencies.

```bash
yarn add -D parcel @parcel/config-default parcel-reporter-bundle-manifest
```

Then, create a `.parcelrc` file in the root of your
project.

```bash
touch .parcelrc
```

And then add the following contents:

```json
{
  "extends": "@parcel/config-default",
  "reporters": ["...", "parcel-reporter-bundle-manifest"]
}
```

## Setting up the server.

If you're using Rails, create a file called `asset_mapper.rb` in
your `config/initializers` folder. If you're not using
Rails, in whatever file initializes your app, add the
following code:

```rb
// config/initializers/asset_mapper.rb

AssetMapper.configure do |config|
  # Prefix before all file paths
  config.asset_host = "/"

  # Where to find your manifest files. (Most people have only 1)
  config.manifest_files = %w[public/parcels/parcel-manifest.json]
end
```

## Adding to our HTML

To add your script and stylesheet tags to your build, you
can do the following:

```erb
<link href="<%= AssetMapper.find('entrypoints/application.css') %>" rel="stylesheet">
<script src="<%= AssetMapper.find('entrypoints/application.js') %>" type="module">
```

## Additional Optimizations

### Compression

First, install the compression plugins:

```bash
yarn add -D @parcel/compressor-gzip @parcel/compressor-brotli
```

If you would like to add gzipping / brotli compression,
make your `.parcelrc` look like the following:

```json
{
  "extends": "@parcel/config-default",
  "reporters": ["...", "parcel-reporter-bundle-manifest"]
  "compressors": {
    "*.{html,css,js,svg,map}": [
      "...",
      "@parcel/compressor-gzip",
      "@parcel/compressor-brotli"
    ]
  }
}
```

This will gzip / brotli compress any .html, .css, .js, .svg,
and .map files so that your web server doesn't have to.

### Specifying a build target

Build targets are a way of specifying "what version of
javascript to ship", IE: ES6, ES2018, ESNext, etc.

Parcel has a whole section dedicated to [specifying targets]()

The easiest to set in your `package.json` is the following:

```json
// package.json
 {
  "browserslist": "> 0.5%, last 2 versions, not dead"
 }
```

### Usage with static files

https://www.npmjs.com/package/parcel-reporter-multiple-static-file-copier
