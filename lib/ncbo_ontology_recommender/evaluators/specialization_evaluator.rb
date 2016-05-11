require_relative 'specialization_result'

module OntologyRecommender

  module Evaluators
    ##
    # Ontology specialization evaluator
    class SpecializationEvaluator

      attr_reader :pref_score, :syn_score, :multiterm_score

      def initialize(pref_score, syn_score, multiterm_score)
        @logger = Kernel.const_defined?('LOGGER') ? Kernel.const_get('LOGGER') : Logger.new(STDOUT)
        @pref_score = pref_score
        @syn_score = syn_score
        @multiterm_score = multiterm_score
        @spec_scores_hash = nil
        @metrics_hash = nil
      end

      def evaluate(annotations_hash, ont_acronym)
        if @spec_scores_hash.nil?
          @spec_scores_hash = {}
          top_spec_score = 0

          annotations_hash.each do |acr, anns|
            # Calculates the specialization score
            spec_score = 0
            # Number of classes in the ontology
            num_classes = get_number_of_classes(acr)

            if num_classes.nil? || num_classes == 0
              @logger.info("Number of classes for #{acr} is #{num_classes}. Specialization score set to 0.")
            else
              # For ALL the annotations done with the ontology...
              anns.each { |ann| spec_score += get_annotation_score(ann) + (2 * ann.hierarchySize) }
              # Normalization by ontology size
              spec_score = (spec_score / Math.log10(num_classes)).round(3)
            end

            if spec_score > top_spec_score
              top_spec_score = spec_score
            end
            # The normalized score (range [0,1]) will be computed and assigned after evaluating all ontologies
            @spec_scores_hash[acr] = OntologyRecommender::Evaluators::SpecializationResult.new(spec_score.round(3), nil)
          end

          @spec_scores_hash.each do |acr, spec_result|
            spec_result.normalizedScore = OntologyRecommender::Helpers.normalize(spec_result.score, 0, top_spec_score, 0, 1).round(3)
            @spec_scores_hash[acr] = spec_result
          end
        end

        @spec_scores_hash[ont_acronym] || OntologyRecommender::Evaluators::SpecializationResult.new(0, 0)
      end

      private

      # The annotation score is computed in the same way than for the coverage evaluation
      def get_annotation_score(annotation)
        number_of_words = annotation.text.split(" ").length
        match_type_score = annotation.matchType == 'PREF' ? @pref_score : @syn_score
        if number_of_words == 1
          score = match_type_score
        else
          score = (match_type_score + @multiterm_score) * number_of_words
        end
        score
      end

      def get_number_of_classes(ont_acronym)
        if @metrics_hash.nil?
          @metrics_hash = {}
          subs = retrieve_latest_submissions

          subs.each do |acronym, sub|
            cls_count = sub.class_count(@logger)
            @metrics_hash[acronym] = cls_count
          end
        end

        cls_count = @metrics_hash[ont_acronym]
        # if cls_count is not found, nil is returned
        cls_count = nil if cls_count && cls_count < 0
        cls_count
      end

      def retrieve_latest_submissions(options={})
        includes = LinkedData::Models::OntologySubmission.goo_attrs_to_load()
        includes << :submissionStatus unless includes.include?(:submissionStatus)
        # load metrics for all submissions (needed for getting class counts)
        includes << {metrics: :classes}
        submissions_query = LinkedData::Models::OntologySubmission.where(submissionStatus: [code: "RDF"])
        include_views = options[:also_include_views] || false
        submissions_query = submissions_query.filter(Goo::Filter.new(ontology: [:viewOf]).unbound) unless include_views
        submissions = submissions_query.include(includes).to_a
        # Figure out latest parsed submissions using all submissions
        latest_submissions = {}

        submissions.each do |sub|
          latest_submissions[sub.ontology.acronym] ||= sub
          latest_submissions[sub.ontology.acronym] = sub if sub.submissionId > latest_submissions[sub.ontology.acronym].submissionId
        end
        latest_submissions
      end

    end
  end
end