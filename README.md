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

- [ ] - Create a plugin for ESBuild.
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
  "/path/before/asset-1.js": "path/after/asset-1.js"
  "/path/before/asset-2.js": "path/after/asset-2.js"
}
```

## Programmatic Usage

```rb
AssetMapper.configure do |config|
  # Where the manifest files can be found on the host machine
  config.manifest_files = ["public/builds/asset-mapper-manifest.json"]

  # The URL or path prefix for the files.
  config.asset_host = "/builds"

  # Do not cache the manifest in testing or in development.
  config.cache_manifest = !(Rails.env.development? || Rails.env.testing?)
end

manifest = AssetMapper.manifest
# =>
#   {
#     "entrypoints/application.js" => "entrypoints/application-[hash].js"
#     "assets/icon.svg" => "assets/icon-[hash].svg"
#   }

manifest.find("entrypoints/application.js")
# => "/builds/entrypoints/application-[hash].js"

manifest.find("assets/icon.svg")
# => "/builds/assets/icon-[hash].svg"
```

## Supported bundlers

- [ESBuild](/docs/esbuild)
- [Parcel](/docs/parcel2)
- [Rollup](/docs/rollup)
- [Vite](/docs/vite/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paramagicdev/asset_mapper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/paramagicdev/asset_mapper/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AssetMapper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/paramagicdev/asset_mapper/blob/main/CODE_OF_CONDUCT.md).
