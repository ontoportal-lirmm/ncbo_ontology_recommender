module OntologyRecommender

  module Scores

    module ScoreAggregator

      module_function
      def get_aggregated_scores(scores)
        final_score = 0
        scores.each do |s|
          final_score += s.score.to_f * s.weight.to_f
        end
        return final_score
      end

    end

  end

end
