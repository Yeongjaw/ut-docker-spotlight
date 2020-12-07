# frozen_string_literal: true

Spotlight::Engine.config.iiif_title_fields = %w(full_title_tesim mods_title_primary_ms)
# fields requested by PO
Spotlight::Engine.config.iiif_contributorConsolidated_fields = %w(dc.contributor_consolidated_ms)
Spotlight::Engine.config.iiif_keydateSort_fields = %w(mods_keydate_sort_s)
Spotlight::Engine.config.iiif_abstract_fields = %w(mods_abstract_ms)
Spotlight::Engine.config.iiif_noteTypeGeneral_fields = %w(mods_note_type_general_ms)
Spotlight::Engine.config.iiif_geographicCoverageConsolidated_fields = %w(mods_geographic_coverage_consolidated_ms)
Spotlight::Engine.config.iiif_displayLanguage_fields = %w(display_language_ms)
Spotlight::Engine.config.iiif_locationPhysicalLocation_fields = %w(mods_location_physicalLocation_ms repository_facet_s)
Spotlight::Engine.config.iiif_subjectGeographic_fields = %w(mods_subject_geographic_ms)
Spotlight::Engine.config.iiif_accessCondition_fields = %w(mods_accessCondition_use_and_reproduction_ss)
Spotlight::Engine.config.iiif_relatedItemIdentifier_fields = %w(mods_relatedItem_identifier_local_source_t)
Spotlight::Engine.config.iiif_relatedItemTitleInfo_fields = %w(mods_relatedItem_titleInfo_title_source_t)
Spotlight::Engine.config.iiif_subtitlePrimary_fields = %w(mods_subTitle_primary_ss)
Spotlight::Engine.config.iiif_subjectTemporal_fields = %w(mods_subject_temporal_ms)
Spotlight::Engine.config.iiif_subjectTopic_fields = %w(mods_subject_topic_ms)
Spotlight::Engine.config.iiif_subtitleTranslated_fields = %w(mods_subTitle_translated_ms)
Spotlight::Engine.config.iiif_titleTranslated_fields = %w(mods_title_translated_ms)
Spotlight::Engine.config.iiif_typeConsolidated_fields = %w(mods_type_consolidated_ms)
Spotlight::Engine.config.iiif_thumbnail_fields = %w(readonly_thumbnail-uri_tesim thumbnail_url_ssm)
Spotlight::Engine.config.iiif_physicalDescription_fields = %w(mods_physicalDescription_extent_ms)

# ==> Uploaded item configuration
# Title
Spotlight::Engine.config.upload_title_field = Spotlight::UploadFieldConfig.new(
  solr_fields: %w(full_title_tesim mods_title_primary_ms spotlight_upload_title_tesim),
  field_name: :spotlight_upload_title_tesim,
  label: 'Title'
)

Spotlight::Engine.config.upload_fields = [
  # Creator/Contributor
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'dc.contributor_consolidated_ms',
      'spotlight_upload_creatorContributor_tesim'
    ],
    field_name: :spotlight_upload_creatorContributor_tesim,
    label: "Creator / Contributor"
  ),
  # Date Created Date Issued
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_keydate_sort_s',
      'spotlight_upload_date_created_tesim'
    ],
    field_name: :spotlight_upload_date_created_tesim,
    label: "Date Created / Date Issued"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_accessCondition_use_and_reproduction_ss',
      'spotlight_upload_accesscondition_tesim'
    ],
    field_name: :spotlight_upload_accesscondition_tesim,
    label: "Rights - Use and Reproduction"
  ),
  # Description
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_abstract_ms',
      'spotlight_upload_description_tesim'
    ],
    field_name: Spotlight::Engine.config.upload_description_field,
    label: -> { I18n.t(:"spotlight.search.fields.#{Spotlight::Engine.config.upload_description_field}") },
    form_field_type: :text_area
  ),
# Type
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_type_consolidated_ms',
      'spotlight_upload_type_tesim'
    ],
    field_name: :spotlight_upload_type_tesim,
    label: "Type"
  ),
# Language
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'display_language_ms',
      'spotlight_upload_language_tesim'
    ],
    field_name: :spotlight_upload_language_tesim,
    label: "Language"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_subject_topic_ms',
      'spotlight_upload_topic_tesim'
    ],
    field_name: :spotlight_upload_topic_tesim,
    label: "Topic"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_geographic_coverage_consolidated_ms',
      'spotlight_upload_geographicCoverageConsolidated_tesim'
    ],
    field_name: :spotlight_upload_geographicCoverageConsolidated_tesim,
    label: "Geographic Coverage"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_location_physicalLocation_ms',
      'spotlight_upload_locationPhysicalLocation_tesim',
      'repository_facet_s'
    ],
    field_name: :spotlight_upload_locationPhysicalLocation_tesim,
    label: "Owning Repository"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_note_type_general_ms',
      'spotlight_upload_noteTypeGeneral_tesim'
    ],
    field_name: :spotlight_upload_noteTypeGeneral_tesim,
    label: "General Note"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_relatedItem_identifier_local_source_t',
      'spotlight_upload_relatedItemIdentifier_tesim'
    ],
    field_name: :spotlight_upload_relatedItemIdentifier_tesim,
    label: "Source Collection Identifier"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_relatedItem_titleInfo_title_source_t',
      'spotlight_upload_relateItemTitleInfo_tesim'
    ],
    field_name: :spotlight_upload_relateItemTitleInfo_tesim,
    label: "Source Collection Name"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_subject_geographic_ms',
      'readonly_place-name_tesim',
      'spotlight_upload_subjectGeographic_tesim'
    ],
    field_name: :spotlight_upload_subjectGeographic_tesim,
    label: "Place Name"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_subject_temporal_ms',
      'spotlight_upload_subjectTemporal_tesim'
    ],
    field_name: :spotlight_upload_subjectTemporal_tesim,
    label: "Time Period Covered"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_subTitle_primary_ss',
      'spotlight_upload_subtitlePrimary_tesim'
    ],
    field_name: :spotlight_upload_subtitlePrimary_tesim,
    label: "Subtitle"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_subTitle_translated_ms',
      'spotlight_upload_subtitleTranslated_tesim'
    ],
    field_name: :spotlight_upload_subtitleTranslated_tesim,
    label: "Translated Subtitle"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_title_translated_ms',
      'spotlight_upload_titleTranslated_tesim'
    ],
    field_name: :spotlight_upload_titleTranslated_tesim,
    label: "Translated Title"
  ),
  Spotlight::UploadFieldConfig.new(
    solr_fields: [
      'mods_physicalDescription_extent_ms',
      'spotlight_upload_physicalDescription_extent_tesim'
    ],
    field_name: :spotlight_upload_physicalDescription_extent_tesim,
    label: "Extent"
  )
]

# ==> User model
# Note that your chosen model must include Spotlight::User mixin
# Spotlight::Engine.config.user_class = '::User'

# ==> Blacklight configuration
# Spotlight uses this upstream configuration to populate settings for the curator
# Spotlight::Engine.config.catalog_controller_class = '::CatalogController'
# Spotlight::Engine.config.default_blacklight_config = nil

# ==> Appearance configuration
# Spotlight::Engine.config.exhibit_main_navigation = [:curated_features, :browse, :about]
Spotlight::Engine.config.resource_partials = [
#   'spotlight/resources/external_resources_form',
  'spotlight/resources/upload/form',
  'spotlight/resources/csv_upload/form',
  # 'spotlight/resources/json_upload/form',
  'spotlight/resources/iiif/form'
]
# Spotlight::Engine.config.external_resources_partials = []
# Spotlight::Engine.config.default_browse_index_view_type = :gallery
# Spotlight::Engine.config.default_contact_email = nil

# ==> Solr configuration
# Spotlight::Engine.config.writable_index = true
# Spotlight::Engine.config.solr_batch_size = 20
# Spotlight::Engine.config.filter_resources_by_exhibit = true
# Spotlight::Engine.config.autocomplete_search_field = 'autocomplete'
# Spotlight::Engine.config.default_autocomplete_params = { qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng' }

# Solr field configurations
# Spotlight::Engine.config.solr_fields.prefix = ''.freeze
# Spotlight::Engine.config.solr_fields.boolean_suffix = '_bsi'.freeze
# Spotlight::Engine.config.solr_fields.string_suffix = '_ssim'.freeze
# Spotlight::Engine.config.solr_fields.text_suffix = '_tesim'.freeze
# Spotlight::Engine.config.resource_global_id_field = :"#{config.solr_fields.prefix}spotlight_resource_id#{config.solr_fields.string_suffix}"
# Spotlight::Engine.config.full_image_field = :full_image_url_ssm
Spotlight::Engine.config.thumbnail_field = :thumbnail_url_ssm
# Spotlight::Engine.config.thumbnail_field = 'readonly_thumbnail-uri_tesim'

# ==> Uploaded item configuration
# Spotlight::Engine.config.upload_fields = [
#   UploadFieldConfig.new(
#     field_name: config.upload_description_field,
#     label: -> { I18n.t(:"spotlight.search.fields.#{config.upload_description_field}") },
#     form_field_type: :text_area
#   ),
#   UploadFieldConfig.new(
#     field_name: :spotlight_upload_attribution_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_attribution_tesim') }
#   ),
#   UploadFieldConfig.new(
#     field_name: :spotlight_upload_date_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
#   )
# ]
# Spotlight::Engine.config.upload_title_field = nil # UploadFieldConfig.new(...)
# Spotlight::Engine.config.uploader_storage = :file
# Spotlight::Engine.config.allowed_upload_extensions = %w(jpg jpeg png)

Spotlight::Engine.config.featured_image_thumb_size = [200, 130]
# Spotlight::Engine.config.featured_image_thumb_size = [400, 300]
# Spotlight::Engine.config.featured_image_square_size = [400, 400]
Spotlight::Engine.config.contact_square_size [70, 70]

# ==> Google Analytics integration
# Spotlight::Engine.config.analytics_provider = Spotlight::Analytics::Ga
# Spotlight::Engine.config.ga_pkcs12_key_path = nil
# Spotlight::Engine.config.ga_web_property_id = nil
# Spotlight::Engine.config.ga_email = nil
# Spotlight::Engine.config.ga_analytics_options = {}
# Spotlight::Engine.config.ga_page_analytics_options = config.ga_analytics_options.merge(limit: 5)
# Spotlight::Engine.config.ga_anonymize_ip = false # false for backwards compatibility

# ==> Sir Trevor Widget Configuration
Spotlight::Engine.config.sir_trevor_widgets = %w(
  Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse LinkToSearch
  FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
  SolrDocumentsFeatures SolrDocumentsGrid SearchResults
)
#
# Page configurations made available to widgets
# Spotlight::Engine.config.page_configurations = {
#   'my-local-config': ->(context) { context.my_custom_data_path(context.current_exhibit) }
# }
