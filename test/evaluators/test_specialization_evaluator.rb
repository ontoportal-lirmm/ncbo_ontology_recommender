require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/specialization_evaluator'
require_relative '../../lib/ncbo_ontology_recommender/utils/utils'

class TestSpecializationEvaluator < TestCase

  def self.before_suite
    @@custom_annotation = OntologyRecommender::Utils::AnnotatorUtils::CustomAnnotation
  end

  def self.after_suite
  end

  def test_evaluate
    specialization_evaluator = OntologyRecommender::Evaluators::SpecializationEvaluator.new
    input = 'software, hormone'
    # Expected annotations:
    # - MCCLTEST-0 -> hormone
    # - BROTEST-0 -> software
    annotations = OntologyRecommender::Utils::AnnotatorUtils.get_annotations(input, 2, ',', [])
    annotations_hash = annotations.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
    result1 = specialization_evaluator.evaluate(annotations_hash, 'MCCLTEST-0')
    result2 = specialization_evaluator.evaluate(annotations_hash, 'BROTEST-0')
    result3 = specialization_evaluator.evaluate(annotations_hash, 'ONTOMATEST-0')
    assert(result1.score > 0)
    assert(result1.normalizedScore > 0)
    assert(result2.score > 0)
    assert(result2.normalizedScore > 0)
    # The result for the ontology that does not provide any annotations must be zero
    assert_equal(0, result3.score)
    assert_equal(0, result3.normalizedScore)
  end

end