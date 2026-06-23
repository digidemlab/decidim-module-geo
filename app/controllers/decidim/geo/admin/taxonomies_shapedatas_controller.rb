# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      class TaxonomiesShapedatasController < Decidim::Geo::Admin::ApplicationController
        before_action :authenticate_user!
        add_breadcrumb_item_from_menu :admin_geo_menu

        helper_method :taxonomy_children, :shapedata, :taxonomy_child, :shapedata_options, :selected_shapedata_id

        def show
          redirect_to action: "index"
        end

        def index
          raise ActiveRecord::RecordNotFound unless current_organization.geo_enabled?
        end

        def update
          @form = form(Decidim::Geo::Admin::TaxonomyShapedataForm).from_params(params)

          Admin::UpdateShapedataTaxonomy.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("taxonomies_shapedatas.actions.update.success", scope: "decidim.geo.admin")
              redirect_to action: "index"
            end

            on(:invalid) do
              flash.now[:alert] = form.errors.full_messages.join(",")
              redirect_to action: "index"
            end
          end
        end

        def edit
          @form = form(Decidim::Geo::Admin::TaxonomyShapedataForm).from_model(taxonomy_child)
          @form.taxonomy_id = taxonomy_child.id
          @form.shapedata_id = taxonomy_child&.shapedata&.id

          render :edit, layout: false
        end

        private

        def geo_config
          @geo_config ||= Decidim::Geo::GeoConfig.geo_config_default(current_organization)
        end

        def taxonomy_children
          shapefile&.taxonomy.present? ? Decidim::Taxonomy.where(parent_id: shapefile.decidim_taxonomies_id) : []
        end

        def taxonomy_child
          Decidim::Taxonomy.find_by(id: params[:id])
        end

        def shapefile
          Decidim::Geo::Shapefile.find_by(id: geo_config.decidim_geo_shapefiles_id)
        end

        def shapedata
          Decidim::Geo::Shapedata.find_by(decidim_taxonomies_id: taxonomy_child.id)
        end

        def shapedata_options
          Decidim::Geo::Shapedata.where(decidim_taxonomies_id: nil, decidim_geo_shapefiles_id: shapefile.id).order(Arel.sql("data->>'NAME' ASC"))
        end

        def selected_shapedata_id
          shapedata.decidim_taxonomies_id if shapedata
        end
      end
    end
  end
end
