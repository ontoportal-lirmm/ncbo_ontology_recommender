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
        if @spec_scores_hash != nil
          @spec_scores_hash[ont_acronym]!=nil ? (return @spec_scores_hash[ont_acronym]) : (return OntologyRecommender::Evaluators::SpecializationResult.new(0, 0))
        else
          @spec_scores_hash = { }
          top_spec_score = 0
          annotations_hash.each do |ont_acronym, anns|
            # Calculates the specialization score
            spec_score = 0
            # For ALL the annotations done with the ontology...
            anns.each do |ann|
              spec_score += get_annotation_score(ann) + (2 * ann.hierarchySize)
            end
            # Number of classes in the ontology
            num_classes = get_number_of_classes(ont_acronym)
            if num_classes.nil?
              spec_score = 0
              @logger.info("Ontology not found (#{ont_acronym}). Specialization score set to 0")
            else
              # Normalization by ontology size
              spec_score = (spec_score / Math.log10(num_classes)).round(3)
            end
            if spec_score > top_spec_score
              top_spec_score = spec_score
            end
            # The normalized score (range [0,1]) will be computed and assigned after evaluating all ontologies
            @spec_scores_hash[ont_acronym] = OntologyRecommender::Evaluators::SpecializationResult.new(spec_score.round(3), nil)
          end
          @spec_scores_hash.each do |ont_acronym, spec_result|
            spec_result.normalizedScore = OntologyRecommender::Helpers.normalize(spec_result.score, 0, top_spec_score, 0, 1).round(3)
            @spec_scores_hash[ont_acronym] = spec_result
          end
          @spec_scores_hash[ont_acronym]!=nil ? (return @spec_scores_hash[ont_acronym]) : (return OntologyRecommender::Evaluators::SpecializationResult.new(0, 0))
        end
      end

      # The annotation score is computed in the same way than for the coverage evaluation
      private
      def get_annotation_score(annotation)
        number_of_words = annotation.text.split(" ").length
        match_type_score = annotation.matchType == 'PREF' ? @pref_score : @syn_score
        if number_of_words == 1
          score = match_type_score
        else
          score = (match_type_score + @multiterm_score) * number_of_words
        end
        return score
      end

      private
      def get_number_of_classes(ont_acronym)
        if @metrics_hash.nil?
          # Retrieve metrics for all ontologies
          metrics = get_metrics()
          @metrics_hash = metrics.group_by{|m| m.submission.first.ontology.acronym}
        end
        if @metrics_hash[ont_acronym] != nil
          cls_count = @metrics_hash[ont_acronym].first.classes
        else
          @logger.info("Ontology metrics not found (#{ont_acronym})")
          ont = LinkedData::Models::Ontology.find(ont_acronym)
          if ont.nil?
            cls_count = nil
          else
            # Retrieves submission
            sub = ont.first.latest_submission
            cls_count = LinkedData::Models::Class.where.in(sub).count
          end
        end
        return cls_count
      end

      private
      def get_metrics(params = {})
        # check_last_modified_collection(LinkedData::Models::Metric)
        submissions = retrieve_latest_submissions(params)
        submissions = submissions.values
        # metrics_include = LinkedData::Models::Metric.goo_attrs_to_load(includes_param)
        metrics_include = LinkedData::Models::Metric.goo_attrs_to_load()
        LinkedData::Models::OntologySubmission.where.models(submissions)
            .include(metrics: metrics_include).all
        #just a fallback for metrics that are not really built.
        to_remove = []
        submissions.each do |x|
          if x.metrics
            begin
              x.metrics.submission
            rescue
              LOGGER.error("submission with inconsistent metrics #{x.id.to_s}")
              to_remove << x
            end
          end
        end
        to_remove.each do |x|
          submissions.delete x
        end
        #end fallback
        return submissions.select { |s| !s.metrics.nil? }.map { |s| s.metrics }
      end

      private
      def retrieve_latest_submissions(options = {})
        status = (options[:status] || "RDF").to_s.upcase
        include_ready = status.eql?("READY") ? true : false
        status = "RDF" if status.eql?("READY")
        any = true if status.eql?("ANY")
        include_views = options[:also_include_views] || false
        # includes = OntologySubmission.goo_attrs_to_load(includes_param)
        includes = LinkedData::Models::OntologySubmission.goo_attrs_to_load()
        includes << :submissionStatus unless includes.include?(:submissionStatus)
        if any
          submissions_query = LinkedData::Models::OntologySubmission.where
        else
          submissions_query = LinkedData::Models::OntologySubmission.where(submissionStatus: [ code: status])
        end
        submissions_query = submissions_query.filter(Goo::Filter.new(ontology: [:viewOf]).unbound) unless include_views
        submissions = submissions_query.include(includes).to_a
        # Figure out latest parsed submissions using all submissions
        latest_submissions = {}
        submissions.each do |sub|
          next if include_ready && !sub.ready?
          latest_submissions[sub.ontology.acronym] ||= sub
          latest_submissions[sub.ontology.acronym] = sub if sub.submissionId > latest_submissions[sub.ontology.acronym].submissionId
        end
        return latest_submissions
      end

    end

  end

end