# RVM 1.x Capistrano 3.x integration

An automated version of the integration requiring minimal configuration.
Includes task to install RVM and Ruby.

## Installation
Add this line to your application's Gemfile:

    gem 'rvm1-capistrano3', require: false

You need to run `bundle install` to install the gem.

Or install it yourself as:

    $ gem install rvm1-capistrano3

## Usage

In `Capfile` add

```ruby
require 'rvm1/capistrano3'
```

It will automatically:

- detect rvm installation path, preferring user installation
- detect ruby from project directory
- create the gemset if not existing already

## Security

Please note that for now no automatic installation of PGP keys is done,
based on this instruction <http://rvm.io/rvm/security> a minimalistic
task can be added to handle the keys installation:

```ruby
namespace :app do
  task :update_rvm_key do
    on roles(:app) do
      execute :gpg, "--keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
    end
  end
end
before "rvm1:install:rvm", "app:update_rvm_key"
```
replace `:gpg` with `:gpg2` depending on the output from RVM.


## Install RVM 1.x

This task will install stable version of rvm in `$HOME/.rvm`:
```bash
cap rvm1:install:rvm
```

Or add an before hook:
```ruby
before 'deploy', 'rvm1:install:rvm'  # install/update RVM
```

## Install Ruby

This task will install ruby from the project (other the specified one):
```bash
cap rvm1:install:ruby
```

Or add an before hook:
```ruby
before 'deploy', 'rvm1:install:ruby'  # install/update Ruby
```

This task requires [`NOPASSWD` for the user in `/etc/sudoers`](http://serverfault.com/a/160587),
or at least all ruby requirements installed already.

Please note that `NOPASSWD` can bring security vulnerabilities to your system and
it's not recommended to involve this option unless you really understand implications of it.

## Create alias

Creates alias with the application name for the app ruby:

```ruby
before 'deploy', 'rvm1:alias:create'
```

To change the alias name use:

```ruby
set :rvm1_alias_name, 'my-alias-name'
```

## Install Gems

This task replaces `capistrano-bundler` gem use only one at time

This will install gems from the project `Gemfile`:
```bash
cap rvm1:install:gems
```

Or add an before hook:
```ruby
before 'deploy', 'rvm1:install:gems'  # install/update gems from Gemfile into gemset
```

Right now all gems in Gemfile will be installed into gemset.

Support for `Gemfile` installation in Rubygems is still young,
we will improve it with new RG releases.

- RG 2.0-2.1 - support for gem + version in `Gemfile`
- RG 2.2 - limited support for `Gemfile.lock` - work still in progress,
  test with `rvm rubygems head`

## Configuration

Well if you really need to there are available ways:

- `set :rvm1_ruby_version, "2.0.0"` - to avoid autodetection and use specific version
- `fetch(:default_env).merge!( rvm_path: "/opt/rvm" )` - to force specific path to rvm installation

## How it works

This gem adds a new task `rvm1:hook` before `deploy:starting`.
It uses the [script/rvm-auto.sh](script/rvm-auto.sh) for capistrano when it wants to run
`rake`, `gem`, `bundle`, or `ruby`.

## Check your configuration

If you want to check your configuration you can use the `rvm1:check` task to
get information about the RVM version and ruby which would be used for
deployment.

    $ cap production rvm1:check

## Custom tasks which rely on RVM/Ruby

When building custom tasks which need the current ruby version and gemset, all you
have to do is run the `rvm1:hook` task before your own task. This will handle
the execution of the ruby-related commands.
This is only necessary if your task is *not* *after* the `deploy:starting` task.

    before :my_custom_task, 'rvm1:hook'

# Custom Roles: :rvm1_roles

If you want to restrict RVM usage to a subset of roles, you may set `:rvm_roles`:

    set :rvm1_roles, [:rvm]

This can be used to restrict RVM use to only one stage which uses given roles.

# Custom Path to rvm-auto.sh

By default the `rvm-auto.sh` script will be saved under `/tmp/<application>-<ssh-user>`. To override it, use:

    set :rvm1_auto_script_path, '/tmp/another/dir'


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test your changes (`tf --text test/*.sh`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
