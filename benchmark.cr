require "benchmark"
require "./src/alias_method.cr"

class BenchmarkMe
  def bare
    7
  end

  def bare_tba
    7
  end

  def args(a)
    a + a
  end

  def args_tba(a)
    a + a
  end

  def block_capture(&block)
    block.call
  end

  def block_capture_tba(&block)
    block.call
  end

  def block_yield
    yield
  end

  def block_yield_tba
    yield
  end

  def self.class_bare
    77
  end

  def self.class_bare_tba
    77
  end

  alias_method("new_bare_tba", "bare_tba")
  alias_method("new_args_tba", "args_tba")
  alias_method("new_block_capture_tba", "block_capture_tba")
  alias_method("new_block_yield_tba", "block_yield_tba")
  alias_method("new_class_bare_tba", "self.class_bare_tba")
end

bm = BenchmarkMe.new

puts "--------------------------------"

Benchmark.ips do |ips|
  # Benchmark the bare method calls, with no arguments.
  ips.report("bare, aliased, alias") { bm.new_bare_tba + bm.new_bare_tba }
  ips.report("bare, aliased, original") { bm.bare_tba + bm.bare_tba }
  ips.report("bare, unaliased") { bm.bare + bm.bare }
end

puts "--------------------------------"

Benchmark.ips do |ips|
  # Benchmark a method call with a basic set of arguments.
  ips.report("with arguments, aliased, alias") { bm.new_args_tba(7) }
  ips.report("with arguments, aliased, original") { bm.args_tba(7) }
  ips.report("with arguments, unaliased") { bm.args(7) }
end

puts "--------------------------------"

Benchmark.ips do |ips|
  # Benchmark a method call with a block.
  ips.report("with block, aliased, alias") { bm.new_block_capture_tba { 7 + 7 } }
  ips.report("with block, aliased, original") { bm.block_capture_tba { 7 + 7 } }
  ips.report("with block, unaliased") { bm.block_capture { 7 + 7 } }
end

puts "--------------------------------"

Benchmark.ips do |ips|
  # Benchmark a method call which yields.
  ips.report("with yield, aliased, alias") { bm.new_block_yield_tba { 7 + 7 } }
  ips.report("with yield, aliased, original") { bm.block_yield_tba { 7 + 7 } }
  ips.report("with yield, unaliased") { bm.block_yield { 7 + 7 } }
end

puts "--------------------------------"

Benchmark.ips do |ips|
  # Benchmark a class method call.
  ips.report("class method, aliased, alias") { BenchmarkMe.new_class_bare_tba + BenchmarkMe.new_class_bare_tba }
  ips.report("class method, aliased, original") { BenchmarkMe.class_bare_tba + BenchmarkMe.class_bare_tba }
  ips.report("class method, unaliased") { BenchmarkMe.class_bare + BenchmarkMe.class_bare }
end

puts "--------------------------------"
