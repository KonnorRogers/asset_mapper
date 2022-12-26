# frozen_string_literal: true

module Bookshelf
  module Actions
    module Home
      class Show < Bookshelf::Action
        def handle(_request, response)
          response.render(view)
        end
      end
    end
  end
end
