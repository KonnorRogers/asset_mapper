require "hanami/view"
require "slim"

module Bookshelf
  class View < Hanami::View
    include Deps["asset_mapper"]

    expose :asset_mapper

    config.paths = [File.join(File.expand_path(__dir__), "templates")]
    config.layout = "application"
  end
end
