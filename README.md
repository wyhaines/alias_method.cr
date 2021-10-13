![Alias_Method.cr CI](https://img.shields.io/github/workflow/status/wyhaines/alias_method.cr/Alias_Method.cr%20CI?style=for-the-badge&logo=GitHub)
[![GitHub release](https://img.shields.io/github/release/wyhaines/alias_method.cr.svg?style=for-the-badge)](https://github.com/wyhaines/alias_method.cr/releases)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/wyhaines/alias_method.cr/latest?style=for-the-badge)

# [Alias_Method.cr](https://wyhaines.github.io/alias_method.cr/)

Crystal does not natively support the creation of method aliases. This is by design, and the general philosophy of the language is that any given method should only be called by a single name.

However, there are times when one might want to create method aliases. It is certainly possible to hand-write code to do this, but this shard provides a single-line way of aliasing a method. It works for both instance methods and for class methods.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     alias_method:
       github: wyhaines/alias_method.cr
   ```

2. Run `shards install`

## Usage

See the [complete documentation](https://wyhaines.github.io/alias_method.cr/toplevel.html) for full information on this shard and how to use it.

```crystal
require "alias_method"

class MyClass
  def self.add(x, y)
    x + y
  end

  def with(arg)
    yield arg
  end

  def [](val)
    val ** 3
  end

  def chain(ary)
    ary << "a"
  end

  alias_method "self.suma", "self.add" # Class method alias
  alias_method suma, MyClass.add       # Instance method alias to a class method
  alias_method con, :with, 1           # Alias to a method that yields
  alias_method cube, :[]               # Alias to a method name that has punctuation
  alias_method nada, nothing           # Alias to a method that doesn't exist (no error)

  alias_method chain_a, chain          # Create a chain of aliases
  def chain(ary)
    chain_a(ary) << "b"
  end
  alias_method chain_b, chain
  def chain(ary)
     chain_b(ary) << "c"
  end
end

foo = MyClass.new

puts "Call the MyClass.add class method via the class method alias, MyClass.suma: #{MyClass.suma(123, 456)}"
puts "Call the MyClass.add class method via the instance method alias, MyClass#suma: #{foo.suma(456, 789)}"
puts "Call an alias to a method that takes a block: #{foo.con(7) {|x| x ** x}}"
puts "Call a method that forms a chain of aliased methods: #{foo.chain([] of String).inspect}"
```

The shard also implements a `remove_method` macro that can be used to (sort of) remove methods. Crystal does not actually provide any ability to truly undefine a method, so this macro redefines the removed method to throw a `NoMethodError` exception.

```crystal
class MyClass
  def self.add(x, y)
    x + y
  end

  def with(arg)
    yield arg
  end

  # Spanish translations of the method names:
  alias_method "suma", "self.add"
  alias_method "con", "with"

  # Remove the English versions.
  remove_method "with"
  remove_method "self.add"
end
```

## Benchmarks

Aliasing methods has no impact on performance, when compiling in release mode (in development mode, they are approximately 1/2 as fast as unaliased methods).

```
--------------------------------          
   bare, aliased, alias 968.52M (  1.03ns) (± 2.71%)  0.0B/op        fastest
bare, aliased, original 965.20M (  1.04ns) (± 2.67%)  0.0B/op   1.00× slower
        bare, unaliased 965.87M (  1.04ns) (± 2.65%)  0.0B/op   1.00× slower
--------------------------------
   with arguments, aliased, alias 970.17M (  1.03ns) (± 2.43%)  0.0B/op        fastest
with arguments, aliased, original 962.70M (  1.04ns) (± 2.55%)  0.0B/op   1.01× slower
        with arguments, unaliased 964.02M (  1.04ns) (± 2.44%)  0.0B/op   1.01× slower
--------------------------------
   with block, aliased, alias 966.57M (  1.03ns) (± 2.33%)  0.0B/op        fastest
with block, aliased, original 961.09M (  1.04ns) (± 4.18%)  0.0B/op   1.01× slower
        with block, unaliased 966.30M (  1.03ns) (± 2.40%)  0.0B/op   1.00× slower
--------------------------------
   with yield, aliased, alias 968.25M (  1.03ns) (± 2.17%)  0.0B/op        fastest
with yield, aliased, original 966.45M (  1.03ns) (± 2.49%)  0.0B/op   1.00× slower
        with yield, unaliased 966.61M (  1.03ns) (± 2.49%)  0.0B/op   1.00× slower
--------------------------------
   class method, aliased, alias 968.68M (  1.03ns) (± 2.83%)  0.0B/op        fastest
class method, aliased, original 966.72M (  1.03ns) (± 2.63%)  0.0B/op   1.00× slower
        class method, unaliased 967.43M (  1.03ns) (± 2.27%)  0.0B/op   1.00× slower
--------------------------------
```

One interesting thing to note is that there seems to be a very slight bias in benchmark outcomes, based on the order of the code being benchmarked. In general, the first block tends to benchmark very slightly faster than the last, which means that if the order of each of the items in the benchmark is reversed, so that unaliased is first, and the aliased method is last, the above results would likely lean towards unaliased first. However, the effect is very slight. There is no appreciable difference in performance, in release mode code, between an aliased method and an unaliased method.

## Development

If you wish to contribute to this shard, please fork the repository, and work from a branch within your own fork. When your work is complete (and has appropriate specs), submit a PR. Thank you!

## Contributing

1. Fork it (<https://github.com/wyhaines/alias_method/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/wyhaines) - creator and maintainer

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/wyhaines/alias_method.cr?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/wyhaines/alias_method.cr?style=for-the-badge)
