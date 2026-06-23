# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      # A command with all the business logic when updating a shapedata with taxonomy.
      class UpdateShapedataTaxonomy < Decidim::Geo::Command
        attr_reader :geo_config, :form

        # Public: Initializes the command.
        #
        # shapedata - The shapedata to update
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_shapedata
          broadcast(:ok)
        end

        private

        def update_shapedata
          old_shapedata = Decidim::Geo::Shapedata.find_by(decidim_taxonomies_id: form.id)
          if old_shapedata
            old_shapedata.decidim_taxonomies_id = nil
            old_shapedata.save!
          end

          shapedata.update!(decidim_taxonomies_id: form.id)
        end

        def shapedata
          @shapedata = Decidim::Geo::Shapedata.find_by(id: form.shapedata_id)
        end
      end
    end
  end
end
