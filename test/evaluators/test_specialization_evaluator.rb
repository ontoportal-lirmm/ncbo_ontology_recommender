require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/specialization_evaluator'

class TestSpecializationEvaluator < TestCase

  def self.before_suite
    @@custom_annotation = OntologyRecommender::Utils::AnnotatorUtils::CustomAnnotation
  end

  def self.after_suite
  end

  # def test_evaluate
  #   # TODO: this test should be written using the sample ontologies because it is necessary to obtain the total number of classes
  #   specialization_evaluator = OntologyRecommender::Evaluators::SpecializationEvaluator.new
  #   # input = 'melanoma, white blood cell, melanoma,     arm, cavity of stomach'
  #   a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   a2 = @@custom_annotation.new(11, 26, 'PREF', 'WHITE BLOOD CELL', 'o1_uri', 'o1_acronym', 'o1_uri/wbc', nil)
  #   a3 = @@custom_annotation.new(29, 36, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   a4 = @@custom_annotation.new(43, 45, 'SYN', 'ARM', 'o1_uri', 'o1_acronym', 'o1_uri/arm', nil)
  #   a5 = @@custom_annotation.new(58, 64, 'PREF', 'STOMACH', 'o1_uri', 'o1_acronym', 'o1_uri/stomach', nil)
  #   a6 = @@custom_annotation.new(1, 8, 'SYN', 'MELANOMA', 'o2_uri', 'o2_acronym', 'o2_uri/melanoma', nil)
  #   a7 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', 'o2_uri', 'o2_acronym', 'o2_uri/cos', nil)
  #   a8 = @@custom_annotation.new(29, 36, 'SYN', 'MELANOMA', 'o2_uri', 'o2_acronym', 'o2_uri/melanoma', nil)
  #   annotations_hash = { }
  #   annotations_hash['o1_uri'] = [a1, a2, a3, a4, a5]
  #   annotations_hash['o2_uri'] = [a6, a7, a8]
  #   result_o1 = specialization_evaluator.evaluate(annotations_hash, 'o1_uri')
  #   result_o2 = specialization_evaluator.evaluate(annotations_hash, 'o2_uri')
  #
  #   # assert_equal(ont_score, result.score, nil)
  #   # assert_equal(ont_score.to_f / top_score.to_f, result.normalizedScore, nil)
  #   # assert_equal(3, result.numberTermsCovered, nil)
  #   # assert_equal(5, result.numberWordsCovered, nil)
  #   # assert_equal(3, result.annotations.size, nil)
  # end

end

