# frozen_string_literal: true

require 'resque/server'

Rails.application.routes.draw do
  root 'home#index'

  devise_for :users
  get '/u/:id' => 'users#show', as: :user

  get  '/photos/:friendly_url' => 'photos#show', as: :photo
  get  '/notes/:friendly_url'  => 'notes#show', as: :note

  scope '/p' do
    get '/:friendly_url' => 'people#show', as: :person
    get '/:friendly_url/family' => 'people#show_family', as: :person_family
    get '/:friendly_url/gallery' => 'people#show_gallery', as: :person_gallery
  end

  get '/search'      => 'search#search', as: :search
  get '/tagged/:tag' => 'search#tagged', as: :tagged

  namespace :ajax do
    get 'tags' => 'ajax#tags'
    get 'people_tags' => 'ajax#people_tags'
    get 'people_tag/:id' => 'ajax#people_tag', as: :people_tag
  end

  authenticate :user do
    resource :settings

    mount Resque::Server, at: 'jobs'
  end

  namespace :admin do
    resources :users
    resources :people
    resources :photos
    resources :notes
    resources :facts
    resources :citations

    get 'suggestions/citation/:text' => 'citations#suggestions'

    get '/snapshots/initiate' => 'snapshots#initiate', as: :initiate_snapshot
    resources :snapshots do
      get 'restore' => 'snapshots#restore'
    end

    root to: 'users#index'
  end
end
