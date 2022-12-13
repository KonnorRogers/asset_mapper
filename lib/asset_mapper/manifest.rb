require 'dry-initializer'
require 'dry-files'

module AssetMapper
  # Manifest reads a given sets of files and reads them into memory via a Hash
  class Manifest
    extend Dry::Initializer

    # @return [AssetMapper::Configuration]
    param :config

    class FileNotFoundError < StandardError; end

    # Attempt to find the +file_name+ inside of the manifest, fallback to given filename.
    # @param {String} file_name - The filename to find in the manifest.
    # @param {Boolean} prepend_asset_host - Whether or not to add the asset_host. Usually "/"
    # @return {String}
    def find(file_name, prepend_asset_host: true)
      file = manifest["files"][file_name]

      if file.nil?
        raise FileNotFoundError("Unable to find #{filename} in your manifest[s].") if config.raise_on_missing_file

        # Fall back to the default filename, perhaps it exists....
        file = file_name
      end

      return with_asset_host(asset_host: config.asset_host, file: file) if prepend_asset_host

      file
    end

    # Returns a cached copy of the manifest only if cache_manifest is true.
    def manifest
      # Always reload the manifest. Useful for development / testing.
      return load_manifest if config.cache_manifest == false

      @manifest ||= load_manifest
    end

    # Refreshes the cached mappings by reading the updated manifest files.
    #   Usually used for things like auto-building.
    def refresh
      @manifest = load_manifest
    end

    private

    def with_asset_host(asset_host:, file:)
      # strip leading "/"
      file = file[(1..-1)] if file.start_with?("/")

      asset_host += "/" unless asset_host.end_with?("/")

      asset_host + file
    end

    def load_manifest
      hash = {}
      config.manifest_files.each { |path| hash.merge!(JSON.parse(Dry::Files.new.read(path))) }
      hash
    end
  end
end
