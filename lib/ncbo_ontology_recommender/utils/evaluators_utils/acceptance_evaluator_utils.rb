require_relative '../../../../lib/ncbo_ontology_recommender/config'

module OntologyRecommender

  module Utils

    module EvaluatorsUtils

      module AcceptanceEvaluatorUtils

        # TODO: the following methods should be executed periodically

        module_function
        def generate_bioportal_scores
          path_in = OntologyRecommender.settings.bp_data_file
          path_out = OntologyRecommender.settings.bp_scores_file
          position = 1
          lines = File.open(path_in).readlines
          file_out = File.open(path_out, 'w')
          lines.each do |line|
            file_out.write(line.chomp + '|' + get_bioportal_score(position, lines.length).to_s + "\n")
            position += 1
          end
        end

        def generate_umls_scores
          path_in = OntologyRecommender.settings.umls_data_file
          path_out = OntologyRecommender.settings.umls_scores_file
          lines = File.open(path_in).readlines
          file_out = File.open(path_out, 'w')
          # Score for the ontologies included into UMLS
          score = 1
          lines.each do |line|
            file_out.write(line.chomp + '|' + score.to_s + "\n")
          end
        end

        def generate_pubmed_scores
          # TODO: read from config file
          path_in = OntologyRecommender.settings.pmed_data_file
          path_out = OntologyRecommender.settings.pmed_scores_file
          citations_hash = { }
          lines = File.open(path_in).readlines
          file_out = File.open(path_out, 'w')
          top_citations = 0
          lines.each do |line|
            ont_acronym = line.chomp.split('|')[0]
            citations = line.chomp.split('|')[2].to_i
            citations_hash[ont_acronym] = citations
            if citations > top_citations
              top_citations = citations
            end
          end
          if top_citations == 0
            raise Exception, 'The highest number of citations is 0'
          end
          citations_hash.each do |k,v|
            score = v > 0? Math.log10(v) : 0
            norm_score = OntologyRecommender::Utils.normalize(score, 0, Math.log10(top_citations), 0, 1)
            file_out.write(k + '|' + norm_score.to_s + "\n")
          end
        end

        private
        module_function
        def get_bioportal_score(position_in_ranking, ranking_size)
          # Formula = 1 - (position-1 / n-1)
          # Example: suppose n=100
          # 1st ontology = 1 - (1-1 / 100) = 1
          # 100 ontology = 1 - (100-1 / 100-1) = 0
          return 1.to_f - ((position_in_ranking - 1).to_f / (ranking_size - 1).to_f)
        end

      end
    end

  end

end