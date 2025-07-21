# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim_geo do
  desc "Destroy and rebuild the index"
  task rebuild_index: :environment do
    Decidim::Geo::Index.destroy_all
    # For each component, update decidim index
    Decidim::Component.all.each do |model|
      model.decidim_geo_avoid_index ||= Decidim::Geo::NoIndex.new
      model.save
      model.update_decidim_geo_index
    end

    # For each model attached to component, update decidim index as well
    models = Decidim::Geo::ManifestRegistry.instance.active_manifests { |manifests| manifests.map { |_name, config| config[:model] } }
    models.each do |model_klass|
      Rails.logger.debug { "index class #{model_klass} " }
      model_klass.all.each(&:update_decidim_geo_index)
    end

    # Clear cache completly
    Rails.cache.clear
  end
end
