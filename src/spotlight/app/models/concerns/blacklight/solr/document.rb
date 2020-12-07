# -*- encoding : utf-8 -*-
# -*- coding: utf-8 -*-
##
##
# = Introduction
# Blacklight::Solr::Document is the module with logic for a class representing
# an individual document returned from Solr results.  It can be added in to any
# local class you want, but in default Blacklight a SolrDocument class is
# provided for you which is pretty much a blank class "include"ing
# Blacklight::Solr::Document.
#
# Blacklight::Solr::Document provides some DefaultFinders.
#
# It also provides support for Document Extensions, which advertise supported
# transformation formats.
#

module Blacklight::Solr::Document
  extend ActiveSupport::Concern
  include Blacklight::Document
  include Blacklight::Document::ActiveModelShim

  def export_as_mla_citation_txt
    creator, date_created, title, url = format_citation_values

    export_text = ""
    export_text << "#{creator.nil? ? "" : creator + '. '}"
    export_text << "#{title.nil? ? "" : title + ' - University of Texas Libraries Collections. '}"
    export_text << "#{date_created.nil? ? "" : date_created + '. '}"
    export_text << "#{url.nil? ? "" : url}"
    export_text
  end

  def export_as_apa_citation_txt
    creator, date_created, title, url = format_citation_values
    today = Time.new

    export_text = ""
    export_text << "#{creator.nil? ? "" : creator + '. '}"
    export_text << "#{date_created.nil? ? "" : '(' + date_created + '). '}"
    export_text << "#{title.nil? ? "" : title + '. '}"
    export_text << "Retrieved #{today.strftime("%B %d, %Y")}, "
    export_text << "#{url.nil? ? "" : 'from ' + url }"
    export_text
  end

  def export_as_chicago_citation_txt
    creator, date_created, title, url = format_citation_values
    today = Time.new

    export_text = ""
    export_text << "#{creator.nil? ? "" : creator + '. '}"
    export_text << "#{title.nil? ? "" : title + '. '}"
    export_text << "#{date_created.nil? ? "" : date_created + '. '}"
    export_text << "#{title.nil? ? "" : title + " – Collections\". University of Texas Libraries Collections. "}"
    export_text << "#{url.nil? ? "" : '&lt;'+ url + '&gt; ' }"
    export_text << "(#{today.strftime("%d-%B-%Y")})."
    export_text
  end

  def format_citation_values
    unless self['dc.contributor_consolidated_ms'].nil?
      if self['dc.contributor_consolidated_ms'].kind_of?(Array)
        ## Remove quotes and brackets from arrays passed in solr fields
        creator = self['dc.contributor_consolidated_ms'].join(', ')
      else
        creator = self['dc.contributor_consolidated_ms']
      end
    end

    unless self['mods_title_primary_ms'].nil?
      if self['mods_title_primary_ms'].kind_of?(Array)
        ## Remove quotes and brackets from arrays passed in solr fields
        title = self['mods_title_primary_ms'].join(', ')
      else
        title = self['mods_title_primary_ms']
      end
    end

    unless self['mods_keydate_sort_s'].nil?
      if self['mods_keydate_sort_s'].kind_of?(Array)
        ## Remove quotes and brackets from arrays passed in solr fields
        date_created = self['mods_keydate_sort_s'].join(', ')
      else
        date_created = self['mods_keydate_sort_s']
      end
    end

    unless self['spotlight_exhibit_slugs_ssim'].nil?
      if self['spotlight_exhibit_slugs_ssim'].kind_of?(Array)
        ## Remove quotes and brackets from arrays passed in solr fields
        exhibit_title = self['spotlight_exhibit_slugs_ssim'].join(', ')
      else
        exhibit_title = self['spotlight_exhibit_slugs_ssim']
      end
    end

    url = "https://" + ENV['SPOTLIGHT_HOST'] + "/spotlight/#{exhibit_title}/catalog/#{self['id']}"

    [creator, date_created, title, url]
  end

  ## These functions were copied over from the document.rb file in blacklight
  def more_like_this
    response.more_like(self).map { |doc| self.class.new(doc, response) }
  end

  def has_highlight_field? k
    return false if response['highlighting'].blank? || response['highlighting'][id].blank?

    response['highlighting'][id].key? k.to_s
  end

  def highlight_field k
    response['highlighting'][id][k.to_s].map(&:html_safe) if has_highlight_field? k
  end
end
