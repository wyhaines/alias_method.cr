require "spec"
require "../src/alias_method"

class AliasTestClass
  def bare
    7
  end

  def bare_with_return_type : UInt8
    77_u8
  end

  def with_args(one, two)
    [one, two]
  end

  def with_args_and_return_type(one, two) : Array(Int32)
    [one, two]
  end

  def with_typed_args(one : String, two : String)
    { one => two }
  end

  def with_typed_args_and_return_type(one : String, two : String) : Hash(String, String)
    { one => two }
  end

  def with_capture(&block : -> Int32)
    block.call
  end

  def with_arg_and_capture(arg, &block : Int32 -> Int32)
    block.call(arg)
  end

  def with_arg_and_capture_and_return_type(arg, &block : Int32 -> Int32) : Int32
    block.call(arg)
  end

  def with_yield(arg)
    yield arg
  end

  alias_method("new_bare", "bare")
  alias_method("new_bare_with_return_type", "bare_with_return_type")
  alias_method("new_with_args", "with_args")
  alias_method("new_with_args_and_return_type", "with_args_and_return_type")
  alias_method("new_with_typed_args", "with_typed_args")
  alias_method("new_with_typed_args_and_return_type", "with_typed_args_and_return_type")
  alias_method("new_with_capture", "with_capture")
  alias_method("new_with_arg_and_capture", "with_arg_and_capture")
  alias_method("new_with_arg_and_capture_and_return_type", "with_arg_and_capture_and_return_type")
  alias_method("new_with_yield", "with_yield")
end