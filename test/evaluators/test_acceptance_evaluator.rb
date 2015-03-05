require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/acceptance_evaluator'

class TestAcceptanceEvaluator < TestCase

  def self.before_suite
   
  end

  def self.after_suite
  end

  # TODO:
  def test_evaluate
    w_bp = 0.34
    w_umls = 0.33
    w_pmed = 0.33
    acceptance_evaluator = OntologyRecommender::Evaluators::AcceptanceEvaluator.new(w_bp, w_umls, w_pmed)
    puts acceptance_evaluator.evaluate('NCIT').inspect
  end

end

