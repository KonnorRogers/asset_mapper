# frozen_string_literal: true

module Bookshelf
  class Routes < Hanami::Routes
    root to: "home.show"
    get "/books", to: "books.index"
  end
end
