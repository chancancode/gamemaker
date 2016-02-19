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
    end
  end
end
