require "ontologies_linked_data"
require "ncbo_annotator"
require_relative "../lib/ncbo_ontology_recommender"
require_relative "../config/config.rb"

require "test/unit"

# Check to make sure you want to run if not pointed at localhost
safe_host = Regexp.new(/localhost|ncbo-dev*|ncbo-unittest*|ncbo-stg-app-22*/)
unless LinkedData.settings.goo_host.match(safe_host) && LinkedData.settings.search_server_url.match(safe_host) && Annotator.settings.annotator_redis_host.match(safe_host)
  print "\n\n================================== WARNING ==================================\n"
  print "** TESTS CAN BE DESTRUCTIVE -- YOU ARE POINTING TO A POTENTIAL PRODUCTION/STAGE SERVER **\n"
  print "Servers:\n"
  print "triplestore -- #{LinkedData.settings.goo_host}\n"
  print "search -- #{LinkedData.settings.search_server_url}\n"
  print "redis annotator -- #{Annotator.settings.annotator_redis_host}:#{Annotator.settings.annotator_redis_port}\n"
  print "Type 'y' to continue: "
  $stdout.flush
  confirm = $stdin.gets
  if !(confirm.strip == 'y')
    abort("Canceling tests...\n\n")
  end
  print "Running tests..."
  $stdout.flush
end

require 'minitest/unit'
MiniTest::Unit.autorun

class RecommenderUnit < MiniTest::Unit
  ANALYTICS_DATA = {
      "NCIT" => {
          2013 => {
              1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 2850, 11 => 1631, 12 => 1323
          },
          2014 => {
              1 => 1004, 2 => 1302, 3 => 2183, 4 => 2191, 5 => 1005, 6 => 1046, 7 => 1261, 8 => 1329, 9 => 1100, 10 => 956, 11 => 1105, 12 => 893
          },
          2015 => {
              1 => 840, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0
          }
      },
      "ONTOMA" => {
          2013 => {
              1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 6, 11 => 15, 12 => 0
          },
          2014 => {
              1 => 2, 2 => 0, 3 => 0, 4 => 2, 5 => 2, 6 => 0, 7 => 6, 8 => 8, 9 => 0, 10 => 0, 11 => 0, 12 => 2
          },
          2015 => {
              1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0
          }
      },
      "CMPO" => {
          2013 => {
              1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 64, 11 => 75, 12 => 22
          },
          2014 => {
              1 => 15, 2 => 15, 3 => 19, 4 => 12, 5 => 13, 6 => 14, 7 => 22, 8 => 12, 9 => 36, 10 => 6, 11 => 8, 12 => 10
          },
          2015 => {
              1 => 7, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0
          }
      },
      "AEO" => {
          2013 => {
              1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 129, 11 => 142, 12 => 70
          },
          2014 => {
              1 => 116, 2 => 93, 3 => 85, 4 => 132, 5 => 96, 6 => 137, 7 => 69, 8 => 158, 9 => 123, 10 => 221, 11 => 163, 12 => 43
          },
          2015 => {
              1 => 25, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0
          }
      },
      "SNOMEDCT" => {
          2013 => {
              1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 20721, 11 => 22717, 12 => 18565
          },
          2014 => {
              1 => 17966, 2 => 17212, 3 => 20942, 4 => 20376, 5 => 21063, 6 => 18734, 7 => 18116, 8 => 18676, 9 => 15728, 10 => 16348, 11 => 13933, 12 => 9533
          },
          2015 => {
              1 => 9036, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0
          }
      },
      "TST" => {
          2013 => {
              1 => 0, 2 => 0, 3 => 23, 4 => 0, 5 => 0, 6 => 0, 7 => 20, 8 => 0, 9 => 0, 10 => 234, 11 => 7654, 12 => 2311
          },
          2014 => {
              1 => 39383, 2 => 239, 3 => 40273, 4 => 3232, 5 => 2, 6 => 58734, 7 => 11236, 8 => 23, 9 => 867, 10 => 232, 11 => 1111, 12 => 8
          },
          2015 => {
              1 => 2000, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0
          }
      }
  }
  def self.ontologies
    @@ontologies
  end

  # Code to run before the very first test
  def before_suites
    LinkedData::SampleData::Ontology.delete_ontologies_and_submissions
    @@ontologies = LinkedData::SampleData::Ontology.sample_owl_ontologies
    @@sty = LinkedData::SampleData::Ontology.load_semantic_types_ontology
    annotator = Annotator::Models::NcboAnnotator.new
    annotator.init_redis_for_tests()
    annotator.create_term_cache_from_ontologies(@@ontologies, true)
    annotator.redis_switch_instance()
    # Ontology analytics data
    annotator.redis.set('ontology_analytics', Marshal.dump(ANALYTICS_DATA))
  end

  def after_suites
    # code to run after the very last test
    LinkedData::SampleData::Ontology.delete_ontologies_and_submissions
  end

  def _run_suites(suites, type)
    begin
      before_suites
      super(suites, type)
    ensure
      after_suites
    end
  end

  def _run_suite(suite, type)
    begin
      suite.before_suite if suite.respond_to?(:before_suite)
      super(suite, type)
    ensure
      suite.after_suite if suite.respond_to?(:after_suite)
    end
  end
end
MiniTest::Unit.runner = RecommenderUnit.new

#
# Base test class. Put shared test methods or setup here.
class TestCase < MiniTest::Unit::TestCase
end
