module Bookshelf
  class Context < Hanami::View::Context
    include Deps["asset_mapper"]

    def asset_path(asset_name)
      asset_mapper.find(asset_name)
    end
  end
end
