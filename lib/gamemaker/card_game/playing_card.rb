module Gamemaker
  module CardGame
    class PlayingCard < Card
      SUITS = [:clubs, :diamonds, :hearts, :spades]
      RANKS = [:ace, 2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king]

      attr_reader :suit, :rank

      def self.all
        cards = []

        SUITS.each do |suit|
          RANKS.each do |rank|
            cards << new(suit, rank)
          end
        end

        cards
      end

      def self.from_json(json)
        suit, rank = json["suit"], json["rank"]

        suit = suit.to_sym
        rank = rank.to_sym if String === rank

        new(suit, rank)
      end

      def initialize(suit, rank)
        unless SUITS.include?(suit)
          raise ArgumentError, "Invalid suit: #{suit.inspect}"
        end

        if Fixnum === rank && rank > 0
          rank = RANKS[rank - 1]
        end

        unless RANKS.include?(rank)
          raise ArgumentError, "Invalid rank: #{rank.inspect}"
        end

        @suit = suit
        @rank = rank
      end

      def clubs?
        @suit == :clubs
      end

      def diamonds?
        @suit == :diamonds
      end

      def hearts?
        @suit == :hearts
      end

      def spades?
        @suit == :spades
      end

      def ace?
        @rank == :ace
      end

      def jack?
        @rank == :jack
      end

      def queen?
        @rank == :queen
      end

      def king?
        @rank == :king
      end

      def ==(other)
        @rank == other.rank && @suit == other.suit
      end

      def as_json(*)
        { suit: @suit, rank: @rank }
      end
    end

    class PlayingCardDeck < Deck.of(PlayingCard)
    end
  end
end
