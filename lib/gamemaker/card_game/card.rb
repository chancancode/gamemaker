module Gamemaker
  module CardGame
    class Card
      # This method should return an array of all possible Cards
      def self.all
        raise NotImplementedError
      end

      # Deserialize the (parsed) +json+ data into a Card object
      def self.from_json(json)
        raise NotImplementedError
      end

      def initialize
        if self.class == Card
          raise NotImplementedError, "Card is an abstract class"
        end
      end

      # Checks if this Card is equal to the +other+ Card
      def ==(other)
        raise NotImplementedError
      end

      # Retrun a JSON-serializable representation of this Card
      def as_json(*)
        raise NotImplementedError
      end
    end
  end
end
