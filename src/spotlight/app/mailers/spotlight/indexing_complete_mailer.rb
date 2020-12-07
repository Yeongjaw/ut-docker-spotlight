# frozen_string_literal: true

module Spotlight
  ##
  # Notify the curator that we're finished processing a
  # batch upload
  class IndexingCompleteMailer < ActionMailer::Base
    def documents_indexed(csv_data, exhibit, user, row_cntr, error_items)
      @number = csv_data.length
      @exhibit = exhibit
      @uploaded = row_cntr
      @error_items = error_items
      mail(to: user.email, from: 'Lib-Support@austin.utexas.edu', subject: 'Document indexing complete')
    end
  end
end
