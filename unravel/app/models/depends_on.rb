class DependsOn < ActiveRecord::Base
  belongs_to :version
  belongs_to :package, :through => :version
end
