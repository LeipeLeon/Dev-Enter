class App < ActiveRecord::Base
  belongs_to :user
  has_many   :depends_on, :class_name => 'AppDependsOn', :conditions => {:parent_id => nil}
  
  def fill(file)
    result = YAML.load_file(file)
    
    result.each do |row|
      if row[:package]
        parse_package(row[:package])
      end
    end
  end

private
  def parse_package(package, parent_id = nil)
    puts "#{package[:name]}:#{parent_id}"
    dependent = AppDependsOn.find_or_create_by_app_id_and_package_name_and_package_type(self.id, package[:name], package[:type] )
    dependent.update_attributes(
        :version => package[:version], 
        :parent_id => parent_id
      )
    dependent.find_related(package)
    
    unless package[:dependencies].blank?
      package[:dependencies].each do |dependency|
        parse_package(dependency[:package], dependent.id)
      end
    end
  end
end
