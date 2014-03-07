# encoding: utf-8
# Set your full path to application.
app_path = "/var/www_test"
shared_path = "#{app_path}/shared"
current_path = "#{app_path}/current"

# Set unicorn options
worker_processes 4
preload_app true   # Preload our app for more speed
timeout 180
# 可同时监听 Unix 本地 socket 或 TCP 端口
# listen 9000, :tcp_nopush => true
listen "/tmp/unicorn.test.tabor.ru.sock", :backlog => 64

# Spawn unicorn master worker for user apps (group: apps)
user ENV['USER'] || 'ruby', ENV['USER'] || 'ruby'

# Fill path to your app
working_directory current_path

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

# Set master PID location
pid "#{app_path}/shared/pids/unicorn.pid"

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection  rescue nil
end


before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{current_path}/Gemfile"
end
