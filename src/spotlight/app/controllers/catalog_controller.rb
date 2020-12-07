# frozen_string_literal: true

##
# Simplified catalog controller
class CatalogController < ApplicationController

  helper Openseadragon::OpenseadragonHelper

  include Blacklight::Catalog

  configure_blacklight do |config|
    blacklight_config.add_results_collection_tool(:sort_widget)
    blacklight_config.add_results_collection_tool(:per_page_widget)
    blacklight_config.add_results_collection_tool(:view_type_group)
    blacklight_config.add_nav_action(:about, partial: 'blacklight/nav/about')
    blacklight_config.add_nav_action(:help, partial: 'blacklight/nav/help')
    blacklight_config.add_nav_action(:contact, partial: 'blacklight/nav/contact')

    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    # config.view.slideshow.partials = [:index]


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    # config.show.partials.insert(1, :openseadragon)
    config.show.partials.insert(1, :viewer)

    # This is used for item widgets
    config.view.embed.partials = [:openseadragon]
    config.view.embed.if = false

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'mods_title_primary_ms'
    config.index.creatorContributor_field = 'dc.contributor_consolidated_ms'

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')
    config.add_sort_field 'title', sort: 'mods_title_primary_ms asc', label: I18n.t('spotlight.search.fields.sort.title')
    config.add_sort_field 'creatorContributor_display', sort: 'dc.contributor_consolidated_ms asc', label: 'Creator'
    config.add_sort_field 'date_created_issued', sort: 'mods_keydate_sort_s asc', label: 'Date Created/Date Issued'
    # config.add_sort_field 'place_name_display', sort: 'mods_subject_geographic_ms asc', label: I18n.t('spotlight.search.fields.sort.place-name')
    # config.add_sort_field 'topic_display', sort: 'mods_subject_topic_ms asc', label: I18n.t('spotlight.search.fields.sort.topic')

    config.add_show_tools_partial(:citation)

    config.add_field_configuration_to_solr_request!

    # enable facets:
    config.add_facet_field 'repository_facet_s', label: 'Owning Repository', limit: true, sort: 'index'
    config.add_facet_field 'mods_keydate_sort_s', label: 'Date Created/Date Issued', limit: true, sort: 'index'
    config.add_facet_field 'mods_subject_geographic_ms', label: 'Place Name', limit: true
    config.add_facet_field 'mods_type_consolidated_ms', label: 'Type', limit: true, sort: 'index'
    config.add_facet_field 'display_language_ms', label: 'Language', limit: true, sort: 'index'
    config.add_facet_field 'mods_subject_topic_ms', label: 'Topic', limit: 5, sort: 'index'

    config.add_facet_fields_to_solr_request!

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    config.add_search_field('mods_title_primary_ms') do |field|
      field.label = 'Title'
    end
    config.add_search_field('dc.contributor_consolidated_ms') do |field|
      field.label = 'Creator/Contributor'
    end
    config.add_search_field('mods_keydate_sort_s') do |field|
      field.label = 'Date Created/Date Issued'
    end
    config.add_search_field('mods_location_physicalLocation_ms') do |field|
      field.label = 'Owning Repository'
    end
    config.add_search_field('mods_type_consolidated_ms') do |field|
      field.label = 'Type'
    end



    # Set which views by default only have the title displayed, e.g.,
    config.view.gallery.title_only_by_default = true
    config.view.masonry.title_only_by_default = true
  end
end
