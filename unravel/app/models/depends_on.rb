class DependsOn < ActiveRecord::Base
  belongs_to :version
  belongs_to :dependency, :through => :version
end
