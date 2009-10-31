env = ENV['RAILS_ENV'] || RAILS_ENV
EXCEPTION_NOTIFIER = YAML.load_file(RAILS_ROOT + '/config/exception.yml')[env]
ExceptionNotifier.exception_recipients = EXCEPTION_NOTIFIER['recipients']
ExceptionNotifier.sender_address = EXCEPTION_NOTIFIER['sender']
ExceptionNotifier.email_prefix = EXCEPTION_NOTIFIER['prefix']
