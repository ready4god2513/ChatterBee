set :application, "jegit"

set :scm, :git
set :repository,  "git@github.com:ready4god2513/ChatterBee.git"
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m

set :user, "user"
set :deploy_via, :remote_cache
set :use_sudo, false

server "173.255.209.57", :app, :web, :db, primary: true

set :deploy_to, "/sites/brandon/jegit.com"


namespace :deploy do
  desc "Tell Passenger to restart."
  task :restart, :roles => :web do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end