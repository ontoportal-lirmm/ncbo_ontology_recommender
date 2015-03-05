require_relative 'specialization_result'
module OntologyRecommender

  module Evaluators

    ##
    # Ontology specialization evaluator
    class SpecializationEvaluator
      attr_reader :pref_score, :syn_score, :multiterm_score

      def initialize
        @spec_scores_hash = nil
      end

      def evaluate(annotations_hash, ont_acronym)
        # TODO:
        return OntologyRecommender::Evaluators::SpecializationResult.new(0, 0)
        # if @spec_scores_hash != nil
        #   return @spec_scores_hash[ont_uri]
        # else
        #   @spec_scores_hash = { }
        #   top_spec_score = 0
        #   annotations_hash.each do |uri, anns|
        #     # Number of classes in the ontology
        #     num_classes = get_number_of_classes(uri)
        #     # Number of annotations done with the ontology
        #     num_annotations = anns.size
        #
        #     spec_score = num_annotations.to_f / Math.log10(num_classes)
        #     if spec_score > top_spec_score
        #       top_spec_score = spec_score
        #     end
        #     # The normalized score will be computed and assigned after evaluating all ontologies
        #     norm_spec_score = nil
        #     @spec_scores_hash[uri] = OntologyRecommender::Evaluators::SpecializationResult.new(spec_score, norm_spec_score)
        #   end
        #
        #   @spec_scores_hash.each do |uri, spec_result|
        #     spec_result.normalizedScore = OntologyRecommender::Utils.normalize(spec_result.score, 0, top_spec_score, 0, 1)
        #     @spec_scores_hash[uri] = spec_result
        #   end
        #   return @spec_scores_hash[ont_uri]
        # end
      end

      # TODO: obtain number of classes. It could be inside some Utils class
      private
      def get_number_of_classes(ont_acronym)
        return 1000
      end

    end

  end

end