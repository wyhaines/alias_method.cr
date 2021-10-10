require "./spec_helper"

describe AliasMethod do
  it "can alias a method that takes no arguments" do
    test = AliasTestClass.new

    test.bare.should eq 7
    test.new_bare.should eq 7
  end

  it "can alias a method that has a typed return value" do
    test = AliasTestClass.new

    test.bare_with_return_type.should eq 77
    test.new_bare_with_return_type.should eq 77
    test.new_bare_with_return_type.class.should eq UInt8
  end

  it "can alias a method that takes simple arguments" do
    test = AliasTestClass.new

    test.with_args(1, 3).should eq [1, 3]
    test.new_with_args(1, 3).should eq [1, 3]
  end

  it "can alias a method that takes simple arguments and has a typed return value" do
    test = AliasTestClass.new

    test.with_args_and_return_type(1, 3).should eq [1, 3]
    test.new_with_args_and_return_type(1, 3).should eq [1, 3]
    test.new_with_args_and_return_type(1, 3).class.should eq Array(Int32)
  end

  it "can alias a method that has specifically typed arguments" do
    test = AliasTestClass.new

    test.with_typed_args("A", "a").should eq ({"A" => "a"})
    test.new_with_typed_args("A", "a").should eq ({"A" => "a"})
  end

  it "can alias a method that takes typed arguments and returns a typed value" do
    test = AliasTestClass.new

    test.with_typed_args_and_return_type("A", "a").should eq ({"A" => "a"})
    test.new_with_typed_args_and_return_type("A", "a").should eq ({"A" => "a"})
    test.new_with_typed_args_and_return_type("A", "a").class.should eq Hash(String, String)
  end

  it "can alias a method that captures a block" do
    test = AliasTestClass.new

    test.with_capture { 7 }.should eq 7
    test.new_with_capture { 7 }.should eq 7
  end

  it "can alias a method that captures a block and has a typed return value" do
    test = AliasTestClass.new

    test.with_arg_and_capture(7) { |x| x*x }.should eq 49
    test.new_with_arg_and_capture(8) { |x| x*x }.should eq 64
  end

  it "can alias a method that captures a block and has a typed return value" do
    test = AliasTestClass.new

    test.with_arg_and_capture_and_return_type(7) { |x| x*x }.should eq 49
    test.new_with_arg_and_capture_and_return_type(8) { |x| x*x }.should eq 64
  end

  it "can alias a method that yields" do
    test = AliasTestClass.new

    test.with_yield(7) { |n| n * n }.should eq 49
    test.new_with_yield(7) { |n| n * n }.should eq 49
  end

  it "can remove a method" do
    test = AliasTestClass.new

    test.new_bare_and_remove.should eq "There can be only one."
    expect_raises(NoMethodError) do
      test.bare_and_remove
    end
  end

  it "can alias class methods" do
    AliasTestClass.bare_class_method.should eq 77
    AliasTestClass.new_bare_class_method.should eq 77
  end

  
end
