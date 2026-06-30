# frozen_string_literal: true

module Decidim
  module Geo
    module UpdateGeoIndex
      extend ActiveSupport::Concern

      included do
        after_commit :update_decidim_geo_index

        def update_decidim_geo_index
          unless decidim_geo_enabled?
            Rails.logger.debug { "Decidim Geo is disabled. Skipping update for #{self.class.name}##{id}" }
            return
          end
          registry = Decidim::Geo::ManifestRegistry.instance
          updater = registry.updater_for(decidim_geo_manifest)
          raise "Internal error: no updater registred for #{decidim_geo_manifest}" unless updater

          model = registry.model_for(decidim_geo_manifest)
          resource = model.where(id: id).first

          updater.process(resource)
        end

        private

        def decidim_geo_manifest
          @decidim_geo_manifest ||= if self.class.include? Decidim::HasComponent
                                      # It's a resource
                                      component.manifest.name if component && component.manifest
                                    elsif instance_of?(Decidim::Component) || self.class.include?(Decidim::ScopableParticipatorySpace)
                                      # It's a component or a participatory space
                                      manifest.name if manifest
                                    end
        end

        def decidim_geo_enabled?
          return false unless decidim_geo_manifest
          return false unless decidim_geo_organization&.geo_enabled?

          Decidim::Geo::ManifestRegistry.instance.enabled?(decidim_geo_manifest)
        end

        def decidim_geo_organization
          @decidim_geo_organization ||= organization_from_record ||
                                        organization_from_component ||
                                        organization_from_participatory_space
        end

        def organization_from_record
          organization if respond_to?(:organization) && organization.present?
        end

        def organization_from_component
          component.organization if respond_to?(:component) && component&.organization
        end

        def organization_from_participatory_space
          participatory_space.organization if respond_to?(:participatory_space) && participatory_space&.organization
        end
      end
    end
  end
end
