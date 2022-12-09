AssetMapper.configure do ||
  # Where the manifest files can be found on the host machine
  config.manifest_files = ["public/asset_manifest.json"]
  config.asset_host = "/"

  # Do not cache the manifest in testing or in development.
  config.cache_manifest = !(Rails.env.development? || Rails.env.testing?)
end