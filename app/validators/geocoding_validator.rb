# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# an existing address and computes its coordinates.
class GeocodingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    organization = record.respond_to?(:organization) ? record.organization : record.component.organization
    if Decidim::Map.available?(:geocoding)
      geocoder = geocoder_for(organization)
      coordinates = geocoder.coordinates(value)

      if coordinates.present?
        record.latitude = coordinates.first
        record.longitude = coordinates.last
      else
        record.errors.add(attribute, :invalid)
      end
    else
      record.errors.add(attribute, :invalid)
    end
  end

  private

  def geocoder_for(organization)
    Decidim::Map.geocoding(organization:)
  end
end
