# Effective Storage

Adds an authentication layer to the Active Storage downloads controller.

Authorizes the user downloading each file and raises an exception for unauthorized requests.

Adds an admin screen to browse Active Storage attachments and mark them as inherited or public.

## Getting Started

This requires Rails 6+ and Twitter Bootstrap 4 and just works with Devise.

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install the [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'haml-rails' # or try using gem 'hamlit-rails'
gem 'effective_storage'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_storage:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

If you want to tweak the table names, manually adjust both the configuration file and the migration now.

Then migrate the database:

```ruby
rake db:migrate
```

Add a link to the admin menu:

```haml
- if can?(:admin, :effective_storage) && can?(:index, ActiveStorage::Attachment)
  = nav_link_to 'Storage', effective_storage.admin_storage_path
```

## Configuration

## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

## Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
# Allow anyone to download a public file
can(:show, ActiveStorage::Blob) { |blob| blob.permission_public? }

if user.persisted?
end

if user.admin?
  # This allows the admin to download any file
  can :show, ActiveStorage::Blob

  # Allows them to see the index screen
  can :admin, :effective_storage
  can :index, ActiveStorage::Blob

  # Admin screen actions
  can(:mark_inherited, ActiveStorage::Blob) { |blob| !blob.permission_inherited? }
  can(:mark_public, ActiveStorage::Blob) { |blob| !blob.permission_public? }
end
```

## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
rails test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
