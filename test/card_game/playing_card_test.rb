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

    test "PlayingCardTest.all returns an array of cards from the standard deck" do
      standard_cards = []

      SUITS.each do |suit|
        RANKS.each do |rank|
          standard_cards << PlayingCard.new(suit, rank)
        end
      end

      assert_equal standard_cards, PlayingCard.all
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
  end
end
