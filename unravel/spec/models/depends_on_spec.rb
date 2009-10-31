require 'spec_helper'

describe DependsOn do
  before(:each) do
    @valid_attributes = {
      :dependency_id => 1,
      :version_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    DependsOn.create!(@valid_attributes)
  end
end
