require "hanami/view"
require "slim"

module Bookshelf
  class View < Hanami::View
    config.default_context = Context.new
    config.paths = [File.join(File.expand_path(__dir__), "templates")]
    config.layout = "application"
  end
end
