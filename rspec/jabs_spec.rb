require 'rspec/jabs_spec_helper'

describe Jabs do
  it "inherits Module" do
    Jabs.class.should == Module
  end
  
  it "has an Engine Class" do
    Jabs.constants.should include("Engine")
  end
  
  it "has a precompiler class" do
    Jabs.constants.should include("Precompiler")
  end
end
