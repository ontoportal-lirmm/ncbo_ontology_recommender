module OntologyRecommender

  module Evaluators
    ##
    # Coverage provided by an ontology for a given input
    class CoverageResult

      include LinkedData::Hypermedia::Resource
      attr_reader :score, :normalizedScore, :numberTermsCovered, :numberWordsCovered, :annotations

      embed :annotations

      def initialize(score, normalized_score, number_terms_covered, number_words_covered, annotations)
        @score = score
        @normalizedScore = normalized_score
        @numberTermsCovered = number_terms_covered
        @numberWordsCovered = number_words_covered
        @annotations = annotations
      end
    end

  end
end