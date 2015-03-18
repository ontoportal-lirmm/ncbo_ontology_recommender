require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/acceptance_evaluator'

class TestAcceptanceEvaluator < TestCase

  def self.before_suite
    @@w_bp = 0.5
    @@w_umls = 0.5
    @@acceptance_evaluator = OntologyRecommender::Evaluators::AcceptanceEvaluator.new(@@w_bp, @@w_umls)
  end

  def self.after_suite
  end

  def test_evaluate
    acronyms = ['BROTEST-0', 'MCCLTEST-0', 'ONTOMATEST-0']
    result1 = @@acceptance_evaluator.evaluate(acronyms, 'BROTEST-0', 2015, 3)
    result2 = @@acceptance_evaluator.evaluate(acronyms, 'MCCLTEST-0', 2015, 3)
    result3 = @@acceptance_evaluator.evaluate(acronyms, 'ONTOMATEST-0', 2015, 3)
    assert(result1.normalizedScore > 0)
    assert(result2.normalizedScore > 0)
    assert_equal(0, result3.normalizedScore)
    assert(result1.normalizedScore > result2.normalizedScore)
  end

  def test_get_umls_score
    # TODO: check that the method returns 1 for an ontology that belongs to UMLS
    acronyms = ['BROTEST-0', 'MCCLTEST-0', 'ONTOMATEST-0']
    # The send method bypasses encapsulation, allowing to call private methods
    assert_equal(0, @@acceptance_evaluator.send(:get_umls_score, acronyms, 'BROTEST-0'))
    assert_equal(0, @@acceptance_evaluator.send(:get_umls_score, acronyms, 'NOT_EXISTING_ONT'))
  end

  def test_get_bp_score
    assert(@@acceptance_evaluator.send(:get_bp_score, 'BROTEST-0', 12, 2015, 3) > 0, msg = 'The acceptance score should be greater than zero')
  end

  def test_get_visits_for_period
    visits_hash = @@acceptance_evaluator.send(:get_visits_for_period, 12, 2015, 3)
    exp = 230
    assert_equal(exp, visits_hash['BROTEST-0'])
  end

  def test_get_last_periods
    num_months = 6
    current_year = 2015
    current_month = 3
    result = @@acceptance_evaluator.send(:get_last_periods, num_months, current_year, current_month)
    exp = [[2015, 2], [2015, 1], [2014, 12], [2014, 11], [2014, 10], [2014, 9]]
    assert_equal(exp, result)
  end

end

