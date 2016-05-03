require_relative '../../../lib/ncbo_ontology_recommender/config'
require_relative 'acceptance_result'

module OntologyRecommender

  module Evaluators

    ##
    # Ontology acceptance evaluator
    class AcceptanceEvaluator

      # - w_bp: weight assigned to the number of visits (pageviews) received by the ontology in BioPortal
      # - w_umls: weight assigned to the criteria "is the ontology included into UMLS?"
      def initialize(w_bp, w_umls, acronyms=nil)
        @logger = Kernel.const_defined?('LOGGER') ? Kernel.const_get('LOGGER') : Logger.new(STDOUT)
        @w_bp = w_bp
        @w_umls = w_umls
        @rank_data = acronyms.nil? || acronyms.empty? ? nil : LinkedData::Models::Ontology.rank(@w_bp, @w_umls, acronyms)
      end

      def evaluate(ont_acronym)
        rank_data = @rank_data || LinkedData::Models::Ontology.rank(@w_bp, @w_umls, [ont_acronym])
        rank = rank_data[ont_acronym] || {}
        bp_score = rank[:bioportalScore] || 0.0
        umls_score = rank[:umlsScore] || 0.0
        norm_score = rank[:normalizedScore] || 0.0
        OntologyRecommender::Evaluators::AcceptanceResult.new(norm_score, bp_score, umls_score)
      end

    end
  end
end