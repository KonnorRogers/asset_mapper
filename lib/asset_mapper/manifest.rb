require 'dry-initializer'
require 'dry-files'

module AssetMapper
  # Manifest reads a given sets of files and reads them into memory via a Hash
  class Manifest
    extend Dry::Initializer

    param :config

    # Find anything located in the "entrypoints" key of the JSON file.
    def find_entrypoint(str)
      manifest.fetch("entrypoints").fetch(str)
    end

    # Find anything located in the "assets" portion of the JSON file.
    def find_asset(str)
      manifest.fetch("assets").fetch(str)
    end

    # Returns a cached copy of the manifest.
    def manifest
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
