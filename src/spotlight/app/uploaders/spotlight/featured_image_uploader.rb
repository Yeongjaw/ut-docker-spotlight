# frozen_string_literal: true

module Spotlight
  ##
  # Page, browse category, and exhibit featured image thumbnails
  class FeaturedImageUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    after :remove, :delete_empty_upstream_dirs # Clean up empty directories when the files in them are deleted

    def extension_whitelist
      Spotlight::Engine.config.allowed_upload_extensions
    end

    def store_dir
      "/home/rvm/storage/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    def delete_empty_upstream_dirs
      path = ::File.expand_path(store_dir)
      Dir.delete(path) # fails if path not empty dir
    rescue SystemCallError
      true # nothing, the dir is not empty
    end
    
  end
end
