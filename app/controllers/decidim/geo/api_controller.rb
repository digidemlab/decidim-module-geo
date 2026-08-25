# frozen_string_literal: true

module Decidim
  module Geo
    class ApiController < ::Decidim::Api::ApplicationController
      def allow_browser(**); end
    end
  end
end
