require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CalRailsVueApp
  class Application < Rails::Application
    config.middleware.use ActionDispatch::Cookies
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Add the following to Japanese.
    config.i18n.default_locale = :ja
    # If you want to change the time zone, add the following.
    config.time_zone = 'Asia/Tokyo'
    config.assets.initialize_on_precompile = false
  end
end
