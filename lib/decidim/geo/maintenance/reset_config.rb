# frozen_string_literal: true

module Decidim
  module Geo
    module Maintenance
      # Clears geo map configuration: shapedatas, shapefiles, and scope/taxonomy links.
      class ResetConfig
        def initialize(dry_run: true)
          @dry_run = dry_run
          @result = Hash.new(0)
        end

        attr_reader :dry_run, :result

        def run!
          log "Resetting decidim-geo config#{dry_run ? ' (DRY RUN)' : ''}"

          clear_geo_config_shapefile_links!
          delete_shapedatas!
          delete_shapefiles!
          clear_index_taxonomy_links!
          clear_index_scope_links!

          clear_cache unless dry_run
          log "Done. #{result_summary}"
          result
        end

        private

        def clear_geo_config_shapefile_links!
          return unless table_exists?(:decidim_geo_configs)
          return unless column_exists?(:decidim_geo_configs, :decidim_geo_shapefiles_id)

          scope = Decidim::Geo::GeoConfig.where.not(decidim_geo_shapefiles_id: nil)
          count = scope.count
          log "  decidim_geo_configs shapefile links: #{count}"
          return if dry_run || count.zero?

          scope.update_all(decidim_geo_shapefiles_id: nil)
          result[:geo_config_shapefile_links] += count
        end

        def delete_shapedatas!
          return unless table_exists?(:decidim_geo_shapefile_datas)

          count = Decidim::Geo::Shapedata.count
          log "  decidim_geo_shapefile_datas: #{count} rows"
          return if dry_run || count.zero?

          Decidim::Geo::Shapedata.delete_all
          result[:decidim_geo_shapefile_datas] += count
        end

        def delete_shapefiles!
          return unless table_exists?(:decidim_geo_shapefiles)

          scope = Decidim::Geo::Shapefile.all
          count = scope.count
          log "  decidim_geo_shapefiles: #{count} rows"
          return if dry_run || count.zero?

          scope.find_each do |shapefile|
            shapefile.shapefile.purge if shapefile.shapefile.attached?
            shapefile.destroy!
            result[:decidim_geo_shapefiles] += 1
          end
        end

        def clear_index_taxonomy_links!
          return unless table_exists?(:decidim_geo_indexes)
          return unless column_exists?(:decidim_geo_indexes, :geo_taxonomy_id)

          scope = Decidim::Geo::Index.where.not(geo_taxonomy_id: nil)
          count = scope.count
          log "  decidim_geo_indexes taxonomy links: #{count}"
          return if dry_run || count.zero?

          scope.update_all(geo_taxonomy_id: nil)
          result[:geo_index_taxonomy_links] += count
        end

        def clear_index_scope_links!
          return unless table_exists?(:decidim_geo_indexes)
          return unless column_exists?(:decidim_geo_indexes, :geo_scope_id)

          scope = Decidim::Geo::Index.where.not(geo_scope_id: nil)
          count = scope.count
          log "  decidim_geo_indexes scope links: #{count}"
          return if dry_run || count.zero?

          scope.update_all(geo_scope_id: nil)
          result[:geo_index_scope_links] += count
        end

        def table_exists?(table)
          ActiveRecord::Base.connection.table_exists?(table)
        end

        def column_exists?(table, column)
          ActiveRecord::Base.connection.column_exists?(table, column)
        end

        def clear_cache
          Rails.cache.clear if defined?(Rails.cache)
        end

        def result_summary
          result.map { |key, count| "#{key}=#{count}" }.join(", ")
        end

        def log(message)
          $stdout.puts(message)
        end
      end
    end
  end
end
