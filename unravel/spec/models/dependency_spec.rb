require 'spec_helper'

describe Dependency do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :url => "value for url"
    }
  end

  it "should create a new instance given valid attributes" do
    Dependency.create!(@valid_attributes)
  end
end
