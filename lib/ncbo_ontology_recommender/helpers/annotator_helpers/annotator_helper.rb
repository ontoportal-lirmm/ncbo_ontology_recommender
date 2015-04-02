require_relative('custom_annotation')
require_relative('text_position')

module OntologyRecommender

  module Helpers

    module AnnotatorHelper
      # Obtain the annotations for an input (text or keywords).
      #   Input types: 1 (text), 2 (keywords).
      module_function
      def get_annotations(input, input_type, delimiter, ontologies)
        if input.strip.size == 0 then return [] end
        logger =  @logger = Kernel.const_defined?('LOGGER') ? Kernel.const_get('LOGGER') : Logger.new(STDOUT)
        logger.info('Obtaining annotations from the Annotator')
        annotator = Annotator::Models::NcboAnnotator.new
        # Obtains the annotations done with all BioPortal ontologies. All these annotations will be used later, to
        # compute the maximum coverage score possible, which will be used to normalize the coverage score
        time_annotator = Time.now
        annotations = annotator.annotate(input, {
                                                  ontologies: ontologies,
                                                  semantic_types: [],
                                                  filter_integers: false,
                                                  expand_class_hierarchy: true,
                                                  expand_hierarchy_levels: 5,
                                                  expand_with_mappings: false,
                                                  min_term_size: 0,
                                                  whole_word_only: true,
                                                  with_synonyms: true,
                                              })
        @logger.info('TIME - Annotator call: ' + (Time.now-time_annotator).to_s + ' sec.')
        custom_annotations = [ ]
        annotations.each do |ann|
          ann.annotations.each do |a|
            custom_annotation = CustomAnnotation.new(a[:from], a[:to], a[:matchType], a[:text], ann.annotatedClass, ann.hierarchy.size)
            custom_annotations.push(custom_annotation)
          end
        end
        @logger.info('Annotations obtained: ' + custom_annotations.size.to_s)
        # If the input type is 'keywords', only the annotations that represent whole keywords are kept.
        if input_type == 2
          custom_annotations = get_keyword_annotations(input, delimiter, custom_annotations)
          @logger.info('Annotations kept: ' + custom_annotations.size.to_s)
        end

        return custom_annotations
      end

      ##
      # Obtains the annotations that annotate whole keywords.
      def get_keyword_annotations(input, delimiter, annotations)
        annotations2 = annotations.clone
        keyword_positions = get_keyword_positions(input, delimiter)
        annotations2.delete_if {|ann| !keyword_positions.include? TextPosition.new(ann.from, ann.to)}
        return annotations2
      end

      ##
      # Obtains all the annotations that cover a specific input fragment from a specific position
      module_function
      def get_annotations_for_fragment(from, to, annotations)
        annotations2 = annotations.clone
        # Removes all annotations that do not cover that fragment
        annotations2.delete_if {|ann| !(ann.from == from and ann.to >= to)}
        return annotations2
      end

      ##
      # Obtains the start (from) and end (to) positions for all the keywords (one-based index).
      def get_keyword_positions(input, delimiter)
        keyword_positions = []
        searching_for_start = true
        start_position, end_position = 0
        input.split("").each_with_index do |c,i|
          # Chars to ignore
          if c != ' ' and c != '\n' and c != '\t'
            if searching_for_start
              if c != delimiter
                start_position = i + 1
                end_position = start_position
                searching_for_start = false
              else # Searching for start and a delimiter was found -> do nothing.
              end
            else # Searching for the end position.
              if c != delimiter
                end_position = i + 1
              else # Searching for end and a delimiter was found.
                keyword_positions.push(TextPosition.new(start_position, end_position))
                searching_for_start = true
              end
            end
          end
          if !searching_for_start and i == input.length-1 # Last position.
            keyword_positions.push(TextPosition.new(start_position, end_position))
          end
        end
        return keyword_positions
      end
    end
  end

end