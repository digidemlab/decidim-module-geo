# frozen_string_literal: true

source "https://rubygems.org"

RUBY_VERSION = ">= 3.3"

ruby RUBY_VERSION

DECIDIM_VERSION = "~> 0.31"

base_path = "./"
base_path = "../../" if File.basename(__dir__) == "decidim_dummy_app"
base_path = "../" if File.basename(__dir__) == "development_app"

require_relative "#{base_path}lib/decidim/geo/version"

gem "decidim", DECIDIM_VERSION

gem "decidim-toggle",
    git: "https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle",
    tag: "v0.1.1"

gem "decidim-decidim_geo", path: base_path

gem "bootsnap", "~> 1.18"

gem "deface",
    git: "https://github.com/froger/deface",
    branch: "fix/js-overrides"

gem "puma", ">= 6.6"
gem "uglifier", "~> 4.2"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
end

group :test do
  gem "capybara", "~> 3.40"
  gem "csv"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop-faker"
  gem "selenium-webdriver"
end

group :development do
  gem "faker", "~> 3.5"
  gem "letter_opener_web", "~> 3.0"
  gem "listen", "~> 3.9"
  gem "web-console", "~> 4.2"
end

gem "activerecord-postgis-adapter"
gem "rgeo", "~> 3.0"
gem "rgeo-geojson", ">= 2.2"
gem "rgeo-shapefile", ">= 3.1"
