set :application, "jegit"
set :repository,  "git@github.com:ready4god2513/ChatterBee.git"

set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

server "173.255.209.57", :app, :web, :db, primary: true