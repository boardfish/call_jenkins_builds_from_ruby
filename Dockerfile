FROM ruby:2.5-alpine
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  && rm -rf /var/cache/apk/*
COPY Gemfile /
COPY jenkins_api_caller_spec.rb /
COPY jenkins_api_caller.rb /
COPY seed_script.rb /
RUN bundle config build.nokogiri --use-system-libraries && bundle install