![Alias_Method.cr CI](https://img.shields.io/github/workflow/status/wyhaines/alias_method.cr/Alias_Method.cr%20CI?style=for-the-badge&logo=GitHub)
[![GitHub release](https://img.shields.io/github/release/wyhaines/alias_method.cr.svg?style=for-the-badge)](https://github.com/wyhaines/alias_method.cr/releases)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/wyhaines/alias_method.cr/latest?style=for-the-badge)

# Alias_Method.cr

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

```crystal
require "alias_method"
```

The `alias_method(to, from, yield_arity)` macro is used to create method aliases. For most usage, only the `to` and the `from` arguments are required. The `yield_arity` argument is optional, only applies when aliasing a method that yields, and defaults to `0`.

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
end

foo = Foo.new

puts Foo.suma(123, 456)
puts(foo.con(7) do |x|
  x ** x
end)
```

The macro will not throw any errors if the method being aliased can not be found.

```crystal
class MyClass
  alias_method "nada", "nothing"
end
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
