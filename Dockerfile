# get official nodejs/npm binaries
FROM node:24.7-alpine AS nodebuilder
WORKDIR /opt/app
COPY package-lock.json ./
COPY package.json ./
RUN npm i

# bundle install the gems for production
FROM ruby:3.4.5-alpine AS rubybuilder
RUN apk update && apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    nodejs \
    yarn \
    gcompat \
    yaml-dev \
    libstdc++

WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install

# copy required files from base images, precompile assets & cleanup
FROM ruby:3.4.5-alpine

WORKDIR /opt/app
RUN apk add --no-cache \
    gcompat \
    tzdata \
    nodejs \
    yarn \
    libstdc++ \
    && adduser -D -s /bin/sh app

COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules

USER app
COPY --chown=app . ./
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]
