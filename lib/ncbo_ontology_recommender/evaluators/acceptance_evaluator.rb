require_relative '../../../lib/ncbo_ontology_recommender/config'
require_relative 'acceptance_result'

module OntologyRecommender

  module Evaluators

    ##
    # Ontology acceptance evaluator
    class AcceptanceEvaluator
      # - w_bp: weight assigned to the number of visits (pageviews) received by the ontology in BioPortal
      # - w_umls: weight assigned to the criteria "is the ontology included into UMLS?"
      # - w_pmed: weight assigned to the number of PubMed articles that mention the ontology
      def initialize(w_bp, w_umls, w_pmed)
        # @w_bp = w_bp
        # @w_umls = w_umls
        # @w_pmed = w_pmed
        # # TODO: read paths from config file
        # @bp_scores = scores_to_hash(OntologyRecommender.settings.bp_scores_file, '|')
        # @umls_scores = scores_to_hash(OntologyRecommender.settings.umls_scores_file, '|')
        # @pmed_scores = scores_to_hash(OntologyRecommender.settings.pmed_scores_file, '|')
      end

      def evaluate(ont_acronym)
        # TODO:
        return OntologyRecommender::Evaluators::AcceptanceResult.new(0, 0, 0, 0)
        # ont_acronym = OntologyRecommender::Utils.get_ont_acronym_from_uri(ont_uri)
        # bp_score = (@bp_scores[ont_acronym] != nil)? @bp_scores[ont_acronym] : 0
        # umls_score = (@umls_scores[ont_acronym] != nil)? @umls_scores[ont_acronym] : 0
        # pmed_score = (@pmed_scores[ont_acronym] != nil)? @pmed_scores[ont_acronym] : 0
        # score = (@w_bp * bp_score) + (@w_umls * umls_score) + (@w_pmed * pmed_score)
        # return OntologyRecommender::Evaluators::AcceptanceResult.new(score, bp_score, umls_score, pmed_score)
      end

      private
      def scores_to_hash(file_path, delimiter)
        scores_hash = { }
        lines = File.open(file_path).readlines
        lines.each do |line|
          ont_acronym = line.chomp.split(delimiter)[0]
          score = line.chomp.split(delimiter)[1].to_f
          scores_hash[ont_acronym] = score
        end
        return scores_hash
      end

    end

  end

end