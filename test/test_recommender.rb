require_relative 'test_case'

class TestRecommender < TestCase

  def self.before_suite
    @@recommender = OntologyRecommender::Recommender.new
  end

  def self.after_suite
  end

  # Validation of input parameters
  def test_recommend_validation
    input = 'An article has been published about hormone antagonists'
    input_type = 1
    output_type = 1
    max_elements_set = nil
    ontologies = [ ]
    wc, ws, wa, wd = [0.55, 0.15, 0.15, 0.15]
    assert_raises(ArgumentError) {@@recommender.recommend(nil, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend([ ], input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, 0, output_type, max_elements_set, ontologies, wc, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, 0, max_elements_set, ontologies, wc, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, 2, 0, ontologies, wc, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, 2, nil, ontologies, wc, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, -1, ws, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, -1, wa, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, -1, wd)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, -1)}
    assert_raises(ArgumentError) {@@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, 0, 0, 0, 0)}
  end

  # Input: Text; Output: single ontologies
  def test_recommend_query_text_single
    input = 'An article has been published about hormone antagonists'
    input_type = 1
    output_type = 1
    max_elements_set = nil
    # All loaded ontologies will be used
    ontologies = [ ]
    wc, ws, wa, wd = [0.55, 0.15, 0.15, 0.15]
    recommendations = @@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)
    # Expected ranking:
    # 1st) MCCLTEST-0 -> hormone antagonists
    # 2nd) ONTOMATEST-0 -> article
    assert_equal(2, recommendations.length, msg='Failed to return 2 recommendations')
    rec_1 = recommendations[0]
    rec_2 = recommendations[1]
    assert_equal(rec_1.ontologies[0].acronym, 'MCCLTEST-0')
    assert_equal(rec_1.coverageResult.annotations.size, 1)
    assert_equal(rec_1.coverageResult.annotations.first.text, 'HORMONE ANTAGONISTS')
    assert_equal(rec_1.coverageResult.annotations.first.from, 37)
    assert_equal(rec_1.coverageResult.annotations.first.to, 55)
    assert_equal(rec_1.coverageResult.annotations.first.matchType, 'PREF')
    assert_equal(rec_2.ontologies[0].acronym, 'ONTOMATEST-0')
    assert_equal(rec_2.coverageResult.annotations.size, 1)
    assert_equal(rec_2.coverageResult.annotations.first.text, 'ARTICLE')
    assert_equal(rec_2.coverageResult.annotations.first.from, 4)
    assert_equal(rec_2.coverageResult.annotations.first.to, 10)
    assert_equal(rec_2.coverageResult.annotations.first.matchType, 'PREF')
  end

  # Input: Text; Output: ontology sets
  def test_recommend_query_text_sets
    input = 'An article has been published about hormone antagonists'
    input_type = 1
    output_type = 2
    max_elements_set = 3
    # All loaded ontologies will be used
    ontologies = [ ]
    wc, ws, wa, wd = [0.55, 0.15, 0.15, 0.15]
    recommendations = @@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)
    # Expected ranking:
    # 1st) MCCLTEST-0, ONTOMATEST-0 -> article, hormone antagonists
    assert_equal(1, recommendations.length, msg='Failed to return 1 recommendation')
    rec = recommendations[0]
    acronyms = rec.ontologies.map { |ont| ont.acronym }
    assert_equal(true, (acronyms.include? 'MCCLTEST-0'))
    assert_equal(true, (acronyms.include? 'ONTOMATEST-0'))
    assert_equal(rec.coverageResult.annotations.size, 2)
    assert_equal(rec.coverageResult.annotations[0].text, 'ARTICLE')
    assert_equal(rec.coverageResult.annotations[0].from, 4)
    assert_equal(rec.coverageResult.annotations[0].to, 10)
    assert_equal(rec.coverageResult.annotations[0].matchType, 'PREF')
    assert_equal(rec.coverageResult.annotations[1].text, 'HORMONE ANTAGONISTS')
    assert_equal(rec.coverageResult.annotations[1].from, 37)
    assert_equal(rec.coverageResult.annotations[1].to, 55)
    assert_equal(rec.coverageResult.annotations[1].matchType, 'PREF')
  end

  # Input: Keywords; Output: single ontologies
  def test_recommend_query_keywords_single
    input = 'software development methodology, software, pancreatic hormone, hormone, colorectal carcinoma'
    input_type = 2
    output_type = 1
    max_elements_set = nil
    # All loaded ontologies will be used
    ontologies = [ ]
    wc, ws, wa, wd = [0.55, 0.15, 0.15, 0.15]
    recommendations = @@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)
    # Expected ranking:
    # 1st) MCCLTEST-0 -> hormone, pancreatic hormone
    # 2nd) BROTEST-0 -> software
    assert_equal(2, recommendations.length, msg='Failed to return 2 recommendations')
    rec_1 = recommendations[0]
    rec_2 = recommendations[1]
    assert_equal(rec_1.ontologies[0].acronym, 'MCCLTEST-0')
    assert_equal(rec_1.coverageResult.annotations.size, 2)
    assert_equal(rec_1.coverageResult.annotations[0].text, 'PANCREATIC HORMONE')
    assert_equal(rec_1.coverageResult.annotations[0].from, 45)
    assert_equal(rec_1.coverageResult.annotations[0].to, 62)
    assert_equal(rec_1.coverageResult.annotations[0].matchType, 'PREF')
    assert_equal(rec_1.coverageResult.annotations[1].text, 'HORMONE')
    assert_equal(rec_1.coverageResult.annotations[1].from, 65)
    assert_equal(rec_1.coverageResult.annotations[1].to, 71)
    assert_equal(rec_1.coverageResult.annotations[1].matchType, 'PREF')
    assert_equal(rec_2.ontologies[0].acronym, 'BROTEST-0')
    assert_equal(rec_2.coverageResult.annotations.size, 1)
    assert_equal(rec_2.coverageResult.annotations[0].text, 'SOFTWARE')
    assert_equal(rec_2.coverageResult.annotations[0].from, 35)
    assert_equal(rec_2.coverageResult.annotations[0].to, 42)
    assert_equal(rec_2.coverageResult.annotations[0].matchType, 'PREF')
  end

  # Input: Keywords; Output: ontology sets
  def test_recommend_query_keywords_sets
    input = 'software development methodology, software, pancreatic hormone, hormone, colorectal carcinoma'
    input_type = 2
    output_type = 2
    max_elements_set = 3
    # All loaded ontologies will be used
    ontologies = [ ]
    wc, ws, wa, wd = [0.55, 0.15, 0.15, 0.15]
    recommendations = @@recommender.recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)
    # Expected ranking:
    # 1st) MCCLTEST-0, BROTEST-0 -> software, hormone, pancreatic hormone
    assert_equal(1, recommendations.length, msg='Failed to return 1 recommendation')
    rec = recommendations[0]
    acronyms = rec.ontologies.map { |ont| ont.acronym }
    assert_equal(true, (acronyms.include? 'MCCLTEST-0'))
    assert_equal(true, (acronyms.include? 'BROTEST-0'))
    assert_equal(rec.coverageResult.annotations.size, 3)
    assert_equal(rec.coverageResult.annotations[0].text, 'SOFTWARE')
    assert_equal(rec.coverageResult.annotations[0].from, 35)
    assert_equal(rec.coverageResult.annotations[0].to, 42)
    assert_equal(rec.coverageResult.annotations[0].matchType, 'PREF')
    assert_equal(rec.coverageResult.annotations[1].text, 'PANCREATIC HORMONE')
    assert_equal(rec.coverageResult.annotations[1].from, 45)
    assert_equal(rec.coverageResult.annotations[1].to, 62)
    assert_equal(rec.coverageResult.annotations[1].matchType, 'PREF')
    assert_equal(rec.coverageResult.annotations[2].text, 'HORMONE')
    assert_equal(rec.coverageResult.annotations[2].from, 65)
    assert_equal(rec.coverageResult.annotations[2].to, 71)
    assert_equal(rec.coverageResult.annotations[2].matchType, 'PREF')
  end

end