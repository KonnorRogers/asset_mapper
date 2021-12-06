# frozen_string_literal: true

require_relative "lib/asset_mapper/version"

Gem::Specification.new do |spec|
  spec.name = "asset_mapper"
  spec.version = AssetMapper::VERSION
  spec.authors = ["ParamagicDev"]
  spec.email = ["konnor5456@gmail.com"]

  spec.summary = "A tightly scoped directory parser and json file generator. "
  spec.homepage = "https://github.com/ParamagicDev/asset_mapper"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ParamagicDev/asset_mapper"
  spec.metadata["changelog_uri"] = "https://github.com/ParamagicDev/asset_mapper/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake", ">= 10"
  spec.add_runtime_dependency "zeitwerk", "~> 2.5"
  spec.add_runtime_dependency "dry-configurable", "~> 0.13.0"
  spec.add_runtime_dependency "dry-files", "~> 0.1.0"
  spec.add_runtime_dependency "dry-initializer", "~> 3.0"
  spec.add_runtime_dependency "dry-types", "~> 1.5"
end
