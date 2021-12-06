# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

require "dry/configurable"

module AssetMapper
  # Your code goes here...
  extend ::Dry::Configurable
  extend self

  setting :files, reader: true
  setting :output_path, reader: true

  # For file.1234.ext
  # if using file-1234.ext change to: /\.[\d\w]+\./
  setting :fingerprint_regexp, default: /\-[\d\w]+\./, reader: true
  setting :fingerprint_replacer, default: ".", reader: true

  def generate_mapping
    hash = {}

    files.map do |file|
      file_without_fingerprint = file.gsub(fingerprint_regexp, fingerprint_replacer)
      hash[file_without_fingerprint] = file
    end

    hash
  end
end
