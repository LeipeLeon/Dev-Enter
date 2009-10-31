set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "unravel"
set :scm, :git
default_run_options[:pty] = true
set :repository, "git@github.com:LeipeLeon/#{app_name}.git"

set :repository_cache, "git_master"
set :deploy_via, :remote_cache
set :branch, "master"
set :scm_verbose, :true

set :use_sudo, false

set :chmod777, %w(public log)

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  [:import, :export].each do |t|
    desc "#{t} content for comatose, do a deploy first"
    task ('coma_'+t.to_s).to_sym, :roles => :app do 
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")

      run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} comatose:data:#{t}"
    end
  end

  desc "Set the proper permissions for directories and files"
  task :before_restart do
    run(chmod777.collect do |item|
      "chmod 777 -R #{current_path}/#{item}"
    end.join(" && "))
  end

  desc "Create shared/config" 
  task :after_setup do
    # copy dev version of database.yml to alter later
    run "if [ ! -d "#{deploy_to}/#{shared_dir}/config" ] ; then mkdir #{deploy_to}/#{shared_dir}/config ; fi"
  end

  after "deploy:finalize_update", "deploy:symlink_config"
  desc "Link to database.yml in shared/config" 
  task :symlink_config do
    ['database'].each {|yml_file|
      # remove  the git version of yml_file.yml
      run "if [ -e "#{release_path}/config/#{yml_file}.yml" ] ; then rm #{release_path}/config/#{yml_file}.yml; fi"
    
      # als shared conf bestand nog niet bestaat
      run "if [ ! -e "#{deploy_to}/#{shared_dir}/config/#{yml_file}.yml" ] ; then cp #{deploy_to}/#{shared_dir}/#{repository_cache}/config/#{yml_file}.example.yml #{deploy_to}/#{shared_dir}/config/#{yml_file}.yml; fi"
    
      # link to the shared yml_file.yml
      run "ln -nfs #{deploy_to}/#{shared_dir}/config/#{yml_file}.yml #{release_path}/config/#{yml_file}.yml" 
    }
    # set deployment date
    run "date > #{current_release}/DATE"
  end

  after "deploy:symlink", "deploy:update_crontab"
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end


  desc "Set .htacces to RailsEnv staging"
  task :update_htaccess, :roles => :app do
    run "echo 'RailsEnv staging' > #{current_path}/public/.htaccess"
  end
  
  # desc "Copy system directory from live site to local"
  # task :copy_system do
  #   run "rsync -avz /home/sneaker/apps/#{application}/#{shared_dir}/system/ #{deploy_to}/#{shared_dir}/system/"
  # end
end

namespace :db do
  require 'yaml'
  
  def mysql_dump(environment, file)
    dbp = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'database.yml'))).result)[environment]
    run "mysqldump -u #{dbp['username']} --password=#{dbp['password']} #{dbp['database']} | bzip2 -c > #{file}"  do |ch, stream, out|
      puts out
    end
  end
  
  desc "Copy production db to the staging db" 
  task :copy_production_to_staging, :roles => :db, :only => { :primary => true } do
    filename = "#{application}.dump.#{Time.now.to_i}.sql.bz2" 
    file = "/tmp/#{filename}" 
    on_rollback { delete file }
    
    # Dump production
    mysql_dump('production', file)
    
    # load in staging
    dbs = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'database.yml'))).result)['staging']
    logger.debug "delete all tables in staging database" 
    run "mysqldump -u #{dbs['username']} --password=#{dbs['password']} --add-drop-table --no-data #{dbs['database']} | grep ^DROP | mysql -u #{dbs['username']} --password=#{dbs['password']} #{dbs['database']}"
    logger.debug "Loading #{filename} into staging database" 
    run "bzip2 -cd #{file} | mysql -u #{dbs['username']} --password=#{dbs['password']} #{dbs['database']}"
    
    run "rm #{file}" 
    
    # run "rsync -avz /home/sneaker/apps/#{application}/#{shared_dir}/system/ #{deploy_to}/#{shared_dir}/system/"
  end

  desc "Backup the production db to local filesystem" 
  task :backup_to_local, :roles => :db, :only => { :primary => true } do
    filename = "#{application}.dump.#{Time.now.to_i}.sql.bz2" 
    file = "/tmp/#{filename}" 
    on_rollback { delete file }
    
    # Dump production
    mysql_dump('production', file)
    
    `mkdir -p #{File.dirname(__FILE__)}/../backups/`
    get file, "backups/#{filename}" 
    run "rm #{file}" 
  end

  desc "Copy the latest backup to the local development database" 
  task :import_backup do
    filename = `ls -tr backups | tail -n 1`.chomp
    if filename.empty?
      logger.important "No backups found" 
    else
      ddb = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'database.yml'))).result)['development']
      logger.debug "delete all tables in development database" 
      `mysqldump -u #{ddb['username']} --password=#{ddb['password']} --add-drop-table --no-data #{ddb['database']} | grep ^DROP | mysql -u #{ddb['username']} --password=#{ddb['password']} #{ddb['database']}`
      logger.debug "Loading backups/#{filename} into local development database" 
      `bzip2 -cd backups/#{filename} | mysql -u #{ddb['username']} --password=#{ddb['password']} #{ddb['database']}`
      logger.debug "Running migrations" 
      `rake db:migrate`
      # logger.debug "Syncing assets to local machine" 
      # `rake assets:sync`
    end
  end

  desc "Backup the remote production database to local filesystem and import it to the local development database" 
  task :backup_and_import do
    backup_to_local
    import_backup
  end
end

end
