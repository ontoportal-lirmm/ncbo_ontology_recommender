module OntologyRecommender

  module Utils

    module AnnotatorUtils

      ##
      # This class represents a mapping between a term and an ontology class. A term can be composed by a unique word
      # (e.g. heart) or by several words (e.g. white blood cell)
      class CustomAnnotation

        include LinkedData::Hypermedia::Resource

        attr_reader :from, :to, :matchType, :text, :annotatedClass

        embed :annotatedClass

        def initialize(from, to, match_type, text, annotatedClass)
          @from = from
          @to = to
          @matchType = match_type
          @text = text
          @annotatedClass = annotatedClass
        end

        def == (other)
          from == other.from && to == other.to && matchType == other.matchType && text == other.text &&
              annotatedClass == other.annotatedClass
        end

        # Makes eql? and == synonymous
        def eql? (other)
          self == other
        end

        def hash
          [from, to, matchType, text, annotatedClass].hash
        end

        def <=> (other) #1 if self>other; 0 if self==other; -1 if self<other
          [from, to, matchType, text, annotatedClass] <=>
              [other.from, other.to, other.matchType, other.text, other.annotatedClass]
        end

      end
    end
  end
end