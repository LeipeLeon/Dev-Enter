class AppDependsOn < ActiveRecord::Base
  belongs_to :app
  has_many :packages
  
  acts_as_tree
  def find_related(package)
    # find a matching package in our repo
    Package.find_by_name_and_package_type
  end
end
