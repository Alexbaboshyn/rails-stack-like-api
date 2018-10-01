source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2'
gem 'sqlite3'
gem 'puma'
gem 'bcrypt'
gem 'uglifier'
gem 'bootsnap', require: false
gem 'draper'
gem 'kaminari'
gem 'email_validator'

group :development, :test do
  gem 'rspec-rails'
  gem 'pry-byebug'
  gem 'factory_bot_rails'
  gem 'ffaker'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'shoulda-matchers'
  gem 'rspec-its'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'shoulda-callback-matchers'
  gem 'rails-controller-testing'
end
