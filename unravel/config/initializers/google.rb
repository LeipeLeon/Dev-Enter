env = ENV['RAILS_ENV'] || RAILS_ENV
GOOGLE_KEYS = YAML.load_file(RAILS_ROOT + '/config/google.yml')[env]
