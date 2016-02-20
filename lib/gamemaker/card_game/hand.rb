module Gamemaker
  module CardGame
    class Hand < Deck
      def self.card_class
        raise NotImplementedError, "Hand is an abstract class, use Hand.of(CardType) to create a usable subclass"
      end

      def self.of(card_class)
        Class.new(self) do
          define_singleton_method(:name) { super() || "#{card_class.name}Hand" }
          define_singleton_method(:card_class) { card_class }
        end
      end

      def initialize(cards = [])
        super(cards)
      end

      def include?(*cards)
        cards.flatten.all? { |card| @cards.include?(card) }
      end

      def draw_randomly(n = nil)
        drawn = n ? @cards.sample(n) : @cards.sample
        remove(*Array(drawn))
        drawn
      end

      def draw_randomly!(n = nil)
        if n && n > @cards.length
          raise IndexError, "Tried to draw #{n} cards when there were only #{@cards.length} cards left"
        elsif !n && empty?
          raise IndexError, "Tried to draw a card when there were no cards left"
        else
          draw_randomly(n)
        end
      end

      def remove(*cards)
        cards = cards.flatten
        @cards.delete_if { |card| cards.include?(card) }
        self
      end

      def remove!(*cards)
        cards.flatten.each do |card|
          unless @cards.include?(card)
            raise ArgumentError, "Cannot remove #{card} as it's not part of the hand"
          end
        end

        remove(*cards)
      end
    end
  end
end
