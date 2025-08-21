# frozen_string_literal: true

module Decidim
  module Geo
    module Admin
      class ShapefilesController < ApplicationController
        before_action :authenticate_user!
        add_breadcrumb_item_from_menu :admin_geo_menu

        def index
          enforce_permission_to :list, :shapefile
          @shapefiles = Decidim::Geo::Shapefile.where(decidim_organization_id: current_organization.id)
        end

        def new
          enforce_permission_to :new, :shapefile
          @form = Decidim::Geo::Admin::ShapefileForm.new
        end

        def create
          enforce_permission_to :create, :shapefile
          @form = form(Decidim::Geo::Admin::ShapefileForm).from_params(params)

          Admin::CreateShapefile.call(@form) do
            on(:invalid) do |message|
              flash.now[:alert] = message || @form.errors.full_messages.join(",") || "Can not upload this shapefile"
              render action: "new"
            end

            on(:ok) do
              flash[:notice] = I18n.t("shapefiles.actions.create.success", scope: "decidim.geo.admin")
              redirect_to shapefiles_path
            end
          end
        end
      end
    end
  end
end
