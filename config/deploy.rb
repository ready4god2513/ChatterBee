set :application, "jegit"

set :scm, :git
set :repository,  "git@github.com:ready4god2513/ChatterBee.git"
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m

set :user, "user"
set :deploy_via, :remote_cache
set :use_sudo, false

server "173.255.209.57", :app, :web, :db, primary: true