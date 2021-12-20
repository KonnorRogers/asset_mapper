require 'dry-initializer'
require 'dry-files'

module AssetMapper
  # Manifest reads a given sets of files and reads them into memory via a Hash
  class Manifest
    extend Dry::Initializer

    param :config

    # Find any asset.
    def find(file_name)
      manifest.fetch(file_name)
    rescue KeyError
      $stdout.puts "Unable to find #{file_name} in your manifest files."
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
