require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/detail_evaluator'
require_relative '../../lib/ncbo_ontology_recommender/utils/utils'

class TestSpecializationEvaluator < TestCase

  def self.before_suite
    @@top_defs = 1
    @@top_syns = 3
    @@top_props = 17
  end

  def self.after_suite
  end

  def test_evaluate
    input = 'An article has been published about hormone antagonists'
    input_type = 1
    ontologies = []
    annotations = OntologyRecommender::Utils::AnnotatorUtils.get_annotations(input, input_type, nil, ontologies)
    annotations_hash = annotations.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
    # Annotations:
    # - MCCLTEST-0 -> hormone antagonists
    # - ONTOMATEST-0 -> article
    detail_evaluator = OntologyRecommender::Evaluators::DetailEvaluator.new(@@top_defs, @@top_syns, @@top_props)
    result1 = detail_evaluator.evaluate(annotations_hash['MCCLTEST-0'])
    result2 = detail_evaluator.evaluate(annotations_hash['ONTOMATEST-0'])
    # TODO: finish this test
  end

end