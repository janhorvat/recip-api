require "mina/bundler"
require "mina/rails"
require "mina/git"
require "mina/rvm"
require "mina-extras/git"
require "mina-extras/puma"

set :branch, current_git_branch!

case branch!
when "master"
  set :rails_env, "production"
  set :domain, "52.58.16.37"
  set :deploy_to, "/var/www/photolotto"
  set :repository, "git@github.com:janhorvat/recip-api.git"
  set :branch, "master"
  set :user, "ubuntu"
  set :ssh_options, "-A"
  set :forward_agent, true
end

set :shared_paths, [
  "config/database.yml",
  ".env",
  "log",
  "config/puma.rb",
  "sockets/puma.state",
  "sockets",
  "pids"
]

task :environment do
  invoke :'rvm:use[ruby-2.3.0@default]'
end

task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/sockets")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/pids")

  queue! %(touch "#{deploy_to}/#{shared_path}/config/database.yml")
  queue  %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'.")

  queue! %(touch "#{deploy_to}/#{shared_path}/config/puma.rb")
  queue  %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/puma.rb'.")

  queue! %(touch "#{deploy_to}/#{shared_path}/sockets/puma.state")
  queue  %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/sockets/puma.state'.")

  queue! %(touch "#{deploy_to}/#{shared_path}/sockets")
  queue  %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/sockets'.")

  queue! %(touch "#{deploy_to}/#{shared_path}/.env")
  queue  %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/.env'.")

  queue! %(chmod g=rx,u=rwx "#{deploy_to}/shared")
  queue! %(chmod g=rx,u=rwx "#{deploy_to}/releases")
end

desc "Deploys the current version to the server."
task deploy: :environment do
  deploy do
    invoke :"git:clone"
    invoke :"deploy:link_shared_paths"
    invoke :"bundle:install"
    invoke :"rails:db_migrate"
    invoke :"rails:assets_precompile"
    invoke :"deploy:cleanup"

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
      invoke :"puma:stop"
      invoke :"puma:start"
    end
  end
end
