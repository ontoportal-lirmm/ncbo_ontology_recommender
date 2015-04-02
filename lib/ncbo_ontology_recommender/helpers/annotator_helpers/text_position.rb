
module OntologyRecommender

  module Helpers

    module AnnotatorHelper

      ##
      # This class represents a substring position.
      class TextPosition
        attr_reader :start, :end
        def initialize(a, b)
          @start = a
          @end = b
        end
        def ==(p1)
          (self.start == p1.start) and (self.end == p1.end)
        end
      end

    end
  end
end
