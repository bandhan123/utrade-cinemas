lock "~> 3.17.2"

#server 'server', port: 7171, roles: [:web, :app, :db], primary: true
#set :rvm_map_bins, %w{gem rake ruby rails bundle}
set :application, 'utrade-cinema'
set :repo_url, 'git@github.com:bandhan123/uTrade-cinema.git'
set :branch, ENV["BRANCH"] if ENV["BRANCH"]
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to, '/home/ubuntu/code/utrade-cinema'
set :rvm_type, :user
set :rvm_ruby_version, '3.1.0'
set :rvm_binary, '~/.rvm/bin/rvm'
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads public/videos}
set :log_level, :debug
# Defaults to 'db'
set :migration_role, 'migrator'

# Defaults to false
# Skip migration if files in db/migrate were not modified
set :conditionally_migrate, true

# Puma
set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"    #accept array for multi-bind
set :puma_default_control_app, "unix://#{shared_path}/tmp/sockets/pumactl.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_role, :app
set :puma_worker_timeout, nil
set :puma_init_active_record, false
set :puma_preload_app, true
set :puma_threads, [0, 16]
set :puma_workers, 0

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'db migrate'
  task :migrate do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        with rails_env: fetch(:puma_env) do
          execute :rake, "db:migrate"
        end
      end
    end
  end

  after :finishing, :restart
end


after "deploy:check",     "puma:config"
after "deploy:published", "puma:restart"


