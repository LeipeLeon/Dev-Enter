require 'spec_helper'

describe AppDependsOn do
  before(:each) do
    @valid_attributes = {
      :app_id => 1,
      :dependency_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    AppDependsOn.create!(@valid_attributes)
  end
end
