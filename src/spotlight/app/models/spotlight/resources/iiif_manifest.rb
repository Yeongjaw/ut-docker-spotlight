# frozen_string_literal: true

module Spotlight
  module Resources
    ##
    # A PORO to construct a solr hash for a given IiifManifest
    class IiifManifest
      attr_reader :collection
      def initialize(attrs = {})
        @url = attrs[:url]
        @manifest = attrs[:manifest]
        @collection = attrs[:collection]
        @solr_hash = {}
      end

      def to_solr
        add_document_id
        add_label
        add_thumbnail_url
        add_full_image_urls
        add_manifest_url
        add_image_urls
        add_metadata
        add_collection_id
        solr_hash
      end

      def with_exhibit(e)
        @exhibit = e
      end

      def compound_id
        Digest::MD5.hexdigest("#{exhibit.id}-#{url}")
      end

      private

      attr_reader :url, :manifest, :exhibit, :solr_hash
      delegate :blacklight_config, to: :exhibit

      def add_document_id
        solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
      end

      def add_collection_id
        solr_hash[collection_id_field] = [collection.compound_id] if collection
      end

      def collection_id_field
        Spotlight::Engine.config.iiif_collection_id_field
      end

      def add_manifest_url
        solr_hash[Spotlight::Engine.config.iiif_manifest_field] = url
      end

      def add_thumbnail_url
        return unless thumbnail_field && manifest['thumbnail'].present?

        solr_hash[thumbnail_field] = manifest['thumbnail']['@id']
      end

      def add_full_image_urls
        return unless full_image_field && full_image_url

        solr_hash[full_image_field] = full_image_url
      end

      def add_label
        return unless title_fields.present? && manifest.try(:label)
        Array.wrap(title_fields).each do |field|
          solr_hash[field] = metadata_class.new(manifest).label
        end

        # add additional fields to solr (requested by PO)
        return unless contributorConsolidated_fields.present? && manifest.try(:label)
        Array.wrap(contributorConsolidated_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_creator-contributor_tesim"]
        end

        return unless keydateSort_fields.present? && manifest.try(:label)
        Array.wrap(keydateSort_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_date-created-date-issued_tesim"]
        end

        return unless abstract_fields.present? && manifest.try(:label)
        Array.wrap(abstract_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_description_tesim"]
        end

        return unless noteTypeGeneral_fields.present? && manifest.try(:label)
        Array.wrap(displayLanguage_fields ).each do |field|
          solr_hash[field] = manifest_metadata["readonly_note-type-general_tesim"]
        end

        return unless geographicCoverageConsolidated_fields.present? && manifest.try(:label)
        Array.wrap(geographicCoverageConsolidated_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_geographic-coverage_tesim"]
        end

        return unless displayLanguage_fields .present? && manifest.try(:label)
        Array.wrap(displayLanguage_fields ).each do |field|
          solr_hash[field] = manifest_metadata["readonly_language_tesim"]
        end

        return unless locationPhysicalLocation_fields.present? && manifest.try(:label)
        Array.wrap(locationPhysicalLocation_fields).each do |field|
          if field == "repository_facet_s"
            solr_hash[field] = manifest_metadata["readonly_owning-repository_tesim"][0].split(",")[0]
          else
            solr_hash[field] = manifest_metadata["readonly_owning-repository_tesim"]
          end
        end

        return unless subjectGeographic_fields.present? && manifest.try(:label)
        Array.wrap(subjectGeographic_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_place-name_tesim"]
        end

        return unless accessCondition_fields.present? && manifest.try(:label)
        Array.wrap(accessCondition_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_rights-use-and-reproduction_tesim"]
        end

        return unless relatedItemIdentifier_fields.present? && manifest.try(:label)
        Array.wrap(relatedItemIdentifier_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_source-collection-local-identifier_tesim"]
        end

        return unless relatedItemTitleInfo_fields.present? && manifest.try(:label)
        Array.wrap(relatedItemTitleInfo_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_source-collection-name_tesim"]
        end

        return unless subtitlePrimary_fields.present? && manifest.try(:label)
        Array.wrap(subtitlePrimary_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_subtitle_tesim"]
        end

        return unless subjectTemporal_fields.present? && manifest.try(:label)
        Array.wrap(subjectTemporal_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_time-period-covered_tesim"]
        end

        return unless subjectTopic_fields.present? && manifest.try(:label)
        Array.wrap(subjectTopic_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_topic_tesim"]
        end

        return unless subtitleTranslated_fields.present? && manifest.try(:label)
        Array.wrap(subtitleTranslated_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_translated-subtitle_tesim"]
        end

        return unless titleTranslated_fields.present? && manifest.try(:label)
        Array.wrap(titleTranslated_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_translated-title_tesim"]
        end

        return unless typeConsolidated_fields.present? && manifest.try(:label)
        Array.wrap(typeConsolidated_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_type_tesim"]
        end

        return unless thumbnail_fields.present? && manifest.try(:label)
        Array.wrap(thumbnail_fields).each do |field|
          solr_hash[field] = manifest_metadata["readonly_thumbnail-uri_tesim"]
        end

        return unless physicalDescription_fields.present? && manifest.try(:label)
        Array.wrap(physicalDescription_fields).each do |field|
          solr_hash[field] = manifest_metadata["mods_physicalDescription_extent_ms"]
        end

      end

      def add_image_urls
        solr_hash[tile_source_field] = image_urls
      end

      def add_metadata
        solr_hash.merge!(manifest_metadata)
        sidecar.update(data: sidecar.data.merge(manifest_metadata))
      end

      def manifest_metadata
        metadata = metadata_class.new(manifest).to_solr
        return {} unless metadata.present?

        create_sidecars_for(*metadata.keys)

        metadata.each_with_object({}) do |(key, value), hash|
          next unless (field = exhibit_custom_fields[key])

          hash[field.field] = value
        end
      end

      def create_sidecars_for(*keys)
        missing_keys(keys).each do |k|
          exhibit.custom_fields.create! label: k, readonly_field: true
        end
        @exhibit_custom_fields = nil
      end

      def missing_keys(keys)
        custom_field_keys = exhibit_custom_fields.keys.map(&:downcase)
        keys.reject do |key|
          custom_field_keys.include?(key.downcase)
        end
      end

      def exhibit_custom_fields
        @exhibit_custom_fields ||= exhibit.custom_fields.each_with_object({}) do |value, hash|
          hash[value.label] = value
        end
      end

      def image_urls
        @image_urls ||= resources.map do |resource|
          next unless resource && !resource.service.empty?

          image_url = resource.service['@id']
          image_url << '/info.json' unless image_url.downcase.ends_with?('/info.json')
          image_url
        end
      end

      def full_image_url
        resources.first.try(:[], '@id')
      end

      def resources
        @resources ||= sequences
                       .flat_map(&:canvases)
                       .flat_map(&:images)
                       .flat_map(&:resource)
      end

      def sequences
        manifest.try(:sequences) || []
      end

      def thumbnail_field
        blacklight_config.index.try(:thumbnail_field)
      end

      def full_image_field
        Spotlight::Engine.config.full_image_field
      end

      def tile_source_field
        blacklight_config.show.try(:tile_source_field)
      end

      def title_fields
        Spotlight::Engine.config.iiif_title_fields || blacklight_config.index.try(:title_field)
      end

      def contributorConsolidated_fields
        Spotlight::Engine.config.iiif_contributorConsolidated_fields
      end

      def keydateSort_fields
        Spotlight::Engine.config.iiif_keydateSort_fields
      end

      def abstract_fields
        Spotlight::Engine.config.iiif_abstract_fields
      end

      def noteTypeGeneral_fields
        Spotlight::Engine.config.iiif_noteTypeGeneral_fields
      end

      def geographicCoverageConsolidated_fields
        Spotlight::Engine.config.iiif_geographicCoverageConsolidated_fields
      end

      def displayLanguage_fields
        Spotlight::Engine.config.iiif_displayLanguage_fields
      end

      def locationPhysicalLocation_fields
        Spotlight::Engine.config.iiif_locationPhysicalLocation_fields
      end

      def subjectGeographic_fields
        Spotlight::Engine.config.iiif_subjectGeographic_fields
      end

      def accessCondition_fields
        Spotlight::Engine.config.iiif_accessCondition_fields
      end

      def relatedItemIdentifier_fields
        Spotlight::Engine.config.iiif_relatedItemIdentifier_fields
      end

      def relatedItemTitleInfo_fields
        Spotlight::Engine.config.iiif_relatedItemTitleInfo_fields
      end

      def subtitlePrimary_fields
        Spotlight::Engine.config.iiif_subtitlePrimary_fields
      end

      def subjectTemporal_fields
        Spotlight::Engine.config.iiif_subjectTemporal_fields
      end

      def subjectTopic_fields
        Spotlight::Engine.config.iiif_subjectTopic_fields
      end

      def subtitleTranslated_fields
        Spotlight::Engine.config.iiif_subtitleTranslated_fields
      end

      def titleTranslated_fields
        Spotlight::Engine.config.iiif_titleTranslated_fields
      end

      def typeConsolidated_fields
        Spotlight::Engine.config.iiif_typeConsolidated_fields
      end

      def thumbnail_fields
        Spotlight::Engine.config.iiif_thumbnail_fields
      end

      def physicalDescription_fields
        Spotlight::Engine.config.iiif_physicalDescription_fields
      end

      def sidecar
        @sidecar ||= document_model.new(id: compound_id).sidecar(exhibit)
      end

      def document_model
        exhibit.blacklight_config.document_model
      end

      def metadata_class
        Spotlight::Engine.config.iiif_metadata_class.call
      end

      ###
      #  A simple class to map the metadata field
      #  in a IIIF document to label/value pairs
      #  This is intended to be overriden by an
      #  application if a different metadata
      #  strucure is used by the consumer
      class Metadata
        def initialize(manifest)
          @manifest = manifest
        end

        def to_solr
          metadata_hash.merge(manifest_level_metadata)
        end

        def label
          return unless manifest.try(:label)

          Array(json_ld_value(manifest.label)).map { |v| html_sanitize(v) }.first
        end

        private

        attr_reader :manifest

        def metadata
          manifest.try(:metadata) || []
        end

        def metadata_hash
          return {} unless metadata.present?
          return {} unless metadata.is_a?(Array)

          metadata.each_with_object({}) do |md, hash|
            next unless md['label'] && md['value']

            label = Array(json_ld_value(md['label'])).first

            hash[label] ||= []
            hash[label] += Array(json_ld_value(md['value'])).map { |v| html_sanitize(v) }
          end
        end

        def manifest_level_metadata
          manifest_fields.each_with_object({}) do |field, hash|
            next unless manifest.respond_to?(field) &&
                        manifest.send(field).present?

            hash[field.capitalize] ||= []
            hash[field.capitalize] += Array(json_ld_value(manifest.send(field))).map { |v| html_sanitize(v) }
          end
        end

        def manifest_fields
          %w[attribution description license]
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
        def json_ld_value(value)
          case value
          # In the case where multiple values are supplied, clients must use the following algorithm to determine which values to display to the user.
          when Array
            # IIIF v2, multivalued monolingual, or multivalued multilingual values

            # If none of the values have a language associated with them, the client must display all of the values.
            if value.none? { |v| v.is_a?(Hash) && v.key?('@language') }
              value.map { |v| json_ld_value(v) }
            # If any of the values have a language associated with them, the client must display all of the values associated with the language that best
            # matches the language preference.
            elsif value.any? { |v| v.is_a?(Hash) && v['@language'] == default_json_ld_language }
              value.select { |v| v.is_a?(Hash) && v['@language'] == default_json_ld_language }.map { |v| v['@value'] }
            # If all of the values have a language associated with them, and none match the language preference, the client must select a language
            # and display all of the values associated with that language.
            elsif value.all? { |v| v.is_a?(Hash) && v.key?('@language') }
              selected_json_ld_language = value.find { |v| v.is_a?(Hash) && v.key?('@language') }

              value.select { |v| v.is_a?(Hash) && v['@language'] == selected_json_ld_language['@language'] }
                   .map { |v| v['@value'] }
            # If some of the values have a language associated with them, but none match the language preference, the client must display all of the values
            # that do not have a language associated with them.
            else
              value.select { |v| !v.is_a?(Hash) || !v.key?('@language') }.map { |v| json_ld_value(v) }
            end
          when Hash
            # IIIF v2 single-valued value
            if value.key? '@value'
              value['@value']
            # IIIF v3 multilingual(?), multivalued(?) values
            # If all of the values are associated with the none key, the client must display all of those values.
            elsif value.keys == ['none']
              value['none']
            # If any of the values have a language associated with them, the client must display all of the values associated with the language
            # that best matches the language preference.
            elsif value.key? default_json_ld_language
              value[default_json_ld_language]
            # If some of the values have a language associated with them, but none match the language preference, the client must display all
            # of the values that do not have a language associated with them.
            elsif value.key? 'none'
              value['none']
            # If all of the values have a language associated with them, and none match the language preference, the client must select a
            # language and display all of the values associated with that language.
            else
              value.values.first
            end
          else
            # plain old string/number/boolean
            value
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

        def html_sanitize(value)
          return value unless value.is_a? String

          html_sanitizer.sanitize(value)
        end

        def html_sanitizer
          @html_sanitizer ||= Rails::Html::FullSanitizer.new
        end

        def default_json_ld_language
          Spotlight::Engine.config.default_json_ld_language
        end
      end
    end
  end
end
