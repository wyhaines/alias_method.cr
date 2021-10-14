module AliasMethod
  VERSION = "0.2.0"

  # When an alias is created, the macro will assign an annotation to it that
  # does the double duty of clearly marking that a method is an alias, and also
  # carrying a pointer back to the canonical method, in the `:parent` key.
  annotation Alias; end
end

# This exception will be thrown if a method that has been removed via
# the `remove_method` macro is called.
class NoMethodError < Exception
end

# The `alias_method` macro is used to create method aliases.
#
# Macro arguments:
#
# * `new`: the alias; the new name for the method. This is required.
# * `old`: the original method name; this is the method that the alias will point to.
# * `yield_arity`: the expected arity of the block that the method being aliased will yield to. This argument is optional, and is only required is the aliased method yields, and the block that it yields to is expected to have an arity other than `0`.
# * `redefine`: normally, when a method is aliased for the first time, a new, canonical copy of it is created, and both the original name and the alias point to the same version of the method. If additional aliases to that same method are created, that canonical version of the method will not be redefined; all aliases will point to the same implementation. When creating alias method chains, however, the aforementioned behavior prevents the formation of a chain of method calls. Each newly created alias will point to the same method.
#
# For example, `alias_method get, :[]` creates an alias from the `[]()` method to
# the `get()` method.
#
# The methods to be aliased can be specified as symbol literals, string literals, or
# via direct method references. The macro will not throw any errors if the method
# being aliased can not be found.For example, consider the following examples:
#
# ```
# class MyClass
#   def self.add(x, y)
#     x + y
#   end
#
#   def with(arg)
#     yield arg
#   end
#
#   def [](val)
#     val ** 3
#   end
#
#   def chain(ary)
#     ary << "a"
#   end
#
#   alias_method "self.suma", "self.add" # Class method alias
#   alias_method suma, MyClass.add       # Instance method alias to a class method
#   alias_method con, :with, 1           # Alias to a method that yields
#   alias_method cube, :[]               # Alias to a method name that has punctuation
#   alias_method nada, nothing           # Alias to a method that doesn't exist (no error)
#
#   alias_method chain_a, chain          # Create a chain of aliases
#   def chain(ary)
#     chain_a(ary) << "b"
#   end
#   alias_method chain_b, chain
#   def chain(ary)
#      chain_b(ary) << "c"
#   end
# end
#
# foo = MyClass.new
#
# puts "Call the MyClass.add class method via the class method alias, MyClass.suma: #{MyClass.suma(123, 456)}"
# puts "Call the MyClass.add class method via the instance method alias, MyClass#suma: #{foo.suma(456, 789)}"
# puts "Call an alias to a method that takes a block: #{foo.con(7) {|x| x ** x}}"
# puts "Call a method that forms a chain of aliased methods: #{foo.chain([] of String).inspect}"
#
# ```
#
macro alias_method(new, old, yield_arity = 0, redefine = false)
  {%
    # Figure out where the _old_ method lives....

    method_name = nil
    if old.class_name == "Call"
      # This is the easy way, and the way that the macro should normally be used.
      # The method to lookup is directly referenced in a Call.
      if old.receiver.is_a?(Nop)
        receiver = @type
      else
        receiver = old.receiver.resolve.class
      end
      method_name = old.name
    elsif old.includes?(".")
      # It's a class method.
      receiver_name, method_name = old.split(".")

      if receiver_name == "self"
        receiver = @type.class
      else
        receiver = nil
        search_paths = [@top_level]
        search_paths << @type.class unless receiver_name[0..1] == "::"

        search_paths.each do |search_path|
          unless receiver
            found_the_receiver = true
            parts = receiver_name.split("::")
            parts.each do |part|
              if found_the_receiver
                constant_id = search_path.constants.find { |c| c.id == part }
                if !constant_id
                  found_the_receiver = false
                else
                  search_path = search_path.constant(constant_id)
                  found_the_receiver = false if search_path.nil?
                end
              end
            end

            if found_the_receiver
              receiver = search_path.class
            end
          end
        end
      end
    else
      # It refers to an instance method within the current @type.
      receiver = @type
      method_name = old
    end

    # Figure out where the _to_  method lives....
    new_method_name = nil
    if new.class_name == "Call"
      if new.receiver.is_a?(Nop)
        new_receiver = @type
      else
        new_receiver = new.receiver.resolve.class
      end
      new_method_name = new.name
    elsif new.includes?(".")
      new_receiver_name, new_method_name = new.split(".")

      if new_receiver_name == "self"
        new_receiver = @type.class
      else
        new_receiver = nil
        search_paths = [@top_level]
        search_paths << @type.class unless receiver_name[0..1] == "::"

        search_paths.each do |search_path|
          unless new_receiver
            found_the_new_receiver = true
            parts = new_receiver_name.split("::")
            parts.each do |part|
              if found_the_new_receiver
                constant_id = search_path.constants.find { |c| c.id == part }
                if !constant_id
                  found_the_new_receiver = false
                else
                  search_path = search_path.constant(constant_id)
                  found_the_new_receiver = false if search_path.nil?
                end
              end
            end

            if found_the_new_receiver
              new_receiver = search_path.class
            end
          end
        end
      end
    else
      # It refers to an instance method within the current @type.
      new_receiver = @type
      new_method_name = new
    end

    new_name = nil
    methods = receiver ? receiver.methods.select { |m| m.name.id == method_name } : [] of Nil
  %}
  {% for method in methods %}
  {%
    skip_origin = false
    # If the original method already has a new name, don't create it again.
    if ann = method.annotation(AliasMethod::Alias)
      if ann[:parent]
        skip_origin = true
        new_name = ann[:parent]
      end
    end

    method_args = method.args
    method_arg_names = method.args.map &.name.id

    # If there is a splat argument, more work is necessary. The array of arguments
    # returned by `#args` doesn't reflect which one may be a splat. There is a
    # separate method, `#splat_index`, which returns the index of the splat argument,
    # if one exists.
    if si = method.splat_index
      method_args[si] = "*#{method_args[si]}"
      method_arg_names[si] = "*#{method_arg_names[si]}"
    end

    block_arg_arity = nil
    block_arg_ary = [] of String
    block_arg_list = ""
    block_call_list = ""
    block_type = nil

    if method.accepts_block?
      if method.block_arg
        block_arg = "&#{method.block_arg.id}".id
        block_arg_name = "&#{method.block_arg.name.id}"
        method_args << block_arg
        method_arg_names << block_arg_name
        block_type = "block"
      else
        block_arg = nil
        block_arg_name = nil
        block_type = "yield"
      end

      # If you are reading this code, the block below is because we need
      # construct a list of variable names, for any block arity that the
      # code might encounter, but the macro language doesn't give us many
      # tools to do this. So, we have to do it gross. If you can think of
      # a better way to do this, please let me know.
      left = method.block_arg.id.gsub(/[\w\d_]+\s+:\s+.\s*/, "").split("->")[0].id
      block_arg_arity = block_type == "block" ? (left.split(",").reject(&.empty?).size - 1) : (yield_arity - 1)

      if block_arg_arity > -1
        letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        (0..block_arg_arity).each do |n|
          block_arg = ""
          work = n
          block_arg = letters[work % 26]
          work = (work // 26) - 1
          (0..3).each do
            if work >= 0
              block_arg = letters[work % 26] + block_arg
              work = (work // 26) - 1
            end
          end

          block_arg_ary << block_arg
        end

        block_call_list = block_arg_ary.join(", ").id
        block_arg_list = "|#{block_call_list}|"
      end
    end

    # Create the new master method name. The purpose of redefining the original
    # method into a new name is to allow both references to refer to the same
    # same implementation. This also allows one to later remove either the
    # original or the alias without affecting the other.
    unless new_name
      new_name = "#{method.name.id}_#{method.column_number}X#{method.line_number}"
      {
        "lxesxs":        /\s*\<\s*/,
        "exqualxs":      /\s*\=\s*/,
        "exxclamatioxn": /\s*\!\s*/,
        "txildxe":       /\s*\~\s*/,
        "gxreatexr":     /\s*\>\s*/,
        "pxluxs":        /\s*\+\s*/,
        "mxinuxs":       /\s*\-\s*/,
        "axsterisxk":    /\s*\*\s*/,
        "sxlasxh":       /\s*\/\s*/,
        "pxercenxt":     /\s*\%\s*/,
        "axmpersanxd":   /\s*\&\s*/,
        "qxuestioxn":    /\s*\?\s*/,
        "lxbrackext":    /\s*\[\s*/,
        "rxbrackext":    /\s*\]\s*/,
      }.each do |label, punctuation|
        new_name = new_name.gsub(punctuation, label.stringify)
      end
    end

    alias_method_call = [
      receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id ,
      new_name.id,
      !method_args.empty? ? "(".id : "".id,
      method_arg_names.join(", ").id,
      !method_args.empty? ? ")".id : "".id,
      method.accepts_block? && (block_type == "yield") ? "{#{block_arg_list.id} yield(#{block_call_list.id})}".id : "".id
    ].join("")

    fqnn = [
      @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id,
      new_name.id
    ].join("")
  %}

  {% if redefine || !skip_origin %}
  # Original method recreation, under a new name.
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
         }}{{
             new_name.id
           }}{{
               !method_args.empty? ? "(".id : "".id
             }}{{
                 method_args.join(", ").id
               }}{{
                   !method_args.empty? ? ")".id : "".id
                 }}{{
                     method.return_type.id != "" ? " : #{method.return_type.id}".id : "".id
                   }}
  {{ method.body }}
  end

  # Create the aliases.
  @[AliasMethod::Alias(parent: {{ fqnn }})]
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           new_receiver == @type ? "".id : "#{new_receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
         }}{{
             method_name.id
           }}{{
               !method_args.empty? ? "(".id : "".id
             }}{{
                 method_args.join(", ").id
               }}{{
                   !method_args.empty? ? ")".id : "".id
                 }}{{
                     method.return_type.id != "" ? " : #{method.return_type.id}".id : "".id
                   }}
    # Rewrite the original method.
    {{ alias_method_call.id }}
  end
  {% end %}

  @[AliasMethod::Alias(parent: {{ fqnn }})]
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           new_receiver == @type ? "".id : "#{new_receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
         }}{{
             new_method_name.id
           }}{{
               !method_args.empty? ? "(".id : "".id
             }}{{
                 method_args.join(", ").id
               }}{{
                   !method_args.empty? ? ")".id : "".id
                 }}{{
                     method.return_type.id != "" ? " : #{method.return_type.id}".id : "".id
                   }}
    # And write the alias method.
    {{ alias_method_call.id }}
  end

  {% end %}
  {% debug if flag? :DEBUG %}
end

# This macro removes a method. It is not possible to actually undefined
# a method in Crystal, so this macro redefines the method to return, at
# runtime, a NoMethodError exception.
#
# Method removal works on both class methods and instance methods.
# If you have a method chain that has been created through multiple layers
# of methods, and one of the links in the middle of the chain is removed,
# it will break the chain, so be careful with that.
#
# Methods to be removed can be specified directly, through StringLiterals,
# or through Symbol literals, just like alias_method.
#
# ```crystal
# class Foo
#   def original_method
#     "do method stuff"
#   end
#
#   alias_method dup_original_method, original_method
#   alias_method copy_original_method, original_method
#   alias_method extra_original_method, original_method
#
#   # Use a naked method name:
#   remove_method original_method
#
#   # Use a string:
#   remove_method "extra_original_method"
#
#   # Use a symbol:
#   remove_method :copy_original_method
# ```
#
# This can be convenient when aliasing class methods.
#
# ```crystal
# module Benchmark
#   alias_method "self.instructions_per_second", "self.ips"
# end
# ```
macro remove_method(old)
  {%
    method_name = nil
    if old.class_name == "Call"
      if old.receiver.is_a?(Nop)
        receiver = @type
      else
        receiver = old.receiver.resolve.class
      end
      method_name = old.name
    elsif old.includes?(".")
      receiver_name, method_name = old.split(".")

      if receiver_name == "self"
        receiver = @type.class
      else
        receiver = nil
        search_paths = [@top_level]
        search_paths << @type.class unless receiver_name[0..1] == "::"

        search_paths.each do |search_path|
          unless receiver
            found_the_receiver = true
            parts = receiver_name.split("::")
            parts.each do |part|
              if found_the_receiver
                constant_id = search_path.constants.find { |c| c.id == part }
                if !constant_id
                  found_the_receiver = false
                else
                  search_path = search_path.constant(constant_id)
                  found_the_receiver = false if search_path.nil?
                end
              end
            end

            if found_the_receiver
              receiver = search_path.class
            end
          end
        end
      end
    else
      receiver = @type
      method_name = old
    end
  %}

  {% methods = receiver ? receiver.methods.select { |m| m.name.id == method_name } : [] of Nil %}
  {% for method in methods %}
  {%
    method_args = method.args
    method_arg_names = method.args.map &.name.id
    if method.accepts_block? && method.block_arg
      block_arg = "&#{method.block_arg.id}".id
      block_arg_name = "&#{method.block_arg.name.id}"
    else
      block_arg = nil
      block_arg_name = nil
    end

    if block_arg
      method_args << block_arg
      method_arg_names << block_arg_name
    end
  %}

  # Redefine the method to simply raise.
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
         }}{{
             method_name.id
           }}{{
               !method_args.empty? ? "(".id : "".id
             }}{{
                 method_args.join(", ").id
               }}{{
                   !method_args.empty? ? ")".id : "".id
                 }}{{
                     method.return_type.id != "" ? " : #{method.return_type.id}".id : "".id
                   }}
    # Rewrite the method to simply raise an undefined exception.
    raise NoMethodError.new("undefined method \`{{ method_name.id }}' for {{ @type ? @type.id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id }}")
  end

  {% end %}
  {% debug if flag? :DEBUG %}
end
