# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      class GeoConfigsController < Decidim::Geo::Admin::ApplicationController
        before_action :authenticate_user!
        add_breadcrumb_item_from_menu :admin_geo_menu

        helper_method :has_shapedata?, :has_taxonomy?

        def index
          redirect_to action: "show", id: geo_config.id
        end

        def show
          raise ActiveRecord::RecordNotFound unless current_organization.geo_enabled?

          @form = form(Decidim::Geo::Admin::GeoConfigForm).from_model(geo_config)
          @form.taxonomy_id = shapefile.decidim_taxonomies_id unless shapefile.nil?
        end

        def create
          update
        end

        def update
          @form = form(Decidim::Geo::Admin::GeoConfigForm).from_params(params)

          @form.decidim_geo_shapefiles_id = geo_config.decidim_geo_shapefiles_id unless params[:geo_config].has_key?(:decidim_geo_shapefiles_id)

          Admin::UpdateGeoConfig.call(geo_config, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("geo_configs.actions.update.success", scope: "decidim.geo.admin")
              redirect_to action: "show", id: geo_config.id
            end

            on(:invalid) do
              flash.now[:alert] = form.errors.full_messages.join(",")
              render action: "show", id: geo_config.id
            end
          end
        end

        private

        def geo_config
          @geo_config ||= Decidim::Geo::GeoConfig.geo_config_default(current_organization)
        end

        def shapefile
          Decidim::Geo::Shapefile.find_by(id: geo_config.decidim_geo_shapefiles_id)
        end

        def shapefiles
          @shapefiles = Decidim::Geo::Shapefile.all
        end

        def has_shapedata?
          return false unless has_taxonomy?

          shapefile.taxonomy.children.find { |child| child.shapedata.present? }
        end

        def has_taxonomy?
          shapefile && shapefile&.taxonomy
        end
      end
    end
  end
end
