require_relative 'specialization_result'
module OntologyRecommender

  module Evaluators

    ##
    # Ontology specialization evaluator
    class SpecializationEvaluator
      def initialize
        @spec_scores_hash = nil
      end

      def evaluate(annotations_hash, ont_acronym)
        if @spec_scores_hash != nil
          @spec_scores_hash[ont_acronym]!=nil ? (return @spec_scores_hash[ont_acronym]) : (return OntologyRecommender::Evaluators::SpecializationResult.new(0, 0))
        else
          @spec_scores_hash = { }
          top_spec_score = 0
          annotations_hash.each do |ont_acronym, anns|
            # Number of classes in the ontology
            num_classes = Utils.get_number_of_classes(ont_acronym)
            # Number of annotations done with the ontology
            num_annotations = anns.size
            spec_score = num_annotations.to_f / Math.log10(num_classes)
            if spec_score > top_spec_score
              top_spec_score = spec_score
            end
            # The normalized score will be computed and assigned after evaluating all ontologies
            norm_spec_score = nil
            @spec_scores_hash[ont_acronym] = OntologyRecommender::Evaluators::SpecializationResult.new(spec_score, norm_spec_score)
          end

          @spec_scores_hash.each do |ont_acronym, spec_result|
            spec_result.normalizedScore = OntologyRecommender::Utils.normalize(spec_result.score, 0, top_spec_score, 0, 1)
            @spec_scores_hash[ont_acronym] = spec_result
          end
          @spec_scores_hash[ont_acronym]!=nil ? (return @spec_scores_hash[ont_acronym]) : (return OntologyRecommender::Evaluators::SpecializationResult.new(0, 0))
        end
      end

      # TODO: improve specialization formula. That will also require to finish writing this method
      # Provides the decile that corresponds to a number of classes. The limits of the intervals correspond to the deciles
      # calculated for the number of classes for all BioPortal ontologies
      # def normalize_num_classes(num_classes)
      #   limits_intervals = [57, 143, 244, 387, 630, 1294, 2101, 4565, 19320, 847760]
      #   result = 0
      #   if num_classes > 0
      #     if num_classes < limits_intervals.last
      #
      #     else
      #       result = 1
      #     end
      #     index = 0
      #     limit_intervals.each do |limit|
      #       if index < limit
      #     end
      #   end
      #   return result
      end

  end

end