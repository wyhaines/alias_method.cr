require "./spec_helper"

describe AliasMethod do
  it "can alias a method that takes no arguments" do
    test = AliasTestClass.new

    test.bare.should eq 7
  end
end
