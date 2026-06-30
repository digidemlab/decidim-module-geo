# frozen_string_literal: true

require_relative "version"
require "rails"
require "decidim/core"
require "decidim/toggle"
require "rgeo-geojson"

module Decidim
  module Geo
    # This is the engine that runs on the public interface of geo.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Geo

      routes do
        scope :api do
          scope :"decidim-geo" do
            resources :geo_taxonomies, only: [:index, :show]
            resources :points, only: [:index]
            get "points/count", to: "points#count", as: :count_point
            get "points/search", to: "points#search_title", as: :search_title
          end
        end
      end

      config.to_prepare do
        # CSP extras
        Decidim::ApplicationController.include(Decidim::Geo::ContentSecurityPolicy)
        Decidim::Admin::ApplicationController.include(Decidim::Geo::ContentSecurityPolicy)

        # API overrides
        Decidim::Api::QueryType.include Decidim::Geo::QueryExtension
        Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter.include Decidim::Geo::HasScopeableInputFilter

        # Add overrides to add locations where there haven't any
        Decidim::Assembly.include(Decidim::Geo::HasDecidimGeoLocation)
        Decidim::Assemblies::Admin::AssemblyForm.include(Decidim::Geo::GeoSpaceAddressForm)
        Decidim::Assemblies::Admin::CreateAssembly.include(Decidim::Geo::AssemblyCreateCommandOverride)
        Decidim::Assemblies::Admin::UpdateAssembly.include(Decidim::Geo::AssemblyUpdateCommandOverride)

        Decidim::ParticipatoryProcess.include(Decidim::Geo::HasDecidimGeoLocation)
        Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm.include(Decidim::Geo::GeoSpaceAddressForm)
        Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.include(Decidim::Geo::ParticipatoryProcessCommandOverride)
        Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.include(Decidim::Geo::ParticipatoryProcessCommandOverride)

        Decidim::Accountability::Result.include(Decidim::Geo::HasDecidimGeoLocation)
        Decidim::Accountability::Admin::ResultForm.include(Decidim::Geo::GeoSpaceAddressForm)
        Decidim::Accountability::Admin::UpdateResult.include(Decidim::Geo::AccountabilityUpdateCommandOverride)
        Decidim::Accountability::Admin::CreateResult.include(Decidim::Geo::AccountabilityCreateCommandOverride)

        # Override Component to add a "avoid_index" field
        Decidim::Admin::ComponentForm.include(Decidim::Geo::ComponentFormOverride)
        Decidim::Component.include(Decidim::Geo::ComponentNoIndexAttr)
        Decidim::Component.include(Decidim::Geo::UpdateGeoComponent)

        # Override Component to add a "hide_map" field
        Decidim::Admin::ComponentForm.include(Decidim::Geo::ComponentFormOverride)
        Decidim::Component.include(Decidim::Geo::ComponentHideMapAttr)

        Decidim::Admin::CreateComponent.include(Decidim::Geo::CreateComponentCommandOverride)
        Decidim::Admin::UpdateComponent.include(Decidim::Geo::UpdateComponentCommandOverride)

        Decidim::Organization.include(Decidim::Geo::OrganizationGeoExtensions)

        # Override Taxonomy model to include Shapedata
        Decidim::Taxonomy.include(Decidim::Geo::TaxonomyOverride)

        # Setup registry
        registry = Decidim::Geo::ManifestRegistry.instance
        if Decidim.const_defined?("Meetings")
          registry.register(
            :meetings,
            time_filter: Decidim::Geo::Api::DefaultFilter,
            model: Decidim::Meetings::Meeting,
            updater: Decidim::Geo::UpdateMeetingGeoIndexJob
          )
          Decidim::Meetings::Meeting.include(Decidim::Geo::UpdateGeoIndex)
        end

        if Decidim.const_defined?("Assembly")
          registry.register(
            :assemblies,
            time_filter: Decidim::Geo::Api::DefaultFilter,
            model: Decidim::Assembly,
            updater: Decidim::Geo::UpdateAssemblyGeoIndexJob
          )
          Decidim::Assembly.include(Decidim::Geo::UpdateGeoIndex)
        end

        if Decidim.const_defined?("ParticipatoryProcess")
          registry.register(
            :participatory_processes,
            time_filter: Decidim::Geo::Api::DefaultFilter,
            model: Decidim::ParticipatoryProcess,
            updater: Decidim::Geo::UpdateProcessGeoIndexJob
          )
          Decidim::ParticipatoryProcess.include(Decidim::Geo::UpdateGeoIndex)
        end
        if Decidim.const_defined?("Proposals")
          registry.register(
            :proposals,
            time_filter: Decidim::Geo::Api::ProposalFilter,
            model: Decidim::Proposals::Proposal,
            updater: Decidim::Geo::UpdateProposalGeoIndexJob
          )
          Decidim::Proposals::Proposal.include(Decidim::Geo::UpdateGeoIndex)
        end
        if Decidim.const_defined?("ReportingProposals")
          registry.register(
            :reporting_proposals,
            time_filter: Decidim::Geo::Api::ProposalFilter,
            model: Decidim::Proposals::Proposal,
            updater: Decidim::Geo::UpdateProposalGeoIndexJob
          )
          Decidim::Proposals::Proposal.include(Decidim::Geo::UpdateGeoIndex)
        end
        if Decidim.const_defined?("Debates")
          registry.register(
            :debates,
            time_filter: Decidim::Geo::Api::DefaultFilter,
            model: Decidim::Debates::Debate,
            updater: Decidim::Geo::UpdateDebateGeoIndexJob
          )
          Decidim::Debates::Debate.include(Decidim::Geo::UpdateGeoIndex)
        end
        if Decidim.const_defined?("Accountability")
          registry.register(
            :accountability,
            time_filter: Decidim::Geo::Api::DefaultFilter,
            model: Decidim::Accountability::Result,
            updater: Decidim::Geo::UpdateAccountabilityGeoIndexJob
          )
          Decidim::Accountability::Result.include(Decidim::Geo::UpdateGeoIndex)
        end
        # By default, enable all registered manifests
        registry.enable(*registry.registered_manifests)
      end

      initializer "decidim_geo.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Geo::Engine, at: "/", as: "decidim_geo"
        end
      end

      initializer "decidim_geo.content_blocks" do
        Decidim.content_blocks.register(:homepage, :geo_maps) do |content_block|
          content_block.cell = "decidim/geo/content_blocks/geo_maps"
          content_block.public_name_key = "decidim.geo.content_blocks.name"
        end
        Decidim.content_blocks.register(:participatory_process_group_homepage, :group_geo_maps) do |content_block|
          content_block.cell = "decidim/geo/content_blocks/group_geo_maps"
          content_block.public_name_key = "decidim.geo.content_blocks.name"
        end
        Decidim.content_blocks.register(:assembly_homepage, :space_geo_maps) do |content_block|
          content_block.cell = "decidim/geo/content_blocks/space_geo_maps"
          content_block.public_name_key = "decidim.geo.content_blocks.name"
        end
        Decidim.content_blocks.register(:participatory_process_homepage, :space_geo_maps) do |content_block|
          content_block.cell = "decidim/geo/content_blocks/space_geo_maps"
          content_block.public_name_key = "decidim.geo.content_blocks.name"
        end
      end

      initializer "add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Geo::Engine.root}/app/cells")
      end

      initializer "decidim_geo.check_rgeo" do
        Rails.logger.warn("GEOS is not available, but is required for correct interpretation of polygons in shapefiles") unless RGeo::Geos.supported?
      end

      initializer "decidim_geo.configure_rgeo" do
        RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
          config.default = RGeo::Geos.factory
          config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: "point")
        end
      end

      initializer "decidim_geo.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("#{Decidim::Geo::Engine.root}/app/packs")
      end

      initializer "decidim_geo.assets.icons" do |_app|
        Decidim.icons.register(name: "map", icon: "map-2-fill", category: "system", description: "", engine: :core)
      end

      initializer "decidim_geo.organization_settings_tab",
                  after: "decidim_toggle.organization_settings_tabs" do
        Decidim::Toggle.settings_tabs :organization_settings do |tabs|
          tabs.add_tab :decidim_geo,
                       I18n.t("decidim_toggle.system.#{Decidim::Geo::MODULE_NAME}.tab"),
                       form: Decidim::Geo::Admin::OrganizationConfigForm,
                       command: Decidim::Toggle::UpdateModuleConfigCommand,
                       module_name: Decidim::Geo::MODULE_NAME,
                       position: 15
        end
      end
    end
  end
end
