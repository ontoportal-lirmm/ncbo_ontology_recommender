module OntologyRecommender

    class Recommendation

      include LinkedData::Hypermedia::Resource

      attr_reader :ontologies, :ontologyUrisUi, :ontologyAcronyms, :evaluationScore,
                  :coverageResult, :specializationResult, :acceptanceResult, :detailResult

      embed :ontologies, :coverageResult, :specialization_result, :acceptance_result, :detail_result

      def initialize(score, ontologies, coverage_result, specialization_result, acceptance_result, detail_result)
        @evaluationScore = score
        @ontologies = ontologies
        @coverageResult = coverage_result
        @specializationResult = specialization_result
        @acceptanceResult = acceptance_result
        @detailResult = detail_result
      end

  end

end