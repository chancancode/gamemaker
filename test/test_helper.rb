$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gamemaker'
require 'active_support/testing/declarative'
require 'active_support/json'
require 'minitest/autorun'

class Minitest::Test
  extend ActiveSupport::Testing::Declarative

  private

  def assert_to_json(expected, actual)
    assert_equal ActiveSupport::JSON.encode(expected), ActiveSupport::JSON.encode(actual)
  end

  def assert_from_json(klass, json, *args, expected)
    json = ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(json))
    assert_equal expected, klass.from_json(json)
  end
end
