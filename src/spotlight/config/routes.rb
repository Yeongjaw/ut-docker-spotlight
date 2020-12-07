Rails.application.routes.draw do

  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'
  root to: 'spotlight/exhibits#index'
  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'
  # mount MiradorRails::Engine, at: MiradorRails::Engine.locales_mount_path
#  root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  get "about", to: "about#index", as: "about"
  get "help", to: "help#index", as: "help"
  get "contact", to: "contact#index", as: "contact"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
