require_relative '../../../lib/ncbo_ontology_recommender/config'
require_relative 'acceptance_result'

module OntologyRecommender

  module Evaluators

    BP_VISITS_NUMBER_MONTHS = 12
    ##
    # Ontology acceptance evaluator
    class AcceptanceEvaluator
      # - w_bp: weight assigned to the number of visits (pageviews) received by the ontology in BioPortal
      # - w_umls: weight assigned to the criteria "is the ontology included into UMLS?"
      def initialize(w_bp, w_umls)
        @logger = Kernel.const_defined?('LOGGER') ? Kernel.const_get('LOGGER') : Logger.new(STDOUT)
        @w_bp = w_bp
        @w_umls = w_umls
        @umls_ontologies = nil
        @visits_hash = nil
      end

      def evaluate(acronyms, ont_acronym, current_year = Time.now.year, current_month = Time.now.month)
        bp_score = get_bp_score(ont_acronym, BP_VISITS_NUMBER_MONTHS, current_year, current_month)
        umls_score = get_umls_score(acronyms, ont_acronym)
        norm_score = @w_bp * bp_score + @w_umls * umls_score
        return OntologyRecommender::Evaluators::AcceptanceResult.new(norm_score.round(3), bp_score.round(3), umls_score.round(3))
      end

      private
      def get_umls_score(all_acronyms, ont_acronym)
        if @umls_ontologies == nil
          @umls_ontologies = OntologyRecommender::Helpers.get_umls_ontologies(all_acronyms)
        end
        if @umls_ontologies.include? ont_acronym
          return 1
        else
          return 0
        end
      end

      private
      # - num_months: number of months used to calculate the score (e.g. months = 6 => last 6 months)
      def get_bp_score(ont_acronym, num_months, current_year, current_month)
        if @visits_hash == nil
          @visits_hash = get_visits_for_period(num_months, current_year, current_month)
        end
        # log10 normalization and range change to [0,1]
        if (!@visits_hash.values.max.nil?) && (@visits_hash.values.max > 0)
          norm_max_visits = Math.log10(@visits_hash.values.max)
        else
          norm_max_visits = 1
        end
        norm_visits = 0
        ont_visits = @visits_hash[ont_acronym]
        if ont_visits.nil?
          @logger.info("Ontology not found (#{ont_acronym}). BioPortal score set to 0")
        elsif ont_visits > 0
          norm_visits = Math.log10(ont_visits)
        end
        bp_score = OntologyRecommender::Helpers.normalize(norm_visits, 0, norm_max_visits, 0, 1)
        return bp_score
      end

      # Return a hash |acronym, visits| for the last num_months. The result is ranked by visits
      private
      def get_visits_for_period(num_months, current_year, current_month)
        # Visits for all BioPortal ontologies
        bp_all_visits = get_visits([])
        periods = get_last_periods(num_months, current_year, current_month)
        period_visits = Hash.new
        bp_all_visits.each do |acronym, visits|
          period_visits[acronym] = 0
          periods.each do |p|
            period_visits[acronym] += visits[p[0]][p[1]]
          end
        end
        return period_visits
      end

      private
      # Obtains an array of [year, month] elements for the last num_months
      def get_last_periods(num_months, year, month)
        # Array of [year, month] elements
        periods = [ ]
        num_months.times do
          if month > 1
            month -= 1
          else
            month = 12
            year -= 1
          end
          periods << [year, month]
        end
        return periods
      end

      private
      # If acronyms = [], all the analytics are returned
      def get_visits(acronyms)
        redis = Redis.new(host: Annotator.settings.annotator_redis_host, port: Annotator.settings.annotator_redis_port)
        raw_analytics = redis.get('ontology_analytics')
        raise Exception, 'Error loading ontology analytics data' if raw_analytics.nil?
        analytics = Marshal.load(raw_analytics)
        analytics.delete_if { |key, _| !acronyms.include? key } unless acronyms.empty?
        return analytics
      end

    end

  end

end