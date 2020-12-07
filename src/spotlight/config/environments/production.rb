Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true
  config.active_job.queue_adapter = :inline

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  # host = ENV['SPOTLIGHT_HOST']
  # config.action_mailer.default_url_options = { :host => ENV['SPOTLIGHT_HOST'], protocol: 'http'}
  config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_caching = false
  # config.action_mailer.smtp_settings = {
  #   address:              'inbound.mail.utexas.edu',
  #   port:                 25,
  #   domain:               ENV['SPOTLIGHT_HOST'],
  #   from:                 ENV['MAIL_FROM'],
  #   }
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    enable_starttls_auto: true,
    port:                 587,
    authentication:       :login,
    domain:               ENV['SPOTLIGHT_HOST'],
    user_name:            ENV['MAIL_USERNAME'],
    password:             ENV['MAIL_PASSWORD'],
    from:                 ENV['MAIL_FROM'],
    }


  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "new-spotlight-test_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
