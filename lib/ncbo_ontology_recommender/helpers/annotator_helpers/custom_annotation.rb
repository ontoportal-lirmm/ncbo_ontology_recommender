module OntologyRecommender

  module Helpers

    module AnnotatorHelper

      ##
      # This class represents a mapping between a term and an ontology class. A term can be composed by a unique word
      # (e.g. heart) or by several words (e.g. white blood cell)
      class CustomAnnotation

        include LinkedData::Hypermedia::Resource

        attr_reader :from, :to, :matchType, :text, :annotatedClass, :hierarchySize

        embed :annotatedClass

        def initialize(from, to, match_type, text, annotated_class, hierarchy_size)
          @from = from
          @to = to
          @matchType = match_type
          @text = text
          @annotatedClass = annotated_class
          @hierarchySize = hierarchy_size
        end

        def == (other)
          from == other.from && to == other.to && matchType == other.matchType && text == other.text &&
              annotatedClass == other.annotatedClass && hierarchySize == other.hierarchySize
        end

        # Makes eql? and == synonymous
        def eql? (other)
          self == other
        end

        def hash
          [from, to, matchType, text, annotatedClass, hierarchySize].hash
        end

        def <=> (other) #1 if self>other; 0 if self==other; -1 if self<other
          [from, to, matchType, text, annotatedClass, hierarchySize] <=>
              [other.from, other.to, other.matchType, other.text, other.annotatedClass, other.hierarchySize]
        end

      end
    end
  end
end