require "./spec_helper"

describe AliasMethod do
  test = uninitialized AliasTestClass

  before_each do
    test = AliasTestClass.new
  end

  it "can alias a method named with punctuation (like [])" do
    test[3].should eq 27
    test.new_get(4).should eq 64
    test.also_new_get(5).should eq 125
  end

  it "will alias all of the overloads of a method" do
    test["a"].should eq "aaa"
    test.new_get("a").should eq "aaa"
    test.also_new_get("a").should eq "aaa"
  end

  it "can alias a method that takes no arguments" do
    test.bare.should eq 7
    test.new_bare.should eq 7
  end

  it "can alias a method that has a typed return value" do
    test.bare_with_return_type.should eq 77
    test.new_bare_with_return_type.should eq 77
    test.new_bare_with_return_type.class.should eq UInt8
  end

  it "can alias a method that takes simple arguments" do
    test.with_args(1, 3).should eq [1, 3]
    test.new_with_args(1, 3).should eq [1, 3]
  end

  it "can call the aliased method, using keyword arguments" do
    test.with_args(one: 1, two: 3).should eq [1, 3]
    test.new_with_args(one: 1, two: 3).should eq [1, 3]
  end

  it "can alias a method that takes simple arguments and has a typed return value" do
    test.with_args_and_return_type(1, 3).should eq [1, 3]
    test.new_with_args_and_return_type(1, 3).should eq [1, 3]
    test.new_with_args_and_return_type(1, 3).class.should eq Array(Int32)
  end

  it "can alias a method that has specifically typed arguments" do
    test.with_typed_args("A", "a").should eq ({"A" => "a"})
    test.new_with_typed_args("A", "a").should eq ({"A" => "a"})
  end

  it "can alias a method that takes typed arguments and returns a typed value" do
    test.with_typed_args_and_return_type("A", "a").should eq ({"A" => "a"})
    test.new_with_typed_args_and_return_type("A", "a").should eq ({"A" => "a"})
    test.new_with_typed_args_and_return_type("A", "a").class.should eq Hash(String, String)
  end

  it "can alias a method that captures a block" do
    test.with_capture { 7 }.should eq 7
    test.new_with_capture { 7 }.should eq 7
  end

  it "can alias a method that has a splat argument" do
    expected_answer = {1, 2, 3}

    test.with_splat(1,2,3).should eq expected_answer
    test.new_with_splat(1,2,3).should eq expected_answer
  end

  it "can alias a method that has a double splat argument" do
    expected_answer = {123, {data: 456}}

    test.with_double_splat(123, data: 456).should eq expected_answer
    test.new_with_double_splat(123, data: 456).should eq expected_answer
  end

  it "can alias a method that captures a block and has a typed return value" do
    test.with_arg_and_capture(7) { |x| x*x }.should eq 49
    test.new_with_arg_and_capture(8) { |x| x*x }.should eq 64
  end

  it "can call an aliased method using keyword arguments, when that method captures a block" do
    test.with_arg_and_capture(arg: 7) { |x| x*x }.should eq 49
    test.new_with_arg_and_capture(arg: 8) { |x| x*x }.should eq 64
  end

  it "can alias a method that captures a block and has a typed return value" do
    test.with_arg_and_capture_and_return_type(7) { |x| x*x }.should eq 49
    test.new_with_arg_and_capture_and_return_type(8) { |x| x*x }.should eq 64
  end

  it "can alias a method that yields" do
    test.with_yield(7) { |n| n * n }.should eq 49
    test.new_with_yield(7) { |n| n * n }.should eq 49
  end

  it "can remove a method" do
    test.new_bare_and_remove.should eq "There can be only one."
    expect_raises(NoMethodError) do
      test.bare_and_remove
    end
  end

  it "can alias class methods" do
    AliasTestClass.bare_class_method.should eq 77
    AliasTestClass.new_bare_class_method.should eq 77
  end

  it "can alias private methods" do
    test.call_explicitly_private.should eq "private"
    test.call_new_explicitly_private.should eq "private"
  end

  it "can chain method calls with aliases" do
    test.chain_c([] of String).should eq ["a", "b", "c"]
  end
end
