require "spec"
require "../src/alias_method"

class AliasTestClass
  def bare
    7
  end

  def with_args(one, two)
    [one, two]
  end

  def with_capture(arg, &block : Int32 -> Int32)
    block.call(arg)
  end

  def with_yield(arg)
    yield arg
  end

  alias_method("new_bare", "bare")
end