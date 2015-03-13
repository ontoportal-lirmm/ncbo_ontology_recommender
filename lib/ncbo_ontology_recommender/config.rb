require 'goo'
require 'ostruct'
require 'set'

module OntologyRecommender
  extend self
  attr_reader :settings

  @settings = OpenStruct.new
  @settings_run = false

  def config(&block)
    return if @settings_run
    @settings_run = true

    yield @settings if block_given?

    # Set defaults
    # The URL for the BioPortal Rails UI
    @settings.input_type ||= 1
    @settings.output_type ||= 1
    @settings.delimiter ||= ','
    # Coverage evaluation
    @settings.wc ||= 0.55
    @settings.pref_score ||= 10
    @settings.syn_score ||= 5
    @settings.multiterm_score ||= 4
    # Specialization evaluation
    @settings.ws ||= 0.15
    # Acceptance evaluation
    @settings.wa ||= 0.15
    @settings.w_bp ||= 0.50
    @settings.w_umls ||= 0.50
    # Detail evaluation
    @settings.wd ||= 0.15
    @settings.top_defs ||= 1
    @settings.top_syns ||= 3
    @settings.top_props ||= 17
    # Other parameters
    @settings.max_elements_set ||= 3
    @settings.max_results_single ||= 25
    @settings.max_results_sets ||= 25

  end

end
