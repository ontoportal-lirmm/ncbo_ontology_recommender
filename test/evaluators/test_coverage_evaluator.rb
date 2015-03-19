require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/evaluators/coverage_evaluator'

class TestCoverageEvaluator < TestCase

  def self.before_suite
    @@pref_score = OntologyRecommender.settings.pref_score
    @@syn_score = OntologyRecommender.settings.syn_score
    @@multiterm_score = OntologyRecommender.settings.multiterm_score
    @@coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(@@pref_score, @@syn_score, @@multiterm_score)
    @@custom_annotation = OntologyRecommender::Helpers::AnnotatorHelper::CustomAnnotation
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
    assert_in_delta(ont_score.to_f / top_score.to_f, result.normalizedScore)
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
    assert_equal(@@pref_score, @@coverage_evaluator.get_annotation_score(a1))
    assert_equal(@@syn_score, @@coverage_evaluator.get_annotation_score(a2))
    assert_equal((@@multiterm_score + @@pref_score)*3, @@coverage_evaluator.get_annotation_score(a3))
    assert_equal((@@multiterm_score + @@syn_score)*3, @@coverage_evaluator.get_annotation_score(a4))
  end

  def test_select_best_annotations_for_input
    input = 'primary treatment'
    a1 = @@custom_annotation.new(1, 5, 'PREF', 'PRIMARY', nil, 0)
    a2 = @@custom_annotation.new(9, 17, 'PREF', 'TREATMENT', nil, 0)
    a3 = @@custom_annotation.new(1, 17, 'PREF', 'PRIMARY TREATMENT', nil, 0)
    a4 = @@custom_annotation.new(1, 5, 'SYN', 'PRIMARY', nil, 0)
    a5 = @@custom_annotation.new(9, 17, 'SYN', 'TREATMENT', nil, 0)
    a6 = @@custom_annotation.new(1, 17, 'SYN', 'PRIMARY TREATMENT', nil, 0)
    assert_equal([a1, a2], @@coverage_evaluator.send(:select_best_annotations_for_input, input, [a1, a2]))
    assert_equal([a3], @@coverage_evaluator.send(:select_best_annotations_for_input, input, [a1, a2, a3, a4, a5, a6]))
    assert_equal([a3], @@coverage_evaluator.send(:select_best_annotations_for_input, input, [a1, a2, a3]))
    assert_equal([a1, a2], @@coverage_evaluator.send(:select_best_annotations_for_input, input, [a1, a2, a4, a5]))
    # We prefer one SYN annotation that covers two words than two PREF annotations
    assert_equal([a6], @@coverage_evaluator.send(:select_best_annotations_for_input, input, [a1, a2, a6]))
  end

  def test_get_top_coverage_score
    input = 'primary treatment'
    a1 = @@custom_annotation.new(1, 5, 'PREF', 'PRIMARY', @@cls_ont1, 0)
    a2 = @@custom_annotation.new(9, 17, 'PREF', 'TREATMENT', @@cls_ont1, 0)
    a3 = @@custom_annotation.new(1, 17, 'SYN', 'PRIMARY TREATMENT', @@cls_ont2, 0)
    annotations_all = [a1, a2, a3]
    annotations_all_hash = annotations_all.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
    result_1 = @@coverage_evaluator.evaluate(input, annotations_all_hash, annotations_all_hash['ONT1'])
    result_2 = @@coverage_evaluator.evaluate(input, annotations_all_hash, annotations_all_hash['ONT2'])
    # We prefer one SYN annotation that covers two words than two PREF annotations
    top_score = @@coverage_evaluator.send(:get_top_coverage_score, input, [a1, a2, a3])
    assert(result_1.score <= top_score, "#{result_1.score} is not <= than #{top_score}")
    assert(result_2.score <= top_score, "#{result_2.score} is not <= than #{top_score}")
  end

end