require 'dry-initializer'
require "rake"

module AssetMapper
  class ManifestGenerator
    extend Dry::Initializer

    FILES = Dry::Files.new

    # @return [AssetMapper::Configuration]
    param :config

    def generate
      return if config.asset_files.nil?
      return if config.asset_files.size.zero?

      map = {
        "files" => {}
      }

      config.asset_files.each do |file|
        hash = handle_file(file)

        map["files"][hash[:relative_path]] = {
          file_path: hash[:file_path],
          asset_path: hash[:asset_path]
        }
      end

      FILES.write(config.manifest_output_path, JSON.pretty_generate(map))
    end

    private

    def handle_file(file)
      relative_path = Pathname.new(file).relative_path_from(config.assets_root).to_s

      content = FILES.read(file)
      asset_path = (find_relative_hashed_path(file, content) || relative_path).to_s

      dir = File.dirname(file)
      FILES.mkdir_p(FILES.join(config.assets_output_path, dir))
      FILES.write(FILES.join(config.assets_output_path, asset_path), content)

      {
        relative_path: relative_path,
        file_path: FILES.join(config.assets_output_path, asset_path),
        asset_path: asset_path
      }
    end

    def find_relative_hashed_path(file, content)
      return nil if config.fingerprint == false

      content_hash = config.fingerprint_method.call(content)

      dir = File.dirname(file)

      base_name_ary = File.basename(file).split(".")
      base_name = FILES.join(dir, base_name_ary[0])
      hashed_path = base_name + "-#{content_hash}." + base_name_ary[1]
      Pathname.new(hashed_path).relative_path_from(config.assets_root)
    end
  end
end
