# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      class GeoConfigsController < Decidim::Geo::Admin::ApplicationController
        before_action :authenticate_user!
        add_breadcrumb_item_from_menu :admin_geo_menu
        def index
          redirect_to action: "show", id: geo_config.id
        end

        def show
          raise ActiveRecord::RecordNotFound unless current_organization.geo_enabled

          @form = form(Decidim::Geo::Admin::GeoConfigForm).from_model(geo_config)
        end

        def create
          update
        end

        def update
          @form = form(Decidim::Geo::Admin::GeoConfigForm).from_params(params)

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
      end
    end
  end
end
