require "dry/configurable"
require "forwardable"
require "digest"

module AssetMapper
  # Configuration object for asset mapper. This is the top level API.
  class Configuration
    extend ::Forwardable
    include ::Dry::Configurable

    # Where to find the json mapping of your asset files.
    # @return [String[]]
    setting :manifest_files, default: []

    # In case you server off of a CDN, you may want to prepend urls.
    setting :asset_host, default: "/"

    # Whether or not to cache the manifest.
    # @return [Boolean]
    setting :cache_manifest, constructor: lambda { |value| !!value }

    # Raise an error if the file can't be found. Useful in development.
    # @return [Boolean]
    setting :raise_on_missing_file, default: false

    # Raise an error if the same key is found twice across the same or multiple manifests.
    # @return [Boolean]
    setting :raise_on_duplicate_key, default: false

    # Files for AssetMapper to watch for changes and generate hashes for.
    # Accepts glob patterns like Dir["*"].
    # @return [Array<String>]
    setting :watch_files, default: []

    # Append hashes to the end of files.
    setting :fingerprint, default: true

    # Use MD5 hashes. They're fast, and don't need to be secure.
    setting :fingerprint_method, default: lambda { |str| Digest::MD5.hexdigest(str) }

    # root of your assets, used for short paths.
    setting :assets_root

    # Where to dump the assets
    setting :assets_output_path

    # Where to write the manifest to.
    setting :manifest_output_path

    def_delegators :manifest, :find

    # Returns an instance of the manifest.
    # @return [AssetMapper::Manifest]
    def manifest
      @manifest ||= Manifest.new(config)
    end

    # Returns an instance of a manifest generator. This is for files that are watched by asset_mapper.
    # @return [AssetMapper::ManifestGenerator]
    def manifest_generator
      @manifest_generator ||= ManifestGenerator.new(config)
    end
  end
end
