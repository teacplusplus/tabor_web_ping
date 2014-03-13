set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
set :use_sudo, false
set :branch, "master"
set :user, "root"
set :application, "tabor_test"
set :unicorn_pid, "/var/www_test/shared/pids/unicorn.pid"
role :web, "188.72.65.185"                          # Your HTTP server, Apache/etc
role :app, "188.72.65.185"                          # This may be the same as your `Web` server
role :db,  "188.72.65.185", :primary => true # This is where Rails migrations will run
set :deploy_to, "/var/www_test"
set :default_environment, {
    'PATH' => "/usr/local/rvm/gems/ruby-2.1.0/bin:/usr/local/rvm/gems/ruby-2.1.0@global/bin:/usr/local/rvm/rubies/ruby-2.1.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin",
    'RUBY_VERSION' => 'ruby 2.1.0p0',
    'GEM_HOME' => "/usr/local/rvm/gems/ruby-2.1.0",
    'GEM_PATH' => "/usr/local/rvm/gems/ruby-2.1.0:/usr/local/rvm/gems/ruby-2.1.0@global"
}



set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :db,  "your slave db-server here"

set :repository, "git@github.com:teacplusplus/tabor_web_ping.git"

set :deploy_via, :remote_cache
set :rails_env, :production

set :keep_releases, 3


namespace :deploy do

  desc "Start unicorn server"
  task :start do
    puts "Start unicorn"
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  desc "Stop unicorn server"
  task :stop do
    puts "Stop unicorn"
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

  desc "restart server"
  task :restart do

  end
end



desc "bundle install"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"
end

before "whenever:update_crontab", 'bundle_install'
after "deploy:restart", 'deploy:stop'
after "deploy:stop", 'deploy:start'





