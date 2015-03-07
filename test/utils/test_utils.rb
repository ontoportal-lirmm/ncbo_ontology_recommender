require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/utils/annotator_utils/custom_annotation'
class TestUtils < TestCase

  def self.before_suite
    @@custom_annotation = OntologyRecommender::Utils::AnnotatorUtils::CustomAnnotation
    @@utils = OntologyRecommender::Utils
  end

  def self.after_suite
  end

  def test_select_ontologies_for_ranking_sets
    pref_score = 10
    syn_score = 5
    multiterm_score = 4
    cls1 = LinkedData::Models::Class.new
    cls1.submission = LinkedData::Models::OntologySubmission.new
    cls1.submission.ontology = LinkedData::Models::Ontology.new
    cls1.submission.ontology.acronym = 'ONT1'
    cls2 = LinkedData::Models::Class.new
    cls2.submission = LinkedData::Models::OntologySubmission.new
    cls2.submission.ontology = LinkedData::Models::Ontology.new
    cls2.submission.ontology.acronym = 'ONT2'
    cls3 = LinkedData::Models::Class.new
    cls3.submission = LinkedData::Models::OntologySubmission.new
    cls3.submission.ontology = LinkedData::Models::Ontology.new
    cls3.submission.ontology.acronym = 'ONT3'
    cls4 = LinkedData::Models::Class.new
    cls4.submission = LinkedData::Models::OntologySubmission.new
    cls4.submission.ontology = LinkedData::Models::Ontology.new
    cls4.submission.ontology.acronym = 'ONT4'
    a1 = @@custom_annotation.new(17, 26, 'PREF', 'BLOOD CELL', cls1)
    a2 = @@custom_annotation.new(11, 26, 'PREF', 'WHITE BLOOD CELL', cls2)
    a3 = @@custom_annotation.new(17, 21, 'PREF', 'BLOOD', cls3)
    a4 = @@custom_annotation.new(17, 21, 'SYN', 'BLOOD', cls2)
    a5 = @@custom_annotation.new(17, 21, 'SYN', 'BLOOD', cls4)
    coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(pref_score, syn_score, multiterm_score)
    selected_acronyms = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([], coverage_evaluator)
    assert_equal([], selected_acronyms)
    selected_acronyms = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a1], coverage_evaluator)
    assert_equal([cls1.submission.ontology.acronym], selected_acronyms)
    selected_acronyms = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a1, a2, a3], coverage_evaluator)
    assert_equal([cls2.submission.ontology.acronym], selected_acronyms)
    selected_acronyms = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a3, a4, a5], coverage_evaluator)
    assert_equal([cls3.submission.ontology.acronym], selected_acronyms)
    selected_acronyms = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a4, a5], coverage_evaluator)
    assert_equal([cls2.submission.ontology.acronym, cls4.submission.ontology.acronym], selected_acronyms)
  end

  def test_annotations_contained_in
    pref_score = 10
    syn_score = 5
    multiterm_score = 4
    coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(pref_score, syn_score, multiterm_score)
    a1 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil)
    a2 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil)
    a3 = @@custom_annotation.new(1, 5, 'SYN', 'BLOOD', nil)
    a4 = @@custom_annotation.new(1, 10, 'PREF', 'BLOOD CELL', nil)
    a5 = @@custom_annotation.new(10, 13, 'PREF', 'HEAD', nil)
    a6 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil)
    a7 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil)
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1], [a2], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a2], [a1], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a3], [a1], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a2], [a4], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1], [a2, a3], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1], [a2, a5], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1, a6], [a4, a5, a7], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a2, a3], [a1], coverage_evaluator))
    assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a3, a7], [a6, a2], coverage_evaluator))
    assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a1], [a3], coverage_evaluator))
    assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a4], [a2], coverage_evaluator))
    assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a2, a5], [a1], coverage_evaluator))
    assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a4, a5, a7], [a1, a6], coverage_evaluator))
    assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a6, a2], [a3, a7], coverage_evaluator))
  end

  def test_get_combinations
    elements = [1, 2, 3, 4]
    exp_0 = [ ]
    exp_1 = [[1], [2], [3], [4]]
    exp_2 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    exp_3 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
           [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]]
    exp_4 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
             [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4], [1, 2, 3, 4]]
    assert_equal(exp_0, @@utils.get_combinations([], 3))
    combinations = @@utils.get_combinations(elements, 1)
    assert_equal(exp_1, combinations)
    combinations = @@utils.get_combinations(elements, 2)
    assert_equal(exp_2, combinations)
    combinations = @@utils.get_combinations(elements, 3)
    assert_equal(exp_3, combinations)
    combinations = @@utils.get_combinations(elements, 4)
    assert_equal(exp_4, combinations)
    combinations = @@utils.get_combinations(elements, 10)
    assert_equal(exp_4, combinations)
  end

  def test_normalize
    assert_equal(0, @@utils.normalize(0, 0, 1, 0, 1))
    assert_equal(1, @@utils.normalize(1, 0, 1, 0, 1))
    assert_equal(0, @@utils.normalize(10, 10, 15, 0, 1))
    assert_equal(1, @@utils.normalize(15, 10, 15, 0, 1))
    assert_equal(0.5, @@utils.normalize(5, 0, 10, 0, 1))
    assert_equal(21.to_f/179.to_f, @@utils.normalize(27, 6, 185, 0, 1))
  end

  def test_normalize_weights
    assert_raises(ArgumentError) {@@utils.normalize_weights([0, 0, 0, 0])}
    assert_raises(RangeError) {@@utils.normalize_weights([0, -2, 0, 0])}
    assert_equal([0.2, 0.2, 0.5, 0.1], @@utils.normalize_weights([0.2, 0.2, 0.5, 0.1]))
    assert_equal([0.2, 0.2, 0.5, 0.1], @@utils.normalize_weights([0.2, 0.2, 0.5, 0.1]))
    assert_equal([0, 0.5, 0.4, 0.1], @@utils.normalize_weights([0, 50, 40, 10]))
    assert_equal([0.1, 0.4, 0.4, 0.1], @@utils.normalize_weights([10, 40, 40, 10]))
  end

  def test_get_ont_acronym_from_uri
    uri = 'http://data.bioontology.org/ontologies/SNOMEDCT'
    acronym = @@utils.get_ont_acronym_from_uri(uri)
    assert_equal('SNOMEDCT', acronym)
  end

  def test_get_number_of_classes
    assert_equal(810, @@utils.get_number_of_classes('MCCLTEST-0'))
    assert_equal(486, @@utils.get_number_of_classes('BROTEST-0'))
    assert_equal(435, @@utils.get_number_of_classes('ONTOMATEST-0'))
  end

end


