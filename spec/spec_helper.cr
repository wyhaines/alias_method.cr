require "spec"
require "../src/alias_method"

class CrossClassAliasTest
  def self.bare_crossclass
    "abc"
  end
end

class AliasTestClass
  def self.bare_class_method
    77
  end

  def self.other_bare_class_method
    99
  end

  def [](val : Number)
    val * val * val
  end

  def [](val : String)
    val + val + val
  end

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
    {one => two}
  end

  def with_typed_args_and_return_type(one : String, two : String) : Hash(String, String)
    {one => two}
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

  def with_splat(*args)
    args
  end

  def with_double_splat(x, **other)
    {x, other}
  end

  def bare_and_remove
    "There can be only one."
  end

  private def explicitly_private
    "private"
  end

  def call_explicitly_private
    explicitly_private
  end

  def call_new_explicitly_private
    new_explicitly_private
  end

  def chain(ary)
    ary << "a"
  end

  alias_method "new_get", "[]"
  alias_method also_new_get, :[]
  alias_method new_bare, bare
  alias_method new_bare_with_return_type, bare_with_return_type
  alias_method new_with_args, with_args
  alias_method :new_with_args_and_return_type, :with_args_and_return_type
  alias_method new_with_typed_args, with_typed_args
  alias_method new_with_typed_args_and_return_type, with_typed_args_and_return_type
  alias_method new_with_capture, "with_capture"
  alias_method new_with_arg_and_capture, with_arg_and_capture
  alias_method new_with_arg_and_capture_and_return_type, with_arg_and_capture_and_return_type
  alias_method new_with_yield, with_yield, 1
  alias_method new_with_splat, with_splat
  alias_method new_with_double_splat, with_double_splat

  alias_method "new_bare_and_remove", "bare_and_remove"
  alias_method just_remove_me, bare_and_remove
  remove_method :bare_and_remove
  remove_method just_remove_me

  alias_method AliasTestClass.new_bare_class_method, AliasTestClass.bare_class_method
  alias_method "self.new_other_bare_class_method", "self.other_bare_class_method"

  alias_method new_bare_crossclass, CrossClassAliasTest.bare_crossclass

  alias_method new_explicitly_private, explicitly_private

  alias_method chain_a, chain, redefine: true

  def chain(ary)
    chain_a(ary) << "b"
  end
  alias_method chain_b, chain, redefine: true
  def chain(ary)
    chain_b(ary) << "c"
  end
  alias_method chain_c, chain, redefine: true

end
