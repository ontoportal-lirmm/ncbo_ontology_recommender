require 'logger'
require_relative 'ncbo_ontology_recommender/config'
require_relative 'ncbo_ontology_recommender/helpers/annotator_helpers/annotator_helper'
require_relative 'ncbo_ontology_recommender/evaluators/coverage_evaluator'
require_relative 'ncbo_ontology_recommender/evaluators/specialization_evaluator'
require_relative 'ncbo_ontology_recommender/evaluators/acceptance_evaluator'
require_relative 'ncbo_ontology_recommender/evaluators/detail_evaluator'
require_relative 'ncbo_ontology_recommender/scores/score_aggregator'
require_relative 'ncbo_ontology_recommender/scores/score'
require_relative 'recommendation'
require_relative 'ncbo_ontology_recommender/helpers/general_helper'

module OntologyRecommender

  class Recommender

    def initialize()
      @logger = Kernel.const_defined?('LOGGER') ? Kernel.const_get('LOGGER') : Logger.new(STDOUT)
      @coverage_evaluator = nil
      @specialization_evaluator = nil
      @annotations_all_hash = nil
      @settings = OntologyRecommender.settings
    end

    # input_type: 1 (text), 2 (keywords)
    # output_type: 1 (single ontologies), 2 (ontology sets)
    def recommend(input, input_type, output_type, max_elements_set, ontologies, wc, ws, wa, wd)
      # Parameters validation
      if input.nil? || input.empty? then raise ArgumentError, 'Invalid input' end
      if input_type == nil || (input_type != 1 && input_type !=2) then raise ArgumentError, 'Invalid value for input_type' end
      if output_type == nil || (output_type != 1 && output_type !=2) then raise ArgumentError, 'Invalid value for output_type' end
      if output_type == 2 && (max_elements_set.nil? || max_elements_set < 2) then raise ArgumentError, 'Invalid value for max_elements_set' end
      if wc.nil? || wc < 0 then raise ArgumentError, 'Invalid value for wc' end
      if ws.nil? || ws < 0 then raise ArgumentError, 'Invalid value for ws' end
      if wa.nil? || wa < 0 then raise ArgumentError, 'Invalid value for wa' end
      if wd.nil? || wd < 0 then raise ArgumentError, 'Invalid value for wd' end
      if wc + ws + wa + wd == 0 then raise ArgumentError, 'The sum of all weights must be greater than zero' end
      @logger.info('Starting ontology recommendation')
      @logger.info('Input: ' + input)
      @logger.info('Input type: ' + input_type.to_s + '; Output type: ' + output_type.to_s + '; Max ontologies/set: ' + max_elements_set.to_s)
      @logger.info('Number of ontologies: ' + ontologies.size.to_s)
      @logger.info('Weights: wc: ' + wc.to_s + '; ws: ' + ws.to_s + '; wa: ' + wa.to_s + '; wd: ' + wd.to_s)
      start_time = Time.now
      # Weights normalization (if necessary)
      if (wc + ws + wa + wd != 1)
        wc, ws, wa, wd  = Helpers.normalize_weights([wc, ws, wa, wd])
        @logger.info('Normalized weights: wc: ' + wc.round(3).to_s + '; ws: ' + ws.round(3).to_s + '; wa: ' + wa.round(3).to_s + '; wd: ' + wd.round(3).to_s)
      end
      # Keywords delimiter char
      delimiter = @settings.delimiter
      # Coverage evaluation
      pref_score = @settings.pref_score
      syn_score = @settings.syn_score
      multiterm_score = @settings.multiterm_score
      # Acceptance evaluation
      w_bp = @settings.w_bp
      w_umls = @settings.w_umls
      # Detail evaluation
      top_defs = @settings.top_defs
      top_syns = @settings.top_syns
      top_props = @settings.top_props
      # Other parameters
      max_results_single = @settings.max_results_single
      max_results_sets = @settings.max_results_sets
      # Evaluators initialization
      @coverage_evaluator = Evaluators::CoverageEvaluator.new(pref_score, syn_score, multiterm_score)
      @specialization_evaluator = Evaluators::SpecializationEvaluator.new(pref_score, syn_score, multiterm_score)
      @acceptance_evaluator = Evaluators::AcceptanceEvaluator.new(w_bp, w_umls)
      @detail_evaluator = Evaluators::DetailEvaluator.new(top_defs, top_syns, top_props)

      time_single = Time.now
      ranking = get_ranking_single(input, input_type, delimiter, ontologies, wc, ws, wa, wd, max_results_single)
      @logger.info('TIME - Obtain single ranking: ' + (Time.now-time_single).to_s + ' sec.')

      if output_type == 2
        time_sets = Time.now
        ranking = get_ranking_sets(ranking, input, wc, ws, max_elements_set, max_results_sets)
        @logger.info('TIME - Obtain sets ranking: ' + (Time.now-time_sets).to_s + ' sec.')
      end

      @logger.info('Recommendation finished. Ranking size: ' + ranking.size.to_s +
                       '; Execution time: ' + (Time.now-start_time).to_s + ' sec.')
      return ranking
    end

    # Single ontology ranking. Each position contains an ontology
    private
    def get_ranking_single(input, input_type, delimiter, ontologies, wc, ws, wa, wd, max_results_single)
      @logger.info('Computing single ranking')
      # Obtain all annotations for the input (annotations done with all BioPortal ontologies)
      time_annotations = Time.now
      annotations_all = Helpers::AnnotatorHelper.get_annotations(input, input_type, delimiter, [])
      @logger.info('TIME - Obtain annotations: ' + (Time.now-time_annotations).to_s + ' sec.')
      # Store the annotations in a hash [ontology_acronym, annotation].
      @annotations_all_hash = annotations_all.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
      # Annotations for the picked ontologies
      annotations_hash = @annotations_all_hash.dup
      if (!ontologies.empty?)
        annotations_hash.delete_if {|acr, _| (!ontologies.include? acr)}
      end
      @logger.info('Ontologies that provide annotations: ' + annotations_hash.keys.size.to_s)
      ranking = []
      time_coverage = 0
      time_specialization = 0
      time_acceptance = 0
      time_detail = 0
      time_retrieve_onts = 0
      annotations_hash.keys.each do |ont_acronym|
        # Coverage evaluation
        time_coverage_ont = Time.now
        coverage_result = @coverage_evaluator.evaluate(input, @annotations_all_hash, @annotations_all_hash[ont_acronym])
        time_coverage += Time.now - time_coverage_ont
        best_annotations_ont = @coverage_evaluator.best_annotations
        # Specialization evaluation
        time_specialization_ont = Time.now
        specialization_result = @specialization_evaluator.evaluate(@annotations_all_hash, ont_acronym)
        time_specialization += Time.now - time_specialization_ont
        # Acceptance evaluation
        time_acceptance_ont = Time.now
        acceptance_result = @acceptance_evaluator.evaluate(annotations_hash.keys, ont_acronym)
        time_acceptance += Time.now - time_acceptance_ont
        # Detail of knowledge evaluation
        time_detail_ont = Time.now
        detail_result = @detail_evaluator.evaluate(@annotations_all_hash, best_annotations_ont)
        time_detail += Time.now - time_detail_ont

        coverage_score = Scores::Score.new(coverage_result.normalizedScore, wc)
        specialization_score = Scores::Score.new(specialization_result.normalizedScore, ws)
        acceptance_score = Scores::Score.new(acceptance_result.normalizedScore, wa)
        detail_score = Scores::Score.new(detail_result.normalizedScore, wd)

        @logger.info("Coverage score: #{coverage_score.score}")
        @logger.info("Specialization score: #{specialization_score.score}")
        @logger.info("Acceptance score: #{acceptance_score.score}")
        @logger.info("Detail score: #{detail_score.score}")

        aggregated_score = Scores::ScoreAggregator.
            get_aggregated_scores([coverage_score, specialization_score, acceptance_score, detail_score]).round(3)
        ont = annotations_hash[ont_acronym].first.annotatedClass.submission.ontology
        ranking << Recommendation.new(aggregated_score, [ont], coverage_result, specialization_result, acceptance_result, detail_result)
      end
      @logger.info('TIME - Coverage evaluation: ' + time_coverage.round(3).to_s + ' sec.')
      @logger.info('TIME - Specialization evaluation: ' + time_specialization.round(3).to_s + ' sec.')
      @logger.info('TIME - Acceptance evaluation: ' + time_acceptance.round(3).to_s + ' sec.')
      @logger.info('TIME - Detail evaluation: ' + time_detail.round(3).to_s + ' sec.')
      @logger.info('TIME - Retrieve ontologies: ' + time_retrieve_onts.round(3).to_s + ' sec.')

      ranking = ranking.sort_by {|element| element.evaluationScore.to_f}.reverse

      return ranking[0..max_results_single-1]
    end

    # Ontology sets ranking. Each position may contain one or several ontologies
    private
    def get_ranking_sets(ranking_single, input, wc, ws, max_elements_set, max_results_sets)
      @logger.info('Computing ranking sets')
      # Stores the results in a hash |ontology_acronym,result| to access them easily
      single_results_hash = {}
      ranking_single.each do |r|
        single_results_hash[r.ontologies[0].acronym] = r
      end
      # Performance improvement: only a subset of the ontologies are selected as candidates
      # for the evaluation of ontology sets (generation of ontology combinations)
      annotations = [ ]
      single_results_hash.each do |_, r|
        annotations.concat r.coverageResult.annotations
      end
      selected_onts = Helpers.select_ontologies_for_ranking_sets(annotations, @coverage_evaluator)
      @logger.info('Selected ontologies (performance improvement 1): ' + selected_onts.size.to_s)

      # Calculates all the combinations of ontology acronyms
      onts_combinations = Helpers.get_combinations(selected_onts, max_elements_set)
      @logger.info('All combinations: ' + onts_combinations.size.to_s)
      # Performance improvement: if the maximum coverage score possible for an ontology set is lower or equal than the
      # coverage provided by the first ontology in the single ranking, the combination is directly discarded because
      # the combination will not improve the results of the single ranking
      c2 = [ ]
      onts_combinations.each do |combination|
        max_coverage = 0
        combination.each do |acronym|
          max_coverage += single_results_hash[acronym].coverageResult.normalizedScore
        end
        if max_coverage > ranking_single[0].coverageResult.normalizedScore
          c2 << combination
        end
      end
      onts_combinations = c2
      @logger.info('Selected combinations (performance improvement 2): ' + onts_combinations.size.to_s)
      count_combinations = 0
      # Evaluation of ontology sets
      ranking = [ ]
      onts_combinations.each do |set|
        # Coverage evaluation for ontology sets. It is computed for all the annotations together.
        annotations_set = [ ]
        set.each do |acronym|
          annotations_set += single_results_hash[acronym].coverageResult.annotations
        end
        coverage_result_set = @coverage_evaluator.evaluate(input, @annotations_all_hash, annotations_set)
        # NOTE: It may happen that after the coverage evaluation step, which selects the best annotations provided
        # by each set, some ontology/ontologies in the set do not provide any annotation. The evaluation is restricted
        # to those sets whose ontologies (all of them) provide at least one annotation
        # Hash |acronym, annotations|
        annotations_hash = coverage_result_set.annotations.group_by{ |a| a.annotatedClass.submission.ontology.acronym}
        if set.size == annotations_hash.keys.size
          count_combinations += 1
          # Calculates the contribution done by each ontology to the coverage score. This contribution (or partial score)
          # will be used later to calculate the rest of the scores proportionally
          # Hash |acronym, partialscore|
          partial_coverage_scores = { }
          set.each do |acronym|
            sum = 0
            annotations_hash[acronym].each do |a|
              sum += @coverage_evaluator.get_annotation_score(a)
            end
            partial_coverage_scores[acronym] = sum
          end

          # Specialization evaluation for ontology sets
          spec_score_set = 0
          spec_norm_score_set = 0
          set.each do |acronym|
            spec_result = single_results_hash[acronym].specializationResult
            correction_factor = partial_coverage_scores[acronym].to_f / coverage_result_set.score.to_f
            spec_score_set += spec_result.score.to_f * correction_factor.to_f
            spec_norm_score_set += spec_result.normalizedScore.to_f * correction_factor.to_f
          end
          specialization_result_set = OntologyRecommender::Evaluators::SpecializationResult.new(spec_score_set, spec_norm_score_set)

          # Acceptance evaluation for ontology sets
          acceptance_score_set = 0
          bp_score_set = 0
          umls_score_set = 0
          set.each do |acronym|
            acceptance_result = single_results_hash[acronym].acceptanceResult
            correction_factor = partial_coverage_scores[acronym].to_f / coverage_result_set.score.to_f
            acceptance_score_set += acceptance_result.normalizedScore.to_f * correction_factor.to_f
            bp_score_set += acceptance_result.umlsScore.to_f * correction_factor.to_f
            umls_score_set += acceptance_result.bioportalScore.to_f * correction_factor.to_f
          end
          acceptance_result_set = OntologyRecommender::Evaluators::AcceptanceResult.new(acceptance_score_set,
                                                                                        bp_score_set, umls_score_set)
          # Detail of knowledge evaluation for ontology sets
          detail_score_set = 0
          defs_score_set = 0
          syns_score_set = 0
          props_score_set = 0
          set.each do |acronym|
            detail_result = single_results_hash[acronym].detailResult
            correction_factor = partial_coverage_scores[acronym].to_f / coverage_result_set.score.to_f
            detail_score_set += detail_result.normalizedScore.to_f * correction_factor.to_f
            defs_score_set += detail_result.definitionsScore.to_f * correction_factor.to_f
            syns_score_set += detail_result.synonymsScore.to_f * correction_factor.to_f
            props_score_set += detail_result.propertiesScore.to_f * correction_factor.to_f
          end
          detail_result_set = OntologyRecommender::Evaluators::DetailResult.new(detail_score_set, defs_score_set,
                                                                                syns_score_set, props_score_set)

          aggregated_score_set = Scores::ScoreAggregator.
              get_aggregated_scores([Scores::Score.new(coverage_result_set.normalizedScore, wc),
                                     Scores::Score.new(specialization_result_set.normalizedScore, ws),
                                     Scores::Score.new(detail_result_set.normalizedScore, ws)])

          onts = set.map { |acronym| annotations_hash[acronym].first.annotatedClass.submission.ontology }

          ranking << Recommendation.new(aggregated_score_set, onts, coverage_result_set,
                                                       specialization_result_set, acceptance_result_set, detail_result_set)
        end
      end
      @logger.info('Selected combinations (performance improvement 3): ' + count_combinations.to_s)
      # Concat the single ranking
      # if ranking.size < max_results_sets
      #   ranking.concat(ranking_single)
      # end
      # Sort by two criteria: (1) Evaluation score, (2) Set size
      ranking = ranking.sort_by {|element| [-element.evaluationScore.to_f, element.ontologies.size]}
      return ranking[0..max_results_sets-1]
    end

  end
end


















