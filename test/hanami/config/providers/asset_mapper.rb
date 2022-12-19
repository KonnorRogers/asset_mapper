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

      # A FileWatcher instance
      config.asset_files = Rake::FileList.new(["app/assets/media/**/*.*"])

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

