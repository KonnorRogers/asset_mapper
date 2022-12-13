# config/providers/asset_mapper.rb

Hanami.app.register_provider(:asset_mapper) do
  prepare do
    require "asset_mapper"
  end

  start do
    asset_mapper = AssetMapper.new.configure do |config|
      # Where the manifest files can be found on the host machine
      config.manifest_files = ["public/esbuild-builds/asset-mapper-manifest.json"]

      # The URL or path prefix for the files.
      config.asset_host = "/esbuild-builds"

      # Do not cache the manifest in testing or in development, only production.
      config.cache_manifest = Hanami.env?(:production)
    end

    register "asset_mapper", asset_mapper
  end
end

