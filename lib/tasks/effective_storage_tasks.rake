namespace :effective_storage do

  # bundle exec rake effective_storage:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

end
