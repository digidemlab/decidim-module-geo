# frozen_string_literal: true

module Decidim
  module Geo
    module HasScopeableInputFilter
      def self.included(child_class)
        child_class.argument :scope_id,
                             type: GraphQL::Types::ID,
                             description: "List result by Scope using decidim_taxonomies_id",
                             required: false,
                             prepare: lambda { |_scope_id, _ctx|
                               { decidim_taxonomies_id: taxonomy_id }
                             }
      end
    end
  end
end
