class Package < ActiveRecord::Base
  has_many :versions
  belongs_to :app_depends_on
  # belongs_to :app, :through => :app_depends_on
end
