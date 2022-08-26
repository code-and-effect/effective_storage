# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveStorage::Engine => '/', as: 'effective_storage'
end

EffectiveStorage::Engine.routes.draw do
  scope module: 'effective' do
    resources :storage, only: [] do
      post :mark_public, on: :member
    end
  end

  namespace :admin do
    resources :storage, only: [] do
      post :mark_inherited, on: :member
      post :mark_public, on: :member
      post :purge, on: :member
    end

    get '/storage', to: 'storage#index', as: :storage

  end

end
