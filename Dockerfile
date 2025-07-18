
FROM hfroger/decidim:0.29 AS bundler
COPY . /home/decidim_module_geo
USER root
RUN cd /home/decidim \
    && bundle config set path "vendor" \
    && bundle config set without "" \
    && bundle config unset frozen \
    && bundle config unset deployment \
    # Add decidim-geo gem with a local path (bounded as volume)
    && echo "" >> Gemfile.modules \
    && echo "# DECIDIM GEO" >> Gemfile.modules \
    && echo "gem \"decidim-decidim_geo\", path: \"../decidim_module_geo\"" >> Gemfile.modules \
    && echo "gem \"deface\",  \">= 1.8.1\"" >> Gemfile.modules \
    && bundle install
    
FROM hfroger/decidim:0.29
ENV NODE_ENV=development \
    RAILS_ENV=development \
    BUNDLE_WITHOUT=""
# Add locally the current rep in module, 
# This will be bound as volume later.
COPY . /home/decidim_module_geo
# Add app configuration for working in dev.
COPY ./.docker/config /home/decidim/app/config
COPY ./.docker/ecosystem.config.js /home/decidim/app/ecosystem.config.js
COPY ./.docker/ecosystem.config.js /usr/local/share/docker-entrypoint.d/ecosystem.config.js

USER root

RUN bundle config set path "vendor" \
    && bundle config set without "" \
    && bundle config unset frozen \
    && bundle config unset deployment \
    && apt-get update \
    && apt-get install -yq libgeos-dev \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /usr/local/bundle/cache \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc /usr/share/man \
    && for x in `gem list --no-versions`; do gem uninstall $x -a -x -I; done \
    && npm i -g pm2

COPY --from=bundler /home/decidim/Gemfile /home/decidim/Gemfile
COPY --from=bundler /home/decidim/Gemfile.lock /home/decidim/Gemfile.lock
COPY --from=bundler /home/decidim/Gemfile.modules /home/decidim/Gemfile.modules
COPY --from=bundler /home/decidim/vendor /home/decidim/vendor
WORKDIR /home/decidim_module_geo
EXPOSE 3000
EXPOSE 3035
CMD ["sleep", "infinity"]