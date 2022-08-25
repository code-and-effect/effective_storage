# frozen_string_literal: true

Rails.application.routes.draw do
  mount EffectiveStorage::Engine => '/', as: 'effective_storage'
end

EffectiveStorage::Engine.routes.draw do
  # Public routes
  scope module: 'effective' do
  end

  namespace :admin do
    get '/storage', to: 'storage#index', as: :storage
  end

end
