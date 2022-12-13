require "dry/configurable"
require "forwardable"

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

    def_delegators :manifest, :find

    # Returns an instance of the manifest.
    # @return [AssetMapper::Manifest]
    def manifest
      @manifest ||= Manifest.new(config)
    end
  end
end
