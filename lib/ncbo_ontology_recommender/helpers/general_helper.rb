module OntologyRecommender

  module Helpers

    # Given the large number of ontologies in BioPortal, it is necessary to minimize the number of ontologies that
    # will be used to create the ontology sets that will be evaluated. Otherwise, the number of ontology sets will
    # be too high and the evaluation will be too slow.
    #
    # The rules used to select the ontologies are:
    # - If the annotations done with an ontology O1 include the annotations done with another ontology, O2, then O2
    # can be ignored and it will not be taken into account to generate ontology combinations.
    module_function
    def select_ontologies_for_ranking_sets(annotations, coverage_evaluator)
      annotations_hash = annotations.group_by{|ann| ann.annotatedClass.submission.ontology.acronym}
      selected_acronyms = [ ]
      annotations_hash.each do |acr1, anns1|
        anns1_contained_anns2 = false
        anns2_contained_anns1 = false
        annotations_hash.each do |acr2, anns2|
          if acr1 != acr2
            if annotations_contained_in(anns1, anns2, coverage_evaluator)
              anns1_contained_anns2 = true
              if annotations_contained_in(anns2, anns1, coverage_evaluator)
                anns2_contained_anns1 = true
              end
              break
            end
          end
        end
        # Only the ontologies whose annotations are not contained in the annotations of other ontologies will be selected.
        # Exception: if anns1 is contained into anns2 and viceversa, both ontologies are selected
        if (anns1_contained_anns2 == false) || (anns1_contained_anns2 == true && anns2_contained_anns1 == true)
          selected_acronyms << acr1
        end
      end
      return selected_acronyms
    end

    def annotations_contained_in(annotations1, annotations2, coverage_evaluator)
      annotations1.each do |a1|
        contained = false
        annotations2.each do |a2|
          if (a1.from >= a2.from) and (a1.to <= a2.to)
            a1_score = coverage_evaluator.get_annotation_score(a1)
            a2_score = coverage_evaluator.get_annotation_score(a2)
            if a2_score >= a1_score
              contained = true
              break
              # If two annotations provide exactly the same coverage the following "elsif" could be used to give more priority
              # to one of them using other criteria (e.g. the acceptance of the ontology they belong to)
              # elsif a2_score == a1_score
            end
          end
        end
        if contained == false
          return false
        end
      end
      return true
    end

    # Obtains all possible combinations with '1' to 'max_elements' elements
    module_function
    def get_combinations(elements, max_elements)
      combinations = []
      1.upto(max_elements) do |i|
        combinations = combinations + elements.combination(i).to_a
      end
      return combinations
    end

    module_function
    def normalize(x, xmin, xmax, ymin, ymax)
      xrange = xmax - xmin
      yrange = ymax - ymin
      return ymin if xrange == 0
      ymin + (x - xmin) * (yrange.to_f / xrange.to_f)
    end

    # Normalizes an array of values in the interval 0..X to the interval 0..1, such that the sum of all values is 1
    module_function
    def normalize_weights(weights)
      weights.each do |w|
        if w < 0
          raise RangeError, 'The weights cannot be lower than 0'
        end
      end
      norm_weights = [ ]
      sum = weights.reduce(:+)
      if sum <= 0
        raise ArgumentError, 'The sum of the weights must be greater than 0'
      end
      weights.each do |w|
        norm_weights << w.to_f / sum.to_f
      end
      return norm_weights
    end

    module_function
    def get_ont_acronym_from_uri(uri)
      uri_parts = uri.split("/")
      return uri_parts[uri_parts.length-1]
    end

    module_function
    def get_ontology(ont_acronym)
      ont = LinkedData::Models::Ontology.find(ont_acronym).first
      ont.bring(*LinkedData::Models::Ontology.goo_attrs_to_load([:acronym, :name]))
      return ont
    end

  end

end


