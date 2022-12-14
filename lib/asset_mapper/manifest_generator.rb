require 'dry-initializer'
require "rake"

module AssetMapper
  class ManifestGenerator
    extend Dry::Initializer

    FILES = Dry::Files.new

    # @return [AssetMapper::Configuration]
    param :config

    def generate
      return if config.watch_files.nil?
      return if config.watch_files.size.zero?

      map = {
        "files" => {}
      }

      config.watch_files.each do |file|
        content = FILES.read(file)

        # relative_hashed_path = relative_path
        relative_path = Pathname.new(file).relative_path_from(config.assets_root).to_s
        relative_hashed_path = nil

        if config.fingerprint
          content_hash = config.fingerprint_method.call(content)

          dir = File.dirname(file)

          base_name_ary = File.basename(file).split(".")
          base_name = FILES.join(dir, base_name_ary[0])
          hashed_path = base_name + "-#{content_hash}." + base_name_ary[1]
          relative_hashed_path = Pathname.new(hashed_path).relative_path_from(config.assets_root)

          map["files"][relative_path.to_s] = {
            file_path: FILES.join(config.assets_output_path, relative_hashed_path.to_s),
            asset_path: relative_hashed_path.to_s
          }
        else
          map["files"][relative_path.to_s] = {
            file_path: Files.join(config.assets_output_path, relative_path.to_s),
            asset_path: relative_path.to_s
          }
        end

        FILES.mkdir_p(FILES.join(config.assets_output_path, dir))
        FILES.write(FILES.join(config.assets_output_path, relative_hashed_path || relative_path), content)
      end

      FILES.write(config.manifest_output_path, JSON.pretty_generate(map))
    end
  end
end
