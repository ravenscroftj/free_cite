role :app, "huey.privatedisplay.net"
set :application, "FreeCite"
set :repository,  "git@github.com:miriam/free_cite.git"
set :branch, "huey_deploy"
set :user, "www"

set :deploy_to, "/www/freecite"
set :deploy_via, "remote_cache"
set :scm, :git
default_run_options[:pty] = true


namespace :deploy do
  namespace :monit do
    set :monit_group, "freecite"
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} mongrel using monit" 
      task t, :roles => :app do
        sudo "/usr/bin/monit #{t.to_s} -g #{monit_group} all" 
      end
    end
  end
  desc "restart mongrel using monit" 
  task :restart, :roles => :app do
    deploy.monit.restart
  end
  desc "start mongrel using monit" 
  task :start, :roles => :app do
    deploy.monit.start
  end
  desc "stop mongrel using monit" 
  task :stop, :roles => :app do
    deploy.monit.stop
  end
end

