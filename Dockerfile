FROM ruby:2.5-alpine
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  && rm -rf /var/cache/apk/*
COPY Gemfile /
RUN bundle config build.nokogiri --use-system-libraries && bundle install