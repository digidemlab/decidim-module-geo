# frozen_string_literal: true

module Decidim
  module Geo
    class TaxonomyInputFilter < Decidim::Core::BaseInputFilter
      graphql_name "TaxonomyFilter"
      description "A type used for filtering geo datasources by taxonomy"

      argument :taxonomy_id, type: Integer, description: "Retrieve search only on this taxonomy", required: true
    end
  end
end
