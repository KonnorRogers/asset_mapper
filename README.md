# AssetMapper

AssetMapper is a base level class who's job is simple.
Given a JSON file matching its schema, reads the file into
memory and then provides a logical mapping of the hashed
file.

## Warning

AssetMapper is still a work in progress. It
is not yet released or stable. The below is essentially an
RFC of how I plan for AssetMapper to work.

## Why?

AssetMapper is built on the belief that your bundler
of choice IE: Parcel, Webpack, Rollup, ESBuild, Vite, etc
all know how to handle your files. AssetMapper acts as a
bridge between frontend and backend.

## How does AssetMapper work?

AssetMapper expects to be given a path to a JSON file(s) that
is in a specific schema. To generate these schemas,
generally a plugin needs to be made for your bundler of
choice that complies with the AssetMapper schema. Then, for
your framework of choice you create or find a rubygem that
uses AssetMapper under the hood and can then compose view
layer helpers for referencing asset files.

## Why not Propshaft?

Propshaft is good. It's also Rails specific. It also does
more than I would like it to. It does things like:

- [Remap CSS asset URLS](https://github.com/rails/propshaft/blob/main/lib/propshaft/compilers/css_asset_urls.rb)
- [Remaps sourcemap URLS](https://github.com/rails/propshaft/blob/main/lib/propshaft/compilers/source_mapping_urls.rb)
- [Expects to be able to get a logical path from a filename](https://github.com/rails/propshaft/blob/bef8a9a500e66215dcc87d8752869a99a10cd9e1/lib/propshaft/asset.rb#L31)

## Roadmap

- [ ] - Create a file hasher for bundle-less setups.
- [ ] - Create a file watcher for development to auto-update the manifest.
- [x] - Create a plugin for ESBuild.
- [ ] - Create a plugin for Parcel 2.
- [ ] - Create a plugin for Vite.
- [ ] - Create a pluggable DevServer thats Rack compatible that can be injected as middleware.
- [ ] - Create Rails view helpers.

## For Developers

If you're interested in making a plugin for a bundler that is AssetMapper compatible
here is the JSON schema expected:

### Schema

The schema is super simple. It just path before transform, and path after transform.

```json
{
  "<unhashed-path>": "<hashed-path>"
}
```

Example:

```json
{
  "files": {
    "/path/before/asset-1.js": "path/after/asset-1.js"
    "/path/before/asset-2.js": "path/after/asset-2.js"
  }
}
```

## Programmatic Usage

```rb
# Create an AssetMapper::Configuration instance
asset_mapper = AssetMapper.new.configure do |config|
  # Where the manifest files can be found on the host machine
  config.manifest_files = ["public/builds/asset-mapper-manifest.json"]

  # The URL or path prefix for the files.
  config.asset_host = "/builds"

  # Do not cache the manifest in testing or in development.
  config.cache_manifest = !(Rails.env.development? || Rails.env.testing?)
end

manifest = asset_mapper.manifest
# =>
#   {
#     "files": {
#       "entrypoints/application.js" => "entrypoints/application-[hash].js",
#       "assets/icon.svg" => "assets/icon-[hash].svg"
#     }
#   }

manifest.find("entrypoints/application.js")
# => "/builds/entrypoints/application-[hash].js"

manifest.find("assets/icon.svg")
# => "/builds/assets/icon-[hash].svg"
```

## Supported bundlers

- [x] [ESBuild](/docs/esbuild)
- [ ] [Parcel 2](/docs/parcel2)
- [ ] [Rollup](/docs/rollup)
- [ ] [Vite](/docs/vite/)

## Rails usage

Create an initializer to initialize AssetMapper at `config/initializers/asset_mapper.rb`.

```rb
# config/initializers/asset_mapper.rb

asset_mapper = AssetMapper.new.configure do |config|
  # Where the manifest files can be found on the host machine
  config.manifest_files = ["public/esbuild-builds/asset-mapper-manifest.json"]
  config.asset_host = "/builds"

  # Do not cache the manifest in testing or in development.
  config.cache_manifest = !(Rails.env.development? || Rails.env.testing?)
end

Rails.application.config.asset_mapper = asset_mapper
```

AssetMapper is now available under: `Rails.application.config.asset_mapper`. This is pretty
verbose to use in your views you can create a helper for it.

### Usage in Rails views

```rb
# app/helpers/application_helper.rb
module ApplicationHelper
  def asset_mapper
    Rails.application.config.asset_mapper
  end
end
```

## Hanami setup

The first step is to create a "provider" for asset_mapper.

```rb
# config/providers/asset_mapper.rb

Hanami.app.register_provider(:asset_mapper) do
  prepare do
    require "asset_mapper"
    require "dry/files"
    require "rake"
  end

  start do
    files = Dry::Files.new
    asset_mapper = AssetMapper.new.configure do |config|
      # The URL or path prefix for the files.
      config.asset_host = "/assets"

      # Do not cache the manifest in testing or in development, only production.
      config.cache_manifest = Hanami.env?(:production)

      # Files to watch
      config.watch_files = Rake::FileList["app/assets/media/**/*.*"]

      # Where to dump the assets
      config.assets_output_path = files.join("public/assets")

      # Where to write the manifest to.
      config.manifest_output_path = files.join(config.assets_output_path, "asset-mapper-manifest.json")

      # top level directory of assets. Used for relative short paths.
      config.assets_root = files.join("app/assets")

      # Where the manifest files can be found on the host machine
      config.manifest_files = [
        "public/assets/esbuild-manifest.json",
        config.manifest_output_path
      ]
    end

    register "asset_mapper", asset_mapper
  end
end

```

### Add a static rack server

Next, we need to add a setting to `./config.ru` for when we write to the `public/` folder.

```rb
# config.ru


require "hanami/boot"

run Hanami.app

#### Everything above here is provided by default

#### Add the below call
use Rack::Static, :urls => [""], :root => "public", cascade: true
```

Finally, to use in your views, do the following:

```rb
# app/context.rb
module Main # <- Replace this with your slice or application name
  class Context < Hanami::View::Context
    include Deps["asset_mapper"]

    def asset_path(asset_name)
      asset_mapper.find(asset_name)
    end
  end
end

# app/view.rb
module Main # <- Replace this with your slice or application name
  class View < Hanami::View
    config.default_context = Context.new
  end
end

# app/views/application.html.slim
html
  head
    title Bookshelf
    script src=asset_path("javascript/entrypoints/application.js") type="module"
  body
    == yield
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paramagicdev/asset_mapper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/paramagicdev/asset_mapper/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AssetMapper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/paramagicdev/asset_mapper/blob/main/CODE_OF_CONDUCT.md).
