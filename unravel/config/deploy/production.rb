role :app, "webd"
role :web, "webd"
role :db,  "webd", :primary => true
set :user, 'webd'
set :rails_env, 'production'
set :deploy_to, "/home/#{user}/apps/#{application}"
