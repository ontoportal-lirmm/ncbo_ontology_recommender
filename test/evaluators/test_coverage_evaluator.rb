require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/coverage_evaluator'

class TestCoverageEvaluator < TestCase

  def self.before_suite
    @@pref_score = 10
    @@syn_score = 5
    @@multiterm_score = 4
    @@coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(@@pref_score, @@syn_score, @@multiterm_score)
    @@custom_annotation = OntologyRecommender::Utils::AnnotatorUtils::CustomAnnotation
  end

  def self.after_suite
  end

  # def test_evaluate
  #   input = 'melanoma, white blood cell, melanoma,     arm, cavity of stomach'
  #   a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   a2 = @@custom_annotation.new(11, 26, 'PREF', 'WHITE BLOOD CELL', 'o1_uri', 'o1_acronym', 'o1_uri/wbc', nil)
  #   a3 = @@custom_annotation.new(29, 36, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   a4 = @@custom_annotation.new(43, 45, 'SYN', 'ARM', 'o1_uri', 'o1_acronym', 'o1_uri/arm', nil)
  #   a5 = @@custom_annotation.new(58, 64, 'PREF', 'STOMACH', 'o1_uri', 'o1_acronym', 'o1_uri/stomach', nil)
  #   a6 = @@custom_annotation.new(1, 8, 'SYN', 'MELANOMA', 'o2_uri', 'o2_acronym', 'o2_uri/melanoma', nil)
  #   a7 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', 'o2_uri', 'o2_acronym', 'o2_uri/cos', nil)
  #   a8 = @@custom_annotation.new(29, 36, 'SYN', 'MELANOMA', 'o2_uri', 'o2_acronym', 'o2_uri/melanoma', nil)
  #   annotations_all = [a1, a2, a3, a4, a5, a6, a7, a8]
  #   annotations_ontology = [a6, a7, a8]
  #   result = @@coverage_evaluator.evaluate(input, annotations_all, annotations_ontology)
  #   top_score = @@coverage_evaluator.get_annotation_score(a1) + @@coverage_evaluator.get_annotation_score(a2) +
  #       @@coverage_evaluator.get_annotation_score(a3) + @@coverage_evaluator.get_annotation_score(a4) +
  #       @@coverage_evaluator.get_annotation_score(a7)
  #   ont_score = @@coverage_evaluator.get_annotation_score(a6) + @@coverage_evaluator.get_annotation_score(a7) +
  #       @@coverage_evaluator.get_annotation_score(a8)
  #   assert_equal(ont_score, result.score)
  #   assert_equal(ont_score.to_f / top_score.to_f, result.normalizedScore)
  #   assert_equal(3, result.numberTermsCovered)
  #   assert_equal(5, result.numberWordsCovered)
  #   assert_equal(3, result.annotations.size)
  # end

  # def test_evaluate_empty_input
  #   input = ''
  #   a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   a2 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', 'o2_uri', 'o2_acronym', 'o2_uri/cos', nil)
  #   annotations_all = [a1, a2]
  #   annotations_ontology = [a1]
  #   result = @@coverage_evaluator.evaluate(input, annotations_all, annotations_ontology)
  #   assert result != nil
  #   assert_equal(0, result.score)
  #   assert_equal(0, result.normalizedScore)
  #   assert_equal(0, result.numberTermsCovered)
  #   assert_equal(0, result.numberWordsCovered)
  #   assert_equal(0, result.annotations.size)
  # end

  def test_evaluate_empty_annotations_all
    input = 'melanoma'
    annotations_all = [ ]
    annotations_ontology = [ ]
    result = @@coverage_evaluator.evaluate(input, annotations_all, annotations_ontology)
    assert result != nil
    assert_equal(0, result.score)
    assert_equal(0, result.normalizedScore)
    assert_equal(0, result.numberTermsCovered)
    assert_equal(0, result.numberWordsCovered)
    assert_equal(0, result.annotations.size)
  end

  # def test_evaluate_empty_annotations_ontology
  #   input = 'melanoma'
  #   a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   annotations_all = [a1]
  #   annotations_ontology = [ ]
  #   result = @@coverage_evaluator.evaluate(input, annotations_all, annotations_ontology)
  #   assert result != nil
  #   assert_equal(0, result.score)
  #   assert_equal(0, result.normalizedScore)
  #   assert_equal(0, result.numberTermsCovered)
  #   assert_equal(0, result.numberWordsCovered)
  #   assert_equal(0, result.annotations.size)
  # end

  # def test_get_annotation_score
  #   a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', 'o1_uri', 'o1_acronym', 'o1_uri/melanoma', nil)
  #   a2 = @@custom_annotation.new(43, 45, 'SYN', 'ARM', 'o1_uri', 'o1_acronym', 'o1_uri/arm', nil)
  #   a3 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', 'o2_uri', 'o2_acronym', 'o2_uri/cos', nil)
  #   a4 = @@custom_annotation.new(48, 64, 'SYN', 'CAVITY OF STOMACH', 'o2_uri', 'o2_acronym', 'o2_uri/cos', nil)
  #   assert_equal(@@pref_score, @@coverage_evaluator.get_annotation_score(a1))
  #   assert_equal(@@syn_score, @@coverage_evaluator.get_annotation_score(a2))
  #   assert_equal((@@multiterm_score + @@pref_score)*3, @@coverage_evaluator.get_annotation_score(a3))
  #   assert_equal((@@multiterm_score + @@syn_score)*3, @@coverage_evaluator.get_annotation_score(a4))
  # end



end

