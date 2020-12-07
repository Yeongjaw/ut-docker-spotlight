# frozen_string_literal: true

require 'csv'

module Spotlight
  module Resources
    ##
    # Creating new exhibit items from single-item entry forms
    # or batch CSV upload
    class CsvUploadController < ApplicationController
      helper :all

      before_action :authenticate_user!

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

      def create
        csv = CSV.parse(csv_io_param, headers: true, return_headers: false).map(&:to_hash)
        Spotlight::AddUploadsFromCSV.perform_later(csv, current_exhibit, current_user)
        flash[:notice] = t('spotlight.resources.upload.csv.success', file_name: csv_io_name)
        redirect_to spotlight.admin_exhibit_catalog_path(current_exhibit)
      end

      def template
        render plain: CSV.generate { |csv| csv << data_param_keys_for_csv.unshift(:url) }, content_type: 'text/csv'
      end

      private

      def build_resource
        @resource ||= Spotlight::Resources::Upload.new exhibit: current_exhibit
      end

      def csv_params
        params.require(:resources_csv_upload).permit(:url)
      end

      # This removes suffix _tesim for template so custom fields are correctly
      # grabbed from csv files
      # e.g. Custom field Original Location -> original-location
      # in the csv header, not original-location_tesim
      def data_param_keys_for_csv
        # Remove readonly fields from csv file
        custom_fields = current_exhibit.custom_fields.where('field NOT LIKE ?', 'readonly_%').all
        custom_fields.map do |field|
          field.field.slice! "_tesim"
          field.field.slice! "_ssim"
        end
        # custom_fields.map {|field| puts field.field }
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) + custom_fields.map(&:field)
      end

      def data_param_keys
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) + current_exhibit.custom_fields.map(&:field)
      end

      # Gets an IO-like object for the CSV parser to use.
      # @return IO
      def csv_io_param
        file_or_io = csv_params[:url]
        io = if file_or_io.respond_to?(:to_io)
               file_or_io.to_io
             else
               file_or_io
             end

        io.set_encoding('utf-8')
      end

      def csv_io_name
        file_or_io = csv_params[:url]

        if file_or_io.respond_to? :original_filename
          file_or_io.original_filename
        else
          t('spotlight.resources.upload.csv.anonymous_file')
        end
      end
    end
  end
end
