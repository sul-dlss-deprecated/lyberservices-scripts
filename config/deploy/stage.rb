server 'sul-lyberservices-test.stanford.edu', user: 'scripts', roles: %w{web app db}

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "test"

set :honeybadger_env, 'lyberservices-test'
