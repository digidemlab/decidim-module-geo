# frozen_string_literal: true

module Decidim
  module Geo
    class PointsController < ::Decidim::Api::ApplicationController
      before_action :set_default_format
      before_action :ensure_geo_search_enabled, only: :search_title

      def count
        render json: { count: query.count }
      end

      def search_title
        render json: { data: query.select("title") }
      end

      def index
        last_modified = query.maximum(:updated_at) || 1.year.from_now
        etag = "#{query.cache_key_with_version}/params-#{Digest::MD5.hexdigest(permitted_params.to_json)}"

        return unless stale?(last_modified: last_modified.utc, etag:)

        results = query.select(permitted_fields_params)
                       .offset(offset_params)
                       .limit(first_params)

        geo_taxonomy_ids = query.select(:geo_taxonomy_id).group(:geo_taxonomy_id, :start_date, :id).pluck(:geo_taxonomy_id).compact
        render json: {
          meta: {
            fields: permitted_fields_params,
            filters: filters_params,
            organization: current_organization.id,
            default_locale: current_organization.default_locale,
            first: first_params,
            offset: offset_params,
            has_more: results.count != 0,
            geo_taxonomy_ids: geo_taxonomy_ids || []
          },
          data: results
        }
      end

      private

      def permitted_params
        @permitted_params ||= params.permit(:first, :offset, :locale, :is_index, :format, fields: [], filters: [])
      end

      def first_params
        @first_params ||= (permitted_params[:first] || "50").to_i
      end

      def offset_params
        @offset_params ||= (permitted_params[:offset] || "0").to_i
      end

      def query
        @query ||= ::Decidim::Geo::Api::GeoQuery.new(
          current_organization,
          current_user,
          {
            filters: filters_params,
            is_index: index?
          },
          locale_param
        ).results
      end

      def index?
        @index ||= !!permitted_params[:is_index]
      end

      def locale_param
        @locale_param ||= permitted_params[:locale] || I18n.default_locale
      end

      def filters_params
        @filters_params ||= (permitted_params[:filters] || []).map { |f| JSON.parse(f).with_indifferent_access }
      end

      def fields_params
        @fields_params ||= permitted_params[:fields] || []
      end

      def include_lonlat?
        fields_params.include? "lonlat"
      end

      def permitted_fields_params
        @permitted_fields_params ||= begin
          allowed_fields = %w(
            resourceUrl
            resourceId
            resourceStatus
            participatorySpaceId
            participatorySpaceType
            componentId
            resourceType
            startDate
            endDate
            title
            shortDescription
            descriptionHtml
            imageUrl
            lonlat
            geoTaxonomyId
            extendedData
            lonlat
          )

          filtered_fields = fields_params.select { |field| allowed_fields.include?(field.to_s) }
          filtered_fields.push("id")
          filtered_fields.map(&:underscore)
        end
      end

      def set_default_format
        request.format = :json
      end

      def ensure_geo_search_enabled
        head :not_found unless current_organization.geo_search_enabled?
      end
    end
  end
end
