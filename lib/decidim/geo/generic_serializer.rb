# frozen_string_literal: true

module Decidim
  module Geo
    module GenericSerializer
      extend ActiveSupport::Concern

      included do
        attr_accessor :resource
        attr_accessor :resource_id

        def taxonomy
          @taxonomy ||= if resource.respond_to?(:component)
                          taxonomy_for_resource
                        elsif resource.instance_of?(Decidim::Component)
                          taxonomy_for_component
                        elsif resource.class.participatory_space?
                          taxonomy_for_participatory_space
                        end
        end

        def image_url
          @image_url ||= if resource.respond_to?(:hero_image)
                           resource.attached_uploader(:hero_image).url(only_path: true)
                         elsif resource.respond_to?(:attachments) && resource.attachments.any?(&:photo?)
                           Rails.application.routes.url_helpers.rails_blob_url(
                             resource.attachments.select(&:photo?).first&.file&.attachment,
                             only_path: true
                           )
                         end
        end

        def start_date
          if manifest_name == "proposals"
            space = resource.participatory_space
            space.manifest.name.to_s
            return resource.participatory_space.included_at if space.manifest.name.to_s == "assemblies" &&
                                                               space.included_at?
            return space.start_date if space.manifest.name.to_s == "participatory_processes"
          end

          return resource.start_time if manifest_name == "meetings"

          return resource.included_at if manifest_name == "assemblies" && resource.included_at?

          resource.start_date if %w(participatory_processes accountability).include?(manifest_name)
        end

        def start_time
          resource.start_time if manifest_name == "debates"
        end

        def end_date
          return proposal_end_date if manifest_name == "proposals"

          return resource.end_time if manifest_name == "meetings"

          return resource.closed_at if manifest_name == "debates" && resource.closed_at?

          return resource.closing_date if manifest_name == "assemblies" && resource.closing_date?

          return resource.end_date if manifest_name == "participatory_processes"

          resource.end_date if manifest_name == "accountability"
        end

        def proposal_end_date
          space = resource.participatory_space
          space.manifest.name.to_s
          return resource.participatory_space.closing_date if space.manifest.name.to_s == "assemblies" &&
                                                              space.closing_date?

          space.end_date if space.respond_to?(:end_date)
        end

        def end_time
          resource.end_time if manifest_name == "debates"
        end

        def resource_id
          @resource_id ||= resource.id
        end

        def resource_url
          @resource_url ||= Decidim::ResourceLocatorPresenter.new(resource).path
        end

        def title
          @title ||= if resource.respond_to?(:title)
                       resource.title
                     elsif resource.respond_to?(:name)
                       resource.name
                     end
        end

        def short_description
          if resource.respond_to?(:short_description)
            truncate_translated(resource.short_description, 250)
          elsif resource.respond_to?(:body)
            truncate_translated(resource.body, 250)
          elsif resource.respond_to?(:description)
            truncate_translated(resource.description, 250)
          end
        end

        def description
          @description ||= if resource.respond_to?(:body)
                             truncate_translated(resource.body, keep_html: true)
                           elsif resource.respond_to?(:description)
                             truncate_translated(resource.description, keep_html: true)
                           end
        end

        def resource_status
          return unless resource.respond_to?("withdrawn?")
          return "withdrawn" if resource.withdrawn?

          resource.proposal_state&.token if manifest_name == "proposals"
        end

        def component_id
          resource.decidim_component_id if %w(proposals meetings debates accountability).include?(manifest_name)
        end

        def participatory_space_id
          return resource.participatory_space.id if %w(proposals meetings debates accountability).include?(manifest_name)

          resource.id if %w(participatory_processes assemblies).include?(manifest_name)
        end

        def participatory_space_type
          resource.participatory_space.manifest.name.to_s if %w(proposals meetings debates accountability).include?(manifest_name)
        end

        def latitude
          @latitude ||= if location_overriden?
                          location.latitude if location && location.latitude
                        else
                          resource.latitude
                        end
        end

        def longitude
          @longitude ||= if location_overriden?
                           location.longitude if location && location.longitude
                         else
                           resource.longitude
                         end
        end

        def location
          @location ||= resource.decidim_geo_space_location
        end

        def location_overriden?
          @location_overriden ||= resource.respond_to?(:decidim_geo_space_location)
        end

        private

        def truncate_translated(value_param, chars = 1000, **options)
          sanitizer = options[:keep_html] ? Rails::Html::SafeListSanitizer.new : Rails::Html::FullSanitizer.new
          value = value_param.deep_dup
          value.each do |key, v|
            value[key] = if v.is_a?(Hash)
                           truncate_translated(v, chars, **options)
                         else
                           sanitizer.sanitize(
                             Decidim::HtmlTruncation.new(
                               Decidim::ContentProcessor.render(
                                 v
                               ),
                               max_length: chars,
                               tail: "…",
                               count_tags: false,
                               count_tail: false,
                               tail_before_final_tag: false
                             ).perform
                           )
                         end
          end
          value
        end

        def taxonomy_for_resource
          @taxonomy_for_resource ||= resource.taxonomies.select { |t| t.shapedata.present? }
        end

        def taxonomy_for_component(component = nil)
          component ||= resource

          @taxonomy_for_component ||= component.taxonomies.select { |t| t.shapedata.present? }
        end

        def taxonomy_for_participatory_space(space = nil)
          space ||= resource

          return unless space && space.taxonomies

          @taxonomy_for_participatory_space ||= space.taxonomies.select { |t| t.shapedata.present? }
        end
      end
    end
  end
end
