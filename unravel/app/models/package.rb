require 'rest_client'
require 'json'

class Package < ActiveRecord::Base
  has_many :versions, :order => "version DESC"
  has_many :app_depends_ons
  # belongs_to :app, :through => :app_depends_on
  # named_scope :version, :order => {:verion => }
  
  def before_create
    update_version
  end

  def update_version
    if 'gem' == self.package_type
      begin
        @response = JSON.parse(RestClient.get("http://gemcutter.org/gems/#{self.name}.json"))
        self.versions << Version.new(:version => @response["version"])
      rescue RestClient::ResourceNotFound
        "No version found for #{self.name}"
      end
    end
  end
end
