module OntologyRecommender

  module Evaluators
    ##
    # Degree of specialization of an ontology for a given input
    class SpecializationResult

      include LinkedData::Hypermedia::Resource
      attr_reader :score
      attr_accessor :normalizedScore

      def initialize(score, normalized_score)
        @score = score
        @normalizedScore = normalized_score
      end
    end

  end
end