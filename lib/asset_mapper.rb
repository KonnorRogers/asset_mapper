# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

require "dry/configurable"
require "forwardable"

# @example
#
#   AssetMapper.configure do |config|
#     config.manifest_files = "public/asset_manifest.json"
#     config.asset_host = "/"
#     config.cache_manifest = Rails.env.development? || Rails.env.test?
#     config.raise_on_missing_file = Rails.env.development? || Rails.env.test?
#   end
module AssetMapper
  extend ::Forwardable
  extend ::Dry::Configurable
  extend self

  # Where to find the json mapping of your asset files.
  setting :manifest_files, default: []

  # In case you server off of a CDN, you may want to prepend urls.
  setting :asset_host, default: "/"
  setting :cache_manifest, constructor: lambda { |value| !!value }
  setting :raise_on_missing_file, default: false

  def_delegators :manifest, :find

  def manifest
    @manifest ||= Manifest.new(config)
  end
end
