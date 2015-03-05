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



  end

end
