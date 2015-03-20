module OntologyRecommender

  module Evaluators

    ##
    # Detail of knowledge of an ontology for a given input
    class DetailResult

      attr_reader :normalizedScore, :definitionsScore, :synonymsScore, :propertiesScore

      def initialize(normalized_score, definitions_score, synonynms_score, properties_score)
        @normalizedScore = normalized_score
        @definitionsScore = definitions_score
        @synonymsScore = synonynms_score
        @propertiesScore = properties_score
      end

    end

  end
end