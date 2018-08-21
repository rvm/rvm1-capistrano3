namespace :rvm1 do
  desc "Runs the RVM1 hook - use it before any custom tasks if necessary"
  task :hook do
    on roles(fetch(:rvm1_roles, :all)) do
      execute :mkdir, "-p", "#{fetch(:rvm1_auto_script_path)}/"
      upload! File.expand_path("../../../../script/rvm-auto.sh", __FILE__), "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh"
      execute :chmod, "+x", "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh"
    end

    if
      roles(fetch(:rvm1_roles, :all)).any?
    then
      SSHKit.config.command_map.prefix[:rvm].unshift("#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh")

      rvm_prefix = "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh #{fetch(:rvm1_ruby_version)}"
      fetch(:rvm1_map_bins).each do |command|
        SSHKit.config.command_map.prefix[command.to_sym].unshift(rvm_prefix)
      end
    end
  end

  desc "Prints the RVM1 and Ruby version on the target host"
  task :check do
    on roles(fetch(:rvm1_roles, :all)) do
      puts capture(:rvm, "version")
      puts capture(:rvm, "list")
      puts capture(:rvm, "current")
      within fetch(:release_path) do
        puts capture(:ruby, "--version || true")
      end
    end
  end
  before :check, "deploy:updating"
  before :check, 'rvm1:hook'

end

namespace :load do
  task :defaults do
    set :rvm1_ruby_version, "."
    set :rvm1_ruby_install_options, []
    set :rvm1_map_bins,   -> { fetch(:rvm_map_bins, %w{rake gem bundle ruby}) }
    set :rvm1_alias_name, -> { fetch(:application) }
    set :rvm1_auto_script_path, -> { "#{fetch(:deploy_to)}/rvm1scripts" }
  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'rvm1:hook'
end
