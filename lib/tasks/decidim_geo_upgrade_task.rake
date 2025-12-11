# frozen_string_literal: true

# Hook into the main Decidim tasks so this module is installed alongside the
# core assets and migrations.
if Rake::Task.task_defined?("decidim:shakapacker:install")
  Rake::Task["decidim:shakapacker:install"].enhance do
    Rake::Task["decidim_geo:webpacker:install"].invoke if Rake::Task.task_defined?("decidim_geo:webpacker:install")
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_geo" unless ENV["FROM"].to_s.include?("decidim_geo")
end
Rake::Task["decidim:upgrade"].enhance do
  Rake::Task["decidim_geo:install:migrations"].invoke if Rake::Task.task_defined?("decidim_geo:install:migrations")
end
