require 'spec_helper'

describe Version do
  before(:each) do
    @valid_attributes = {
      :dependency_id => 1,
      :version => "value for version",
      :version_mayor => 1,
      :version_minor => 1,
      :version_bug => 1,
      :url => "value for url"
    }
  end

  it "should create a new instance given valid attributes" do
    Version.create!(@valid_attributes)
  end
end
