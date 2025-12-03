# frozen_string_literal: true

module Decidim
  module Geo
    module Api
      class GeoQuery
        attr_reader :locale, :graphql_params, :organization, :current_user, :params

        delegate :count, to: :results, prefix: true

        def initialize(organization, current_user, params, locale)
          @locale = locale || I18n.locale
          @params = params
          @graphql_params = normalize_graphql_params(params[:filters]) || {}
          @organization = organization
          @current_user = current_user
        end

        def results
          query = show_children_points
          query = query.geolocated if geolocated? || config.force_geoencoded?
          query = indexed!(query)
          query = virtual!(query)
          query = scoped!(query)
          query = scoped_participatory_space!(query, :participatory_processes, process_params)
          query = scoped_participatory_space!(query, :assemblies, assembly_params)
          query = scoped_resource_type!(query)
          scoped_time!(query)
        end

        private

        def show_children_points
          types = Decidim.participatory_space_registry.manifests.map { |manifest| manifest.name.to_s }

          if show_children_points? && show_children_points_params.first == "all"
            return Decidim::Geo::Index.where("decidim_organization_id = :org OR resource_type NOT IN (:types)", org: organization.id,
                                                                                                                types:)
          end

          return Decidim::Geo::Index.where.not(decidim_organization_id: organization.id) if show_children_points? && show_children_points_params == ["children_only"]

          Decidim::Geo::Index.where(decidim_organization_id: organization.id)
        end

        def show_children_points?
          organization.space_page_settings_attributes["show_children_points"]
        end

        def active_time_filter
          @active_time_filter ||= time_filter_params && time_filter_params[:time_filter][:time]
        end

        def computed_time_filters(query)
          return [] unless active_time_filter && active_time_filter != "all"

          resource_type_params.map do |manifest|
            time_filter_class = ::Decidim::Geo.registry.time_filter_for(manifest)
            filter = time_filter_class.new(self, manifest)
            case active_time_filter
            when "active"
              filter.filter_active(query)
            when "past"
              filter.filter_past(query)
            when "future"
              filter.filter_future(query)
            else
              raise "Unkown time filter #{active_time_filter}"
            end
          end
        end

        def indexed!(query)
          return query.indexed if only_indexed?

          participatory_where_clause = if process_params.any?
                                         { participatory_space_id: process_params }
                                       else
                                         {}
                                       end
          query.where(participatory_where_clause)
        end

        def virtual!(query)
          return query.virtual if virtual?

          query
        end

        def scoped!(query)
          return query.where(geo_scope_id: scope_ids_params) unless scope_ids_params.empty?

          query
        end

        def scoped_participatory_space!(query, type, space_params)
          return query.where(participatory_space_type: type, participatory_space_id: space_params) if space_params.any?

          query
        end

        def scoped_resource_type!(query)
          return query.where(resource_type: resource_type_params) unless resource_type_params.empty? || resource_type_params.first == "all"

          query
        end

        def scoped_time!(query)
          computed_filters = computed_time_filters(query)
          return query if computed_filters.empty?

          time_filter_chain = computed_filters.pop
          computed_filters.each do |or_time_filter|
            time_filter_chain = time_filter_chain.or(or_time_filter)
          end
          time_filter_chain
        end

        def config
          @config ||= Decidim::Geo::GeoConfig.geo_config_default(organization)
        end

        def active_manifests_names
          @active_manifests_names ||= ::Decidim::Geo.registry.active_manifests(&:keys)
        end

        def normalize_graphql_params(graphql_params)
          graphql_params.map do |hash|
            next hash unless hash.is_a?(Hash)

            hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
                .deep_transform_values { |value| value.is_a?(Hash) ? value.with_indifferent_access : value }
                .with_indifferent_access
          end
        end

        def time_filter_params
          graphql_params.find { |f| f[:time_filter].present? }
        end

        def only_indexed?
          params.has_key?(:is_index) && params[:is_index]
        end

        def assembly_groups?
          assembly_params.size > 1
        end

        def assembly_params
          @assembly_params ||= graphql_params.select { |f| f[:assembly_filter].present? }.map do |graphql_param|
            graphql_param[:assembly_filter][:id].to_i
          end
        end

        def resource_type_params
          @resource_type_params ||= begin
            resource_types = graphql_params
                             .select { |f| f.has_key?("resource_type_filter") }
                             .map { |f| f["resource_type_filter"]["resource_type"] }

            if resource_types
              if resource_types.include?("all")
                active_manifests_names
              else
                resource_types
              end
            else
              active_manifests_names
            end
          end
        end

        def process_params
          @process_params ||= graphql_params.select { |f| f[:process_filter].present? }.map do |graphql_param|
            graphql_param[:process_filter][:id].to_i
          end
        end

        def geolocated?
          geolocated_params &&
            geolocated_params[:geoencoded_filter] &&
            geolocated_params[:geoencoded_filter][:geoencoded]
        end

        def virtual?
          geolocated_params &&
            geolocated_params[:geoencoded_filter] &&
            !geolocated_params[:geoencoded_filter][:geoencoded]
        end

        def geolocated_params
          graphql_params.find { |f| f[:geoencoded_filter].present? }
        end

        def scope_ids_params
          @scope_ids_params ||= graphql_params.select { |f| f[:scope_filter].present? }.map do |graphql_param|
            graphql_param[:scope_filter][:scope_id]
          end
        end

        def show_children_points_params
          @show_children_points_param ||= graphql_params.select { |f| f[:source_filter].present? }.map do |graphql_param|
            graphql_param[:source_filter][:source]
          end
        end

        def time_filters
          @time_filters ||= ::Decidim::Geo.registry.active_manifests do |manifests|
            manifests.map { |config| config.last[:time_filter].new(self, config.first) }
          end
        end

        def spaces_time_filter
          @spaces_time_filter ||= time_filters.select(&:participatory_space?)
        end

        def components_time_filter
          @components_time_filter ||= time_filters.select(&:component?)
        end
      end
    end
  end
end
