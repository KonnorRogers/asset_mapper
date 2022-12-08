require 'dry-initializer'
require 'dry-files'

module AssetMapper
  # Manifest reads a given sets of files and reads them into memory via a Hash
  class Manifest
    extend Dry::Initializer

    param :config

    class FileNotFoundError < StandardError; end

    # Attempt to find the +file_name+ inside of the manifest, fallback to given filename.
    # @param {String} - The filename to find in the manifest.
    # @return {String}
    def find(file_name)
      raise FileNotFoundError("#{file_name} not found.") if config.raise_on_missing_file

      manifest.fetch(file_name, file_name)
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

    def load_manifest
      config.manifest_files.map { |path| JSON.parse(Dry::Files.new.read(path)) }.inject({}, &:merge)
    end
  end
end
