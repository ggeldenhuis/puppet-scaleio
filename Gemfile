source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['~> 3.7.5']
end

gem 'puppet', puppetversion
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
gem 'rake'
gem 'librarian-puppet'
gem 'json_pure', '< 2.0.2'

if Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.0.0')
  gem 'puppet-blacksmith'
  gem 'simplecov', :require => false, :group => :test
end
