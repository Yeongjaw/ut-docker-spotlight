# frozen_string_literal: true

module Spotlight
  ##
  # Process a CSV upload into new Spotlight::Resource::Upload objects
  class AddUploadsFromCSV < ActiveJob::Base
    queue_as :default

    @@row_cntr = 0
    @@error_items = []

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user, @@row_cntr, @@error_items).deliver_now
      @@row_cntr = 0
      @@error_items = []
    end

    def perform(csv_data, exhibit, _user)
      encoded_csv(csv_data).each do |row|
        url = row['url']
        title = row['spotlight_upload_title_tesim']
        creator = row['spotlight_upload_creatorContributor_tesim']
        date_created = row['spotlight_upload_date_created_tesim']
        access = row['spotlight_upload_accesscondition_tesim']

        if (!(title.present?) || !(creator.present?) ||
           !(date_created.present?) || !(access.present?))
          @@error_items << [url, title, creator, date_created, access]
          next
        end

        resource = Spotlight::Resources::Upload.new(
          data: row,
          exhibit: exhibit
        )

        multivalue_custom_fields = exhibit.custom_fields.where(is_multiple: true).map(&:field)
        multivalue_custom_fields.map do |field|
          field.slice! "_tesim"
          field.slice! "_ssim"
        end
        all_multivalue_fields = multivalue_custom_fields + Spotlight::Resources::Upload.fields(exhibit).map(&:field_name)
        # resource['data'].each { |k, v| puts k + v if all_multi_value_fields.to_s.include? k }

        # For all multivalued upload fields make pipe delimited cells into multiple items
        resource['data'].each { |k, v| resource['data'][k] = v.split('|') if all_multivalue_fields.to_s.include? k }

        resource.build_upload(remote_image_url: url) unless url == '~'
        unless resource.save_and_index
          url += " **INVALID IMAGE URL**"
          @@error_items << [url, title, creator, date_created, access]
          next
        end

        @@row_cntr += 1

      end
    end

    private

    def encoded_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          [label, column.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")] if column.present?
        end.compact.to_h
      end.compact
    end
  end
end
