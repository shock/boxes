FROM ruby:2.6.6

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY vendor /app/vendor
RUN bundle install --without development test
COPY bin /app/bin
COPY public /app/public
COPY lib /app/lib
COPY db /app/db
COPY config /app/config
COPY app /app/app

CMD ["sh", "-c", "rm -f /app/tmp/pids/server.pid && /app/bin/rails server -b 0.0.0.0"]
