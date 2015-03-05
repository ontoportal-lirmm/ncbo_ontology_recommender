require_relative 'coverage_result'
module OntologyRecommender

  module Evaluators

    ##
    # Ontology coverage evaluator
    class CoverageEvaluator
      attr_reader :pref_score, :syn_score, :multiterm_score
      # - pref_score: score assigned to "PREF" annotations (done with a concept preferred name)
      # - syn_score: score assigned to "SYN" annotations (done with a concept synonym)
      # - multiterm_score: score assigned to annotations done with multi-word terms (e.g. white blood cell)
      def initialize(pref_score, syn_score, multiterm_score)
        @pref_score = pref_score
        @syn_score = syn_score
        @multiterm_score = multiterm_score
        @input = nil
        @annotations_all = nil
        @top_score = nil
      end

      def evaluate(input, annotations_all, annotations_ontology)
        # Selects the best annotations for the input
        best_annotations = select_best_annotations_for_input(input, annotations_ontology)
        # Computes the score for the selected annotations
        score = 0
        best_annotations.each do |ann|
          score += get_annotation_score(ann)
        end

        # Prevents from computing the top score multiple times
        if @top_score==nil or input != @input or annotations_all != @annotations_all
          @top_score = get_top_coverage_score(input, annotations_all)
          @input = input
          @annotations_all = annotations_all
        end

        # Score normalization
        normalized_score = @top_score == 0? 0 : (score.to_f / @top_score.to_f)

        # Number of terms and words covered
        number_terms_covered = best_annotations.length
        number_words_covered = 0
        best_annotations.each do |ann| number_words_covered += ann.text.split(" ").length end

        return OntologyRecommender::Evaluators::CoverageResult.
            new(score, normalized_score, number_terms_covered, number_words_covered, best_annotations)
      end

      def get_annotation_score(annotation)
        number_of_words = annotation.text.split(" ").length
        match_type_score = annotation.matchType == 'PREF' ? @pref_score : @syn_score
        if number_of_words == 1
          score = match_type_score
        else
          score = (match_type_score + @multiterm_score) * number_of_words
        end
        return score
      end

      # Selects the best annotations for the input. For each input substring (fragment),
      # it will select the annotation with the highest score.
      # NOTE: the argument 'annotations' represents the annotations for a specific ontology
      private
      def select_best_annotations_for_input(input, annotations)
        best_annotations = [ ]
        from = 1
        while from < input.length
          to = from + 1
          # Obtains all annotations for a text fragment
          annotations_for_fragment = OntologyRecommender::Utils::AnnotatorUtils.get_annotations_for_fragment(from, to, annotations)
          if annotations_for_fragment.length > 0
            scores_hash = Hash[annotations_for_fragment.collect { |ann| [ann, get_annotation_score(ann)] }]
            # Keeps only the best annotation. If there are several annotations with the same score, only one of them
            # (the first one) is kept.
            max_score = scores_hash.values.max
            best_annotation = scores_hash.select{|ann, score| score == max_score}.keys[0]
            best_annotations << best_annotation
            from = best_annotation.to + 1
          else
            from += 1
          end
        end
        return best_annotations
      end

      ##
      # Obtains the maximum possible coverage score provided by all the annotations done with all BioPortal ontologies.
      private
      def get_top_coverage_score(input, annotations_all)
        # Selects the annotations that provide the best score
        best_all_annotations = select_best_annotations_for_input(input, annotations_all)
        # The maximum possible score is computed as the sum of all scores
        top_score = 0
        best_all_annotations.each do |ann|
          top_score += get_annotation_score(ann)
        end
        return top_score
      end

    end

  end

end