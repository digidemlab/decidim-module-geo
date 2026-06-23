# frozen_string_literal: true

module Decidim
  module Geo
    # The data store for a Proposal in the Decidim::Proposals component.
    class Shapefile < ApplicationRecord
      # include Decidim::TranslatableResource
      include Decidim::HasUploadValidations

      self.table_name = "decidim_geo_shapefiles"

      has_many :shapedatas, foreign_key: "decidim_geo_shapefiles_id", dependent: :destroy

      belongs_to :taxonomy, inverse_of: :shapefile, optional: true, foreign_key: "decidim_taxonomies_id"

      validates :title, :description, presence: true
      validate :taxonomy_is_root

      has_one_attached :shapefile
      validates_upload :shapefile, uploader: Decidim::Geo::ShapefileUploader
      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      def taxonomy_is_root
        !decidim_taxonomies_id || Decidim::Taxonomy.find(decidim_taxonomies_id).weight.zero?
      end
    end
  end
end
