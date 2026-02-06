FROM ruby:2.6.6

RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY vendor /app/vendor
RUN bundle install --without development test
COPY Rakefile /app/Rakefile
COPY bin /app/bin
COPY public /app/public
COPY lib /app/lib
COPY db /app/db
COPY config /app/config
COPY config.ru /app/config.ru
COPY app /app/app

RUN RAILS_ENV=production bundle exec rake assets:precompile

CMD ["sh", "-c", "rm -f /app/tmp/pids/server.pid && /app/bin/rails server -b 0.0.0.0"]
