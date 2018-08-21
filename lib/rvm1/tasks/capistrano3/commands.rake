namespace :rvm1 do
  namespace :install do
    desc "Installs RVM 1.x user mode"
    task :rvm do
      on roles(fetch(:rvm1_roles, :all)) do
        execute :mkdir, "-p", "#{fetch(:rvm1_auto_script_path)}/"
        upload! File.expand_path("../../../../../script/install-rvm.sh", __FILE__), "#{fetch(:rvm1_auto_script_path)}/install-rvm.sh"
        execute :chmod, "+x", "#{fetch(:rvm1_auto_script_path)}/install-rvm.sh"
        execute "#{fetch(:rvm1_auto_script_path)}/install-rvm.sh"
      end
    end
    before :rvm, 'rvm1:hook'

    desc "Installs Ruby for the given ruby project"
    task :ruby do
      on roles(fetch(:rvm1_roles, :all)) do
        within fetch(:release_path) do
          execute "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh", "rvm", "--install", "install", fetch(:rvm1_ruby_version), *fetch(:rvm1_ruby_install_options, [])
        end
      end
    end
    before :ruby, "deploy:updating"
    before :ruby, 'rvm1:hook'

    desc "Install gems from Gemfile into gemset using rubygems."
    task :gems do
      on roles(fetch(:rvm1_roles, :all)) do
        within release_path do
          execute :gem, "install", "--file", "Gemfile"
        end
      end
    end
    before :gems, "deploy:updating"
    before :gems, 'rvm1:hook'

  end

  namespace :alias do
    desc "Create an alias for the given"
    task :create do
      on roles(fetch(:rvm1_roles, :all)) do
        within fetch(:release_path) do
          execute "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh",
            "rvm", "alias", "create",
            fetch(:rvm1_alias_name), fetch(:rvm1_ruby_version)
        end
      end
    end
    before :create, "deploy:updating"
    before :create, 'rvm1:hook'
  end
end
