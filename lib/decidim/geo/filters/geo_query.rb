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
          query = scoped_time!(query)
          search_title(query)
        end

        private

        def show_children_points
          Decidim.participatory_space_registry.manifests.map { |manifest| manifest.name.to_s }

          actives_first = <<~SQL
            CASE
              -- 1. Future
              WHEN start_date >= (CURRENT_DATE + INTERVAL '15 days')
              THEN 1

              -- 2. Active/Future, between today and 15 days
              WHEN start_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '15 days')
              AND  end_date   > (CURRENT_DATE + INTERVAL '15 days')
              THEN 2

              -- 3. Active, start in past < 15 days finish today or in future
              WHEN start_date <= CURRENT_DATE
              AND  end_date   >= CURRENT_DATE
              THEN 3

              -- 4. Active/Past, start in past > 15 days
              WHEN start_date < CURRENT_DATE
              AND  end_date   BETWEEN (CURRENT_DATE - INTERVAL '15 days') AND CURRENT_DATE
              THEN 4

              -- 5. Past, starts and ends > 15 days
              WHEN end_date   <= (CURRENT_DATE - INTERVAL '15 days')
              THEN 5

              ELSE 6
            END ASC
          SQL

          Decidim::Geo::Index.where(decidim_organization_id: organization.id)
                             .order(
                               Arel.sql(actives_first),
                               start_date: :desc,
                               end_date: :desc,
                               id: :desc
                             )
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
          return query.where(geo_taxonomy_id: taxonomy_ids_params) unless taxonomy_ids_params.empty?

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

        def search_title(query)
          return query if search_title_params.nil?

          search_term = search_title_params[:search_filter][:title]
          query.where("(title ->> ? ILIKE ?) OR (title ->> ? ILIKE ?)",
                      locale, "%#{search_term}%",
                      default_locale, "%#{search_term}%")
        end

        def search_title_params
          graphql_params.find { |f| f[:search_filter].present? }
        end

        def default_locale
          organization.default_locale
        end

        def config
          @config ||= Decidim::Geo::GeoConfig.geo_config_default(organization)
        end

        def active_manifests_names
          @active_manifests_names ||= ::Decidim::Geo.registry.active_manifests(&:keys)
        end

        def normalize_graphql_params(graphql_params)
          return unless graphql_params

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

        def taxonomy_ids_params
          @taxonomy_ids_params ||= graphql_params.select { |f| f[:taxonomy_filter].present? }.map do |graphql_param|
            graphql_param[:taxonomy_filter][:taxonomy_id]
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
