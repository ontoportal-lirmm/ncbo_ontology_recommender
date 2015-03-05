module OntologyRecommender

  module Scores

    class Score
      attr_reader :score, :weight
      def initialize(score, weight)
        @score = score
        @weight = weight
      end
    end

  end

end
