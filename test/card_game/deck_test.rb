require 'test_helper'
require 'gamemaker/card_game'

module Gamemaker::CardGame
  class DeckTest < Minitest::Test
    test "Deck is an abstract class" do
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

    DeckOfNumberCards = Deck.of(NumberCard)

    test "the generated subclasses has a name" do
      assert_equal "Gamemaker::CardGame::DeckTest::DeckOfNumberCards", DeckOfNumberCards.name
      assert_equal "Gamemaker::CardGame::DeckTest::NumberCardDeck", Deck.of(NumberCard).name
    end

    test "by default, it builds a standard deck from Card.all" do
      standard_cards = NumberCard.all
      deck = DeckOfNumberCards.new

      assert_equal DeckOfNumberCards.new(standard_cards), deck
      assert_equal standard_cards, deck.to_a
      assert_equal 9, deck.length
      refute_empty deck
    end

    test "it can be initialized with specific cards" do
      cards = [
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ]

      deck = DeckOfNumberCards.new(cards)

      assert_equal cards, deck.to_a
      assert_equal 4, deck.length
      refute_empty deck
    end

    test "it can be shuffled" do
      standard_deck, test_deck = DeckOfNumberCards.new, DeckOfNumberCards.new

      assert_equal standard_deck, test_deck

      test_deck.shuffle

      assert_equal 9, test_deck.length
      refute_equal standard_deck, test_deck
    end

    test "a single card can be drawn from the deck" do
      deck = DeckOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ])

      card = deck.draw

      assert_equal NumberCard.new(3), card
      assert_equal 3, deck.length
      refute_empty deck

      # It is aliased to Card#take
      card = deck.take

      assert_equal NumberCard.new(1), card
      assert_equal 2, deck.length
      refute_empty deck

      card = deck.draw

      assert_equal NumberCard.new(2), card
      assert_equal 1, deck.length
      refute_empty deck

      card = deck.draw

      assert_equal NumberCard.new(4), card
      assert_equal 0, deck.length
      assert_empty deck

      card = deck.draw

      assert_nil card
      assert_equal 0, deck.length
      assert_empty deck
    end

    test "multiple cards can be drawn from the deck" do
      deck = DeckOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ])

      cards = deck.draw(2)

      assert_equal [NumberCard.new(3), NumberCard.new(1)], cards
      assert_equal 2, deck.length
      refute_empty deck

      # It is aliased to Card#take
      cards = deck.take(1)

      assert_equal [NumberCard.new(2)], cards
      assert_equal 1, deck.length
      refute_empty deck

      # It returns whatever is left when over-drawn
      cards = deck.draw(3)

      assert_equal [NumberCard.new(4)], cards
      assert_equal 0, deck.length
      assert_empty deck

      cards = deck.draw(3)

      assert_equal [], cards
      assert_equal 0, deck.length
      assert_empty deck
    end

    test "Deck#draw! protects from over-drawing" do
      deck = DeckOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ])

      assert_raises(IndexError) { deck.draw!(5) }
      assert_raises(IndexError) { deck.take!(5) }

      assert_equal 4, deck.length
      refute_empty deck

      deck.draw!

      assert_equal 3, deck.length
      refute_empty deck

      assert_raises(IndexError) { deck.draw!(4) }
      assert_raises(IndexError) { deck.take!(4) }

      assert_equal 3, deck.length
      refute_empty deck

      deck.draw!(3)

      assert_equal 0, deck.length
      assert_empty deck

      assert_raises(IndexError) { deck.draw!(1) }
      assert_raises(IndexError) { deck.take!(1) }

      assert_raises(IndexError) { deck.draw! }
      assert_raises(IndexError) { deck.take! }

      assert_equal 0, deck.length
      assert_empty deck
    end

    test "cards can be added to the bottom of the deck" do
      deck = DeckOfNumberCards.new([NumberCard.new(1)])

      # Putting a single card to the bottom
      deck.put(NumberCard.new(2))

      # Putting a single card to the bottom explicitly
      deck.put(NumberCard.new(3), position: :bottom)

      # Using the << alias
      deck << NumberCard.new(4)

      # Putting multiple cards to the bottom
      deck.put(NumberCard.new(5), NumberCard.new(6), NumberCard.new(7))

      # Putting multiple cards to the bottom with an array
      deck.put([NumberCard.new(8), NumberCard.new(9)])

      expected = DeckOfNumberCards.new([
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(3),
        NumberCard.new(4),
        NumberCard.new(5),
        NumberCard.new(6),
        NumberCard.new(7),
        NumberCard.new(8),
        NumberCard.new(9)
      ])

      assert_equal expected, deck
    end

    test "cards can be added to the top of the deck" do
      deck = DeckOfNumberCards.new([NumberCard.new(1)])

      # Putting a single card to the top
      deck.put(NumberCard.new(2), position: :top)

      # Using the undraw alias
      deck.undraw(NumberCard.new(3))

      # Using the untake alias
      deck.untake(NumberCard.new(4))

      # Putting multiple cards to the top
      deck.put(NumberCard.new(5), NumberCard.new(6), NumberCard.new(7), position: :top)

      # Putting multiple cards to the top with an array
      deck.put([NumberCard.new(8), NumberCard.new(9)], position: :top)

      expected = DeckOfNumberCards.new([
        NumberCard.new(8),
        NumberCard.new(9),
        NumberCard.new(5),
        NumberCard.new(6),
        NumberCard.new(7),
        NumberCard.new(4),
        NumberCard.new(3),
        NumberCard.new(2),
        NumberCard.new(1)
      ])

      assert_equal expected, deck
    end

    test "it can be merged with another deck" do
      deck = DeckOfNumberCards.new([
        NumberCard.new(7),
        NumberCard.new(8),
        NumberCard.new(1),
        NumberCard.new(3),
        NumberCard.new(5)
      ])

      discard_pile = DeckOfNumberCards.new([
        NumberCard.new(2),
        NumberCard.new(9),
        NumberCard.new(4),
        NumberCard.new(6)
      ])

      deck.merge(discard_pile)

      expected = DeckOfNumberCards.new([
        NumberCard.new(7),
        NumberCard.new(8),
        NumberCard.new(1),
        NumberCard.new(3),
        NumberCard.new(5),
        NumberCard.new(2),
        NumberCard.new(9),
        NumberCard.new(4),
        NumberCard.new(6)
      ])

      assert_equal expected, deck
      assert_empty discard_pile
    end

    test "it can be serialized into JSON" do
      json = { cards: [3,1,2,4] }

      deck = DeckOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ])

      assert_to_json json, deck
    end

    test "it can be deserialized from JSON" do
      json = { cards: [3,1,2,4] }

      deck = DeckOfNumberCards.new([
        NumberCard.new(3),
        NumberCard.new(1),
        NumberCard.new(2),
        NumberCard.new(4)
      ])

      assert_from_json DeckOfNumberCards, json, deck
    end
  end
end
