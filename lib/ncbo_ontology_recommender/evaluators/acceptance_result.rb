module OntologyRecommender

  module Evaluators
    ##
    # Acceptance of an ontology by the biomedical community
    class AcceptanceResult

      attr_reader :score, :bioportal_score, :umls_score, :pubmed_score

      def initialize(score, bioportal_score, umls_score, pubmed_score)
        @score = score
        @bioportalScore = bioportal_score
        @umlsScore = umls_score
        @pubmedScore = pubmed_score
      end

    end
  end
end