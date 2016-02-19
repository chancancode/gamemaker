require 'test_helper'
require 'gamemaker/card_game'

module Gamemaker::CardGame
  class PlayingCardTest < Minitest::Test
    # These are intentionally duplicated from the PlayingCard class
    SUITS = [:clubs, :diamonds, :hearts, :spades]
    RANKS = [:ace, 2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king]

    test "it has a suite and a rank" do
      assert_suit_and_rank PlayingCard.new(:clubs, :ace), :clubs, :ace
      assert_suit_and_rank PlayingCard.new(:diamonds, 3), :diamonds, 3
      assert_suit_and_rank PlayingCard.new(:hearts, :jack), :hearts, :jack
      assert_suit_and_rank PlayingCard.new(:spades, :king), :spades, :king
    end

    test "it can take numeric aliases for named ranks" do
      assert_suit_and_rank PlayingCard.new(:clubs, 1), :clubs, :ace
      assert_suit_and_rank PlayingCard.new(:hearts, 11), :hearts, :jack
      assert_suit_and_rank PlayingCard.new(:spades, 13), :spades, :king
    end

    test "it raises when passed invalid arguments" do
      assert_raises(ArgumentError) { PlayingCard.new(:clubs, 0) }
      assert_raises(ArgumentError) { PlayingCard.new(:clubs, 14) }
      assert_raises(ArgumentError) { PlayingCard.new(:clubs, :zomg) }
      assert_raises(ArgumentError) { PlayingCard.new(:zomg, 3) }
    end

    test "its equality is based on suit and rank" do
      assert PlayingCard.new(:clubs, :ace) == PlayingCard.new(:clubs, :ace)
      refute PlayingCard.new(:clubs, :ace) == PlayingCard.new(:clubs, 3)
      refute PlayingCard.new(:clubs, :ace) == PlayingCard.new(:diamonds, :ace)
    end

    test "it can be serialized into JSON" do
      assert_to_json({ suit: "clubs", rank: "ace" }, PlayingCard.new(:clubs, :ace))
      assert_to_json({ suit: "diamonds", rank: 3 }, PlayingCard.new(:diamonds, 3))
    end

    test "it can be deserialized from JSON" do
      assert_from_json PlayingCard, { suit: "clubs", rank: "ace" }, PlayingCard.new(:clubs, :ace)
      assert_from_json PlayingCard, { suit: "diamonds", rank: 3 }, PlayingCard.new(:diamonds, 3)
    end

    test "PlayingCard.all returns an array of cards from the standard deck" do
      standard_cards = []

      SUITS.each do |suit|
        RANKS.each do |rank|
          standard_cards << PlayingCard.new(suit, rank)
        end
      end

      assert_equal standard_cards, PlayingCard.all
    end

    test "it has a simple to_s" do
      ace_of_clubs = PlayingCard.new(:clubs, :ace)
      assert_equal "♣A", ace_of_clubs.to_s
      assert_equal "♣A", ace_of_clubs.to_s(:simple)

      diamonds_10 = PlayingCard.new(:diamonds, 10)
      assert_equal "♦10", diamonds_10.to_s
      assert_equal "♦10", diamonds_10.to_s(:simple)
    end

    test "it has a fancy to_s" do
      ace_of_clubs = PlayingCard.new(:clubs, :ace)
      ace_of_clubs_fancy = "┌──┐\n" \
                           "│♣A|\n" \
                           "└──┘\n"

      assert_equal ace_of_clubs_fancy, ace_of_clubs.to_s(:fancy)

      diamonds_10 = PlayingCard.new(:diamonds, 10)
      diamonds_10_fancy = "┌──┐\n" \
                          "│♦10\n" \
                          "└──┘\n"

      assert_equal diamonds_10_fancy, diamonds_10.to_s(:fancy)
    end

    test "it has a unicode glyph to_s" do
      ace_of_clubs = PlayingCard.new(:clubs, :ace)
      assert_equal "🃑", ace_of_clubs.to_s(:glyph)

      diamonds_10 = PlayingCard.new(:diamonds, 10)
      assert_equal "🃊", diamonds_10.to_s(:glyph)
    end

    private

    def assert_suit_and_rank(card, expected_suit, expected_rank)
      assert_suit card, expected_suit
      assert_rank card, expected_rank
    end

    def assert_suit(card, expected_suit)
      assert_equal card.suit, expected_suit

      SUITS.each do |suit|
        if suit == expected_suit
          assert_predicate card, :"#{suit}?"
        else
          refute_predicate card, :"#{suit}?"
        end
      end
    end

    def assert_rank(card, expected_rank)
      assert_equal card.rank, expected_rank

      RANKS.each do |rank|
        if Symbol === rank
          if rank == expected_rank
            assert_predicate card, :"#{rank}?"
          else
            refute_predicate card, :"#{rank}?"
          end
        end
      end
    end

    class PlayingCardDeckTest < Minitest::Test
      test "it produces the standard deck by default" do
        assert_equal PlayingCard.all, PlayingCardDeck.new.to_a
      end
    end

    class PlayingCardHandTest < Minitest::Test
      test "it produces an empty hand by default" do
        assert_empty PlayingCardHand.new
      end

      test "it has a simple to_s" do
        hand = PlayingCardHand.new([
          PlayingCard.new(:clubs, :ace),
          PlayingCard.new(:diamonds, 10),
          PlayingCard.new(:spades, :king)
        ])

        assert_equal "♣A ♦10 ♠K", hand.to_s
        assert_equal "♣A ♦10 ♠K", hand.to_s(:simple)
        assert_equal "♣A, ♦10, ♠K", hand.to_s(:simple, seperator: ', ')
      end

      test "it has a fancy to_s" do
        hand = PlayingCardHand.new([
          PlayingCard.new(:clubs, :ace),
          PlayingCard.new(:diamonds, 10),
          PlayingCard.new(:spades, :king)
        ])

        expected = "┌──┐ ┌──┐ ┌──┐\n" \
                   "│♣A| │♦10 │♠K|\n" \
                   "└──┘ └──┘ └──┘\n"

        assert_equal expected, hand.to_s(:fancy)

        expected_with_seperator = "┌──┐  ┌──┐  ┌──┐\n" \
                                  "│♣A|  │♦10  │♠K|\n" \
                                  "└──┘, └──┘, └──┘\n"


        assert_equal expected_with_seperator, hand.to_s(:fancy, seperator: ', ')

        expected_with_seperators = "┌──┐   ┌──┐   ┌──┐\n" \
                                   "│♣A| / │♦10 / │♠K|\n" \
                                   "└──┘   └──┘   └──┘\n"

        assert_equal expected_with_seperators, hand.to_s(:fancy, seperators: ['   ', ' / ', '   '])
      end

      test "it has a unicode glyph to_s" do
        hand = PlayingCardHand.new([
          PlayingCard.new(:clubs, :ace),
          PlayingCard.new(:diamonds, 10),
          PlayingCard.new(:spades, :king)
        ])

        assert_equal "🃑 🃊 🂮", hand.to_s(:glyph)
        assert_equal "🃑, 🃊, 🂮", hand.to_s(:glyph, seperator: ', ')
      end
    end
  end
end
