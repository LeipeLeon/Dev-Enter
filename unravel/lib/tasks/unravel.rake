desc  "Import file"

namespace :unravel do
  task :import => :environment do
    a = App.find_by_app_name('bort')
    a.fill(ENV['FILE'])
  end
  
  task :spider => :environment do
    
  end
end