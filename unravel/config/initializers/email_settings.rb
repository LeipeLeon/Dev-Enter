env = ENV['RAILS_ENV'] || RAILS_ENV
EMAIL = YAML.load_file(RAILS_ROOT + '/config/email_settings.yml')[env]
