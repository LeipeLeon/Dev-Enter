class AppDependsOn < ActiveRecord::Base
  belongs_to :app
  has_many :packages
  
end
