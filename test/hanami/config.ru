# frozen_string_literal: true

require "hanami/boot"

run Hanami.app
use Rack::Static, :urls => [""], :root => "public", cascade: true
