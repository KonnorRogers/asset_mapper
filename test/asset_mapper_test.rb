# frozen_string_literal: true

require "test_helper"

class AssetMapperTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AssetMapper::VERSION
  end

  def test_it_should_be_configurable
    cache_manifest = true
    manifest_files = %w[public/manifest.json]

    asset_mapper = AssetMapper.new.configure do |config|
      config.manifest_files = manifest_files
      config.cache_manifest = cache_manifest
    end

    assert_equal asset_mapper.config.manifest_files, manifest_files
    assert_equal asset_mapper.config.cache_manifest, cache_manifest
  end
end
