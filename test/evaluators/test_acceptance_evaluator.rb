require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/acceptance_evaluator'

class TestAcceptanceEvaluator < TestCase

  def self.before_suite
    @@w_bp = OntologyRecommender.settings.w_bp
    @@w_umls = OntologyRecommender.settings.w_umls
    @@acceptance_evaluator = OntologyRecommender::Evaluators::AcceptanceEvaluator.new(@@w_bp, @@w_umls, ['BROTEST-0', 'MCCLTEST-0', 'ONTOMATEST-0'])
  end

  def self.after_suite
  end

  def test_evaluate
    result1 = @@acceptance_evaluator.evaluate('BROTEST-0')
    result2 = @@acceptance_evaluator.evaluate('MCCLTEST-0')
    result3 = @@acceptance_evaluator.evaluate('ONTOMATEST-0')
    assert(result1.normalizedScore > 0)
    assert(result2.normalizedScore > 0)
    assert_equal(0.481, result3.normalizedScore)
    assert(result1.normalizedScore > result2.normalizedScore)
  end

end

