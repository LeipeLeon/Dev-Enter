class AppDependsOn < ActiveRecord::Base
  belongs_to :app
  has_many :packages
  
  acts_as_tree
  
  def find_related(package)
    # find a matching package in our repo
    package = Package.find_or_create_by_name_and_package_type_and_homepage_and_description(
      :name          => package[:name],
      :package_type  => package[:type],
      :homepage      => package[:homepage],
      :description   => package[:description]
    )
    self.update_attribute(:package_id, package.id)
  end
end
