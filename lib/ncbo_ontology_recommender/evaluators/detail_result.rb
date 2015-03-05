module OntologyRecommender

  module Evaluators

    ##
    #
    class DetailResult

      attr_reader :score

      def initialize(score)
        @score = score
      end

    end

  end
end