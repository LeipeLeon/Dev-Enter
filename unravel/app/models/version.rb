class Version < ActiveRecord::Base
  belongs_to :dependency
  has_many   :depends_on
end
