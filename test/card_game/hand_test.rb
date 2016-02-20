require 'test_helper'
require 'gamemaker/card_game'

module Gamemaker::CardGame
  class HandTest < Minitest::Test
    test "Hand is an abstract class" do
      assert_raises(NotImplementedError) { Deck.new }
    end

    class NumberCard < Card
      def self.all
        (1..9).map { |i| new(i) }
      end

      def self.from_json(number)
        new(number)
      end

      attr_reader :number

      def initialize(number)
        @number = number
      end

      def ==(other)
        @number == other.number
      end

      def as_json(*)
        @number
      end

      def inspect
        @number
      end
    end

    HandOfNumberCards = Hand.of(NumberCard)

    test "the generated subclasses has a name" do
      assert_equal "Gamemaker::CardGame::HandTest::HandOfNumberCards", HandOfNumberCards.name
      assert_equal "Gamemaker::CardGame::HandTest::NumberCardHand", Hand.of(NumberCard).name
    end

    test "by default, it builds an empty hand" do
      assert_empty HandOfNumberCards.new
    end

    test "it can be initialized with specific cards" do
      cards = [
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ]

      hand = HandOfNumberCards.new(cards)

      assert_equal cards, hand.to_a
      assert_equal 4, hand.length
      refute_empty hand
    end

    test "check whether a card is part of the hand" do
      hand = HandOfNumberCards.new([
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(3),
        NumberCard.new(4)
      ])

      assert hand.include?(NumberCard.new(3))
      assert hand.include?(NumberCard.new(3), NumberCard.new(4))
      assert hand.include?([NumberCard.new(3), NumberCard.new(4)])

      refute hand.include?(NumberCard.new(5))
      refute hand.include?(NumberCard.new(5), NumberCard.new(4))
      refute hand.include?([NumberCard.new(5), NumberCard.new(4)])
    end

    test "cards can be drawn randomly from the hand" do
      cards = [
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(3),
        NumberCard.new(4)
      ]

      hand = HandOfNumberCards.new(cards)

      # Drawing without arguments return a single card
      drawn = hand.draw_randomly
      assert_instance_of NumberCard, drawn
      cards.delete(drawn)

      assert_equal cards, hand.to_a
      assert_equal 3, hand.length
      refute_empty hand

      # Drawing with an argument returns an array of N cards
      drawn = hand.draw_randomly(2)
      assert_equal 2, drawn.length
      cards -= drawn

      assert_equal cards, hand.to_a
      assert_equal 1, hand.length
      refute_empty hand

      # Over-drawing returns whatever is left
      drawn = hand.draw_randomly(2)
      assert_equal 1, drawn.length

      assert_equal 0, hand.length
      assert_empty hand

      assert_nil hand.draw_randomly
      assert_equal 0, hand.draw_randomly(2).length

      assert_equal 0, hand.length
      assert_empty hand
    end

    test "Hand#draw_randomly! protects from over-drawing" do
      hand = HandOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ])

      assert_raises(IndexError) { hand.draw_randomly!(5) }

      assert_equal 4, hand.length
      refute_empty hand

      hand.draw_randomly!

      assert_equal 3, hand.length
      refute_empty hand

      assert_raises(IndexError) { hand.draw_randomly!(4) }

      assert_equal 3, hand.length
      refute_empty hand

      hand.draw_randomly!(3)

      assert_equal 0, hand.length
      assert_empty hand

      assert_raises(IndexError) { hand.draw_randomly!(1) }
      assert_raises(IndexError) { hand.draw_randomly! }

      assert_equal 0, hand.length
      assert_empty hand
    end

    test "specific cards can be removed from the hand" do
      hand = HandOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4),
        NumberCard.new(5)
      ])

      hand.remove(NumberCard.new(1))

      assert_equal 4, hand.length
      refute hand.include?(NumberCard.new(1))

      # Removing a non-existent card is a no-op
      hand.remove(NumberCard.new(6))

      assert_equal 4, hand.length

      # Removing multiple cards
      hand.remove(NumberCard.new(2), NumberCard.new(3), NumberCard.new(6))

      assert_equal 2, hand.length
      refute hand.include?(NumberCard.new(2), NumberCard.new(3))

      # Removing multiple cards with an array
      hand.remove([NumberCard.new(4), NumberCard.new(5), NumberCard.new(6)])

      assert_empty hand
      refute hand.include?(NumberCard.new(4), NumberCard.new(5))
    end

    test "remove! checks for non-existent cards" do
      hand = HandOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4),
        NumberCard.new(5)
      ])

      assert_raises(ArgumentError) { hand.remove!(NumberCard.new(6)) }

      assert_equal 5, hand.length

      hand.remove!(NumberCard.new(1))

      assert_equal 4, hand.length
      refute hand.include?(NumberCard.new(1))

      assert_raises(ArgumentError) { hand.remove!(NumberCard.new(2), NumberCard.new(3), NumberCard.new(6)) }

      assert_equal 4, hand.length
      assert hand.include?(NumberCard.new(2), NumberCard.new(3))

      hand.remove!(NumberCard.new(2), NumberCard.new(3))

      assert_equal 2, hand.length
      refute hand.include?(NumberCard.new(2), NumberCard.new(3))

      assert_raises(ArgumentError) { hand.remove!([NumberCard.new(4), NumberCard.new(5), NumberCard.new(6)]) }

      assert_equal 2, hand.length
      assert hand.include?(NumberCard.new(4), NumberCard.new(5))

      hand.remove!([NumberCard.new(4), NumberCard.new(5)])

      assert_empty hand
      refute hand.include?(NumberCard.new(4), NumberCard.new(5))
    end
  end
end
