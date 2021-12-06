# frozen_string_literal: true

require "test_helper"

class HashCreationTest < Minitest::Test
  def setup
    @files = {"test.rb" => "test.f185dde.rb",
              "test" => "test",
              "test1.js" => "test1.js",
              "nested/test.rb" => "nested/test.f185dde.rb",
              "nested/test.js" => "nested/test.js",
              "nested/test" => "nested/test"
             }

    AssetMapper.config.files = @files.values
  end

  def test_that_it_returns_a_properly_mapped_hash

    hash = AssetMapper.generate_mapping

    @files.each do |logical_name, actual_name|
      assert_equal hash[logical_name], actual_name
    end
  end
end
