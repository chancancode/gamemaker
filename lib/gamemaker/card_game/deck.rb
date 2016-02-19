module Gamemaker
  module CardGame
    class Deck
      def self.card_class
        raise NotImplementedError, "Deck is an abstract class, use Deck.of(CardType) to create a usable subclass"
      end

      def self.of(card_class)
        Class.new(self) do
          define_singleton_method(:name) { super() || "#{card_class.name}Deck" }
          define_singleton_method(:card_class) { card_class }
        end
      end

      def self.from_json(json)
        new(json["cards"].map { |card| card_class.from_json(card) })
      end

      def initialize(cards = self.class.card_class.all)
        @cards = cards.dup
      end

      def length
        @cards.length
      end

      def empty?
        @cards.empty?
      end

      def shuffle!
        @cards.shuffle!
        self
      end

      def draw(n = nil)
        n ? @cards.shift(n) : @cards.shift
      end

      alias_method :take, :draw

      def draw!(n = nil)
        if n && n > @cards.length
          raise IndexError, "Cannot draw #{n} cards from the deck: only #{@cards.length} cards left"
        elsif !n && empty?
          raise IndexError, "Cannot draw from the deck: no cards left"
        else
          draw(n)
        end
      end

      alias_method :take!, :draw!

      def put(*cards, position: :bottom)
        case position
        when :top
          undraw(*cards)
        when :bottom
          self << cards
        else
          raise ArgumentError, "Cannot put cards to #{position.inspect}"
        end
      end

      def <<(*cards)
        @cards.concat(cards.flatten)
        self
      end

      def undraw(*cards)
        @cards = cards.flatten + @cards
        self
      end

      alias_method :untake, :undraw

      def merge!(other)
        self << other.draw(other.length)
      end

      def to_a
        @cards.dup
      end

      def ==(other)
        @cards == other.to_a
      end

      def as_json(*)
        { cards: to_a }
      end
    end
  end
end
