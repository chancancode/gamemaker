require 'test_helper'
require 'gamemaker/card_game'

module Gamemaker::CardGame
  class CardTest < Minitest::Test
    test "Card is an abstract class" do
      assert_raises(NotImplementedError) { Card.new }
    end
  end
end
