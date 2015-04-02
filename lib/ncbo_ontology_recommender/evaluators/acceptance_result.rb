module OntologyRecommender

  module Evaluators
    ##
    # Acceptance of an ontology by the biomedical community
    class AcceptanceResult

      attr_reader :normalizedScore, :bioportalScore, :umlsScore

      def initialize(normalized_score, bioportal_score, umls_score)
        @normalizedScore = normalized_score
        @bioportalScore = bioportal_score
        @umlsScore = umls_score
      end

    end
  end
end