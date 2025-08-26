#ruby=1.8.7

source "https://rubygems.org"

gemspec

if RUBY_VERSION < "2.0.0"
  gem "capistrano", "< 3.3.0"
  gem "net-ssh",    "< 3.0.0"
  gem "i18n",       "< 1.0.0" # Drop Ruby 1.9 support
end
