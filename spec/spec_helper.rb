# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["ENGINE_ROOT"] = File.dirname(__dir__)

require "decidim/dev"

Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.around do |example|
    I18n.with_locale(:en) { example.run }
  end

  config.include Warden::Test::Helpers, type: :controller
  config.include Warden::Test::Helpers, type: :request

  config.after do
    Warden.test_reset!
  end
end
