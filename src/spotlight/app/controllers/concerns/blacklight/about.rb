# frozen_string_literal: true
module Blacklight
  module About
    extend ActiveSupport::Concern
    include Blacklight::Configurable

    included do
      copy_blacklight_config_from(CatalogController)
    end

  end
end
