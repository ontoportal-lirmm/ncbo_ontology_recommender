require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/scores/score_aggregator'

class TestScoreAggregator < TestCase

  def self.before_suite
    @@score_aggregator = OntologyRecommender::Scores::ScoreAggregator
  end

  def self.after_suite
  end

  def test_get_aggregated_scores
    s1 = OntologyRecommender::Scores::Score.new(0.2, 0.4)
    s2 = OntologyRecommender::Scores::Score.new(0.9, 0.3)
    s3 = OntologyRecommender::Scores::Score.new(0.5, 0.2)
    s4 = OntologyRecommender::Scores::Score.new(0, 0.1)
    scores = [s1, s2, s3, s4]
    aggregated_score = @@score_aggregator.get_aggregated_scores(scores)
    assert_in_delta(0.45, aggregated_score)
  end

end

