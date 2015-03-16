require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/coverage_evaluator'

class TestCoverageEvaluator < TestCase

  def self.before_suite
    @@pref_score = 10
    @@syn_score = 5
    @@multiterm_score = 4
    @@coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(@@pref_score, @@syn_score, @@multiterm_score)
    @@custom_annotation = OntologyRecommender::Utils::AnnotatorUtils::CustomAnnotation
    @@cls_ont1 = LinkedData::Models::Class.new
    @@cls_ont1.submission = LinkedData::Models::OntologySubmission.new
    @@cls_ont1.submission.ontology = LinkedData::Models::Ontology.new
    @@cls_ont1.submission.ontology.acronym = 'ONT1'
    @@cls_ont2 = LinkedData::Models::Class.new
    @@cls_ont2.submission = LinkedData::Models::OntologySubmission.new
    @@cls_ont2.submission.ontology = LinkedData::Models::Ontology.new
    @@cls_ont2.submission.ontology.acronym = 'ONT2'
  end

  def self.after_suite
  end

  def test_evaluate
    input = 'melanoma, white blood cell, melanoma,     arm, cavity of stomach'
    a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', @@cls_ont1, 0)
    a2 = @@custom_annotation.new(11, 26, 'PREF', 'WHITE BLOOD CELL', @@cls_ont1, 0)
    a3 = @@custom_annotation.new(29, 36, 'PREF', 'MELANOMA', @@cls_ont1, 0)
    a4 = @@custom_annotation.new(43, 45, 'SYN', 'ARM', @@cls_ont1, 0)
    a5 = @@custom_annotation.new(58, 64, 'PREF', 'STOMACH', @@cls_ont1, 0)
    a6 = @@custom_annotation.new(1, 8, 'SYN', 'MELANOMA', @@cls_ont2, 0)
    a7 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', @@cls_ont2, 0)
    a8 = @@custom_annotation.new(29, 36, 'SYN', 'MELANOMA', @@cls_ont2, 0)
    annotations_all = [a1, a2, a3, a4, a5, a6, a7, a8]
    annotations_all_hash = annotations_all.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
    result = @@coverage_evaluator.evaluate(input, annotations_all_hash, annotations_all_hash['ONT2'])
    top_score = @@coverage_evaluator.get_annotation_score(a1) + @@coverage_evaluator.get_annotation_score(a2) +
        @@coverage_evaluator.get_annotation_score(a3) + @@coverage_evaluator.get_annotation_score(a4) +
        @@coverage_evaluator.get_annotation_score(a7)
    ont_score = @@coverage_evaluator.get_annotation_score(a6) + @@coverage_evaluator.get_annotation_score(a7) +
        @@coverage_evaluator.get_annotation_score(a8)
    assert_equal(ont_score, result.score)
    assert_equal(ont_score.to_f / top_score.to_f, result.normalizedScore)
    assert_equal(3, result.numberTermsCovered)
    assert_equal(5, result.numberWordsCovered)
    assert_equal(3, result.annotations.size)
  end

  def test_evaluate_empty_input
    input = ''
    a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', @@cls_ont1, 0)
    a2 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', @@cls_ont2, 0)
    annotations_all = [a1, a2]
    annotations_all_hash = annotations_all.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
    result = @@coverage_evaluator.evaluate(input, annotations_all_hash, annotations_all_hash['ONT2'])
    assert result != nil
    assert_equal(0, result.score)
    assert_equal(0, result.normalizedScore)
    assert_equal(0, result.numberTermsCovered)
    assert_equal(0, result.numberWordsCovered)
    assert_equal(0, result.annotations.size)
  end

  def test_evaluate_empty_annotations_all
    input = 'melanoma'
    annotations_all_hash = Hash.new
    result = @@coverage_evaluator.evaluate(input, annotations_all_hash, [])
    assert result != nil
    assert_equal(0, result.score)
    assert_equal(0, result.normalizedScore)
    assert_equal(0, result.numberTermsCovered)
    assert_equal(0, result.numberWordsCovered)
    assert_equal(0, result.annotations.size)
  end

  def test_evaluate_empty_annotations_ontology
    input = 'melanoma'
    a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', @@cls_ont1, 0)
    annotations_all = [a1]
    annotations_all_hash = annotations_all.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
    result = @@coverage_evaluator.evaluate(input, annotations_all_hash, [])
    assert result != nil
    assert_equal(0, result.score)
    assert_equal(0, result.normalizedScore)
    assert_equal(0, result.numberTermsCovered)
    assert_equal(0, result.numberWordsCovered)
    assert_equal(0, result.annotations.size)
  end

  def test_get_annotation_score
    a1 = @@custom_annotation.new(1, 8, 'PREF', 'MELANOMA', nil, 0)
    a2 = @@custom_annotation.new(43, 45, 'SYN', 'ARM', nil, 0)
    a3 = @@custom_annotation.new(48, 64, 'PREF', 'CAVITY OF STOMACH', nil, 0)
    a4 = @@custom_annotation.new(48, 64, 'SYN', 'CAVITY OF STOMACH', nil, 0)
    # The send method bypasses encapsulation, allowing to call private methods
    assert_equal(@@pref_score, @@coverage_evaluator.send(:get_annotation_score, a1))
    assert_equal(@@syn_score, @@coverage_evaluator.send(:get_annotation_score, a2))
    assert_equal((@@multiterm_score + @@pref_score)*3, @@coverage_evaluator.get_annotation_score(a3))
    assert_equal((@@multiterm_score + @@syn_score)*3, @@coverage_evaluator.get_annotation_score(a4))
  end

end