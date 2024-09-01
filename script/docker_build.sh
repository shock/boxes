#1/bin/bash

RAILS_ENV=production bundle exec rake assets:precompile
docker build -t boxes4_ruby_2_6_6 .