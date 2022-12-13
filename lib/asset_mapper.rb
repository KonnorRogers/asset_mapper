# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!


# @example
#
#   asset_mapper = AssetMapper.new.configure do |config|
#     config.asset_host = "/builds"
#     config.manifest_files = "public/builds/asset_manifest.json"
#     config.cache_manifest = Rails.env.development? || Rails.env.test?
#     config.raise_on_missing_file = Rails.env.development? || Rails.env.test?
#   end
module AssetMapper
  # Returns an instance of AssetMapper configuration.
  # @return [Configuration]
  def self.new(*args, **kwargs, &block)
    Configuration.new(*args, **kwargs, &block)
  end
end
