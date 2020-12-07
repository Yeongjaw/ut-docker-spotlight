# frozen_string_literal: true

require 'bundler'

DEFAULT_BLACKLIGHT_OPTIONS = '--devise'
DEFAULT_SPOTLIGHT_OPTIONS = '-f --devise --quiet --openseadragon --mailer_default_url_host=localhost:3000'
blacklight_options = ENV.fetch('BLACKLIGHT_INSTALL_OPTIONS', DEFAULT_BLACKLIGHT_OPTIONS)
spotlight_options = ENV.fetch('SPOTLIGHT_INSTALL_OPTIONS', DEFAULT_SPOTLIGHT_OPTIONS)

# Add gem dependencies to the application
gem 'blacklight', '~> 7.10.0'
gem 'blacklight-spotlight', '3.0.0.rc2'
# gem 'blacklight-gallery', '>= 0.3.0'
# gem 'blacklight-oembed', '~> 0.3'
# gem 'devise'
# gem 'devise_invitable'
gem 'devise_saml_authenticatable'

Bundler.with_clean_env do
  run 'bundle install'
end

# run the blacklight install generator
generate 'blacklight:install', blacklight_options

# run the spotlight installer
generate 'spotlight:install', spotlight_options
rake 'spotlight:install:migrations'

# Handle devise
generate 'devise:install', '-f'
generate 'devise_invitable:install', '-f'

# create an initial administrator (if we are running interactively..)
# if !options['quiet'] && yes?('Would you like to create an initial administrator?')
  rake 'db:migrate' # we only need to run the migrations if we are creating an admin user
#  rake 'spotlight:initialize'
#end
