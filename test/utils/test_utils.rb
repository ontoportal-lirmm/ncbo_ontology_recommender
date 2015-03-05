require_relative '../test_case'
require_relative '../../lib/ncbo_ontology_recommender/utils/annotator_utils/custom_annotation'
class TestUtils < TestCase

  def self.before_suite
    @@custom_annotation = OntologyRecommender::Utils::AnnotatorUtils::CustomAnnotation
  end

  def self.after_suite
  end

  # def test_select_ontologies_for_ranking_sets
  #   pref_score = 10
  #   syn_score = 5
  #   multiterm_score = 4
  #   coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(pref_score, syn_score, multiterm_score)
  #   a1 = @@custom_annotation.new(17, 26, 'PREF', 'BLOOD CELL', 'o1_uri', 'o1_acronym', 'o1_uri/bc', nil)
  #   a2 = @@custom_annotation.new(11, 26, 'PREF', 'WHITE BLOOD CELL', 'o2_uri', 'o2_acronym', 'o2_uri/wbc', nil)
  #   a3 = @@custom_annotation.new(17, 21, 'PREF', 'BLOOD', 'o3_uri', 'o3_acronym', 'o3_uri/blood', nil)
  #   a4 = @@custom_annotation.new(17, 21, 'SYN', 'BLOOD', 'o2_uri', 'o2_acronym', 'o2_uri/blood', nil)
  #   a5 = @@custom_annotation.new(17, 21, 'SYN', 'BLOOD', 'o5_uri', 'o5_acronym', 'o5_uri/blood', nil)
  #   selected_uris = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([], coverage_evaluator)
  #   assert_equal([], selected_uris)
  #   selected_uris = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a1], coverage_evaluator)
  #   assert_equal(['o1_uri'], selected_uris)
  #   selected_uris = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a1, a2, a3], coverage_evaluator)
  #   assert_equal(['o2_uri'], selected_uris)
  #   selected_uris = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a3, a4, a5], coverage_evaluator)
  #   assert_equal(['o3_uri'], selected_uris)
  #   selected_uris = OntologyRecommender::Utils.select_ontologies_for_ranking_sets([a4, a5], coverage_evaluator)
  #   assert_equal(['o2_uri', 'o5_uri'], selected_uris)
  # end

  # def test_annotations_contained_in
  #   pref_score = 10
  #   syn_score = 5
  #   multiterm_score = 4
  #   coverage_evaluator = OntologyRecommender::Evaluators::CoverageEvaluator.new(pref_score, syn_score, multiterm_score)
  #   a1 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil, '', nil, nil)
  #   a2 = @@custom_annotation.new(1, 5, 'PREF', 'BLOOD', nil, '', nil, nil)
  #   a3 = @@custom_annotation.new(1, 5, 'SYN', 'BLOOD', nil, '', nil, nil)
  #   a4 = @@custom_annotation.new(1, 10, 'PREF', 'BLOOD CELL', '', nil, nil, nil)
  #   a5 = @@custom_annotation.new(10, 13, 'PREF', 'HEAD', nil, '', nil, nil)
  #   a6 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil, '', nil, nil)
  #   a7 = @@custom_annotation.new(20, 22, 'PREF', 'ARM', nil, '', nil, nil)
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1], [a2], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a2], [a1], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a3], [a1], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a2], [a4], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1], [a2, a3], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1], [a2, a5], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a1, a6], [a4, a5, a7], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a2, a3], [a1], coverage_evaluator))
  #   assert_equal(true, OntologyRecommender::Utils.annotations_contained_in([a3, a7], [a6, a2], coverage_evaluator))
  #   assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a1], [a3], coverage_evaluator))
  #   assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a4], [a2], coverage_evaluator))
  #   assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a2, a5], [a1], coverage_evaluator))
  #   assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a4, a5, a7], [a1, a6], coverage_evaluator))
  #   assert_equal(false, OntologyRecommender::Utils.annotations_contained_in([a6, a2], [a3, a7], coverage_evaluator))
  # end

  def test_get_combinations
    elements = [1, 2, 3, 4]
    exp_0 = [ ]
    exp_1 = [[1], [2], [3], [4]]
    exp_2 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    exp_3 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
           [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]]
    exp_4 = [[1], [2], [3], [4], [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
             [1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4], [1, 2, 3, 4]]
    assert_equal(exp_0, OntologyRecommender::Utils.get_combinations([], 3))
    combinations = OntologyRecommender::Utils.get_combinations(elements, 1)
    assert_equal(exp_1, combinations)
    combinations = OntologyRecommender::Utils.get_combinations(elements, 2)
    assert_equal(exp_2, combinations)
    combinations = OntologyRecommender::Utils.get_combinations(elements, 3)
    assert_equal(exp_3, combinations)
    combinations = OntologyRecommender::Utils.get_combinations(elements, 4)
    assert_equal(exp_4, combinations)
    combinations = OntologyRecommender::Utils.get_combinations(elements, 10)
    assert_equal(exp_4, combinations)
  end

  def test_normalize
    assert_equal(0, OntologyRecommender::Utils.normalize(0, 0, 1, 0, 1))
    assert_equal(1, OntologyRecommender::Utils.normalize(1, 0, 1, 0, 1))
    assert_equal(0, OntologyRecommender::Utils.normalize(10, 10, 15, 0, 1))
    assert_equal(1, OntologyRecommender::Utils.normalize(15, 10, 15, 0, 1))
    assert_equal(0.5, OntologyRecommender::Utils.normalize(5, 0, 10, 0, 1))
    assert_equal(21.to_f/179.to_f, OntologyRecommender::Utils.normalize(27, 6, 185, 0, 1))
  end

  def test_normalize_weights
    assert_raises(ArgumentError) {OntologyRecommender::Utils.normalize_weights([0, 0, 0, 0])}
    assert_raises(RangeError) {OntologyRecommender::Utils.normalize_weights([0, -2, 0, 0])}
    assert_equal([0.2, 0.2, 0.5, 0.1], OntologyRecommender::Utils.normalize_weights([0.2, 0.2, 0.5, 0.1]))
    assert_equal([0.2, 0.2, 0.5, 0.1], OntologyRecommender::Utils.normalize_weights([0.2, 0.2, 0.5, 0.1]))
    assert_equal([0, 0.5, 0.4, 0.1], OntologyRecommender::Utils.normalize_weights([0, 50, 40, 10]))
    assert_equal([0.1, 0.4, 0.4, 0.1], OntologyRecommender::Utils.normalize_weights([10, 40, 40, 10]))
  end

  def test_get_ont_acronym_from_uri
    uri = 'http://data.bioontology.org/ontologies/SNOMEDCT'
    acronym = OntologyRecommender::Utils.get_ont_acronym_from_uri(uri)
    assert_equal('SNOMEDCT', acronym)
  end

end


