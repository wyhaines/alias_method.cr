module AliasMethod
  VERSION = "0.1.0"

  annotation Alias; end
end

# This exception will be thrown if a method that has been removed via
# the `remove_method` macro is called.
class NoMethodError < Exception
end

# The `alias_method(to, from, yield_arity)` macro is used to create method
# aliases. For most usage, only the `to` and the `from` arguments are
# required. The `yield_arity` argument is optional, only applies when
# aliasing a method that yields, and defaults to `0`.
#
# When a method contains a `yield` statement, that method accepts a block.
# However, because the block is not captured, the macro does not know what
# the expected call signature of the block is. So, when it constructs the
# block forwarding code, it has no way of knowing how many arguments the
# code expects the block to have. So, when aliasing methods that yield, one
# must provide that arity information to the macro if the arity is anything
# other than zero.
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
#   # Spanish translations of the method names:
#   alias_method "suma", "self.add", 1
#   alias_method "con", "with"
# end
#
# foo = Foo.new
#
# puts Foo.suma(123, 456)
# puts(foo.con(7) do |x|
#   x ** x
# end)
# ```
#
# The macro will not throw any errors if the method being aliased can not be
# found.
#
# ```
# class MyClass
#   alias_method "nada", "nothing"
# end
# ```
macro alias_method(to, from, yield_arity = 0)
  {%
    # Figure out where the _from_ method lives....

    method_name = nil
    if from.class_name == "Call"
      # This is the easy way, and the way that the macro should normally be used.
      # The method to lookup is directly referenced in a Call.
      if from.receiver.is_a?(Nop)
        receiver = @type
      else
        receiver = from.receiver.resolve.class
      end
      method_name = from.name
    elsif from.includes?(".")
      # It's a class method.
      receiver_name, method_name = from.split(".")

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
      method_name = from
    end

    # Figure out where the _to_  method lives....
    to_method_name = nil
    if to.class_name == "Call"
      if to.receiver.is_a?(Nop)
        to_receiver = @type
      else
        to_receiver = to.receiver.resolve.class
      end
      to_method_name = to.name
    elsif to.includes?(".")
      to_receiver_name, to_method_name = to.split(".")

      if to_receiver_name == "self"
        to_receiver = @type.class
      else
        to_receiver = nil
        search_paths = [@top_level]
        search_paths << @type.class unless receiver_name[0..1] == "::"

        search_paths.each do |search_path|
          unless to_receiver
            found_the_to_receiver = true
            parts = to_receiver_name.split("::")
            parts.each do |part|
              if found_the_to_receiver
                constant_id = search_path.constants.find { |c| c.id == part }
                if !constant_id
                  found_the_to_receiver = false
                else
                  search_path = search_path.constant(constant_id)
                  found_the_to_receiver = false if search_path.nil?
                end
              end
            end

            if found_the_to_receiver
              to_receiver = search_path.class
            end
          end
        end
      end
    else
      to_receiver = @type
      to_method_name = to
    end
  %}
  {%
    new_name = nil
    methods = receiver ? receiver.methods.select { |m| m.name.id == method_name } : [] of Nil
  %}
  {% for method in methods %}
  {%
    skip_origin = false
    # If the original method already has a new name, don't create it again.
    if ann = method.annotation(AliasMethod::Alias)
      skip_origin = true if ann[:parent]
    end

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

    block_arg_arity = nil
    block_arg_ary = [] of String
    block_arg_list = ""
    block_call_list = ""
    block_type = nil
    if method.accepts_block?
      block_type = method.block_arg ? "block" : "yield"

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
  %}

  {% if !skip_origin %}
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
  {% end %}

  # Create the aliases.
  @[AliasMethod::Alias(parent: {{ new_name }})]
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           to_receiver == @type ? "".id : "#{to_receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
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
    {{
      receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
    }}{{
        new_name.id
      }}{{
          !method_args.empty? ? "(".id : "".id
        }}{{
            method_arg_names.join(", ").id
          }}{{
              !method_args.empty? ? ")".id : "".id
            }}{{
                method.accepts_block? && (block_type == "yield") ? "{#{block_arg_list.id} yield(#{block_call_list.id})}".id : "".id
              }}
  end

  @[AliasMethod::Alias(parent: new_name)]
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           to_receiver == @type ? "".id : "#{to_receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
         }}{{
             to_method_name.id
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
    {{
      receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
    }}{{
        new_name.id
      }}{{
          !method_args.empty? ? "(".id : "".id
        }}{{
            method_arg_names.join(", ").id
          }}{{
              !method_args.empty? ? ")".id : "".id
            }}{{
                method.accepts_block? && (block_type == "yield") ? "{#{block_arg_list.id} yield(#{block_call_list.id})}".id : "".id
              }}
  end

  {% end %}
  {% debug if flag? :DEBUG %}
end

# This macro removes a method. It is not possible to actually undefined
# a method in Crystal, so this macro redefines the method to return, at
# runtime, a NoMethodError exception.
#
# Method removal works on both class methods and instance methods.
macro remove_method(from)
  {% method_name = nil %}
  {% # Figure out where the method lives....
 if from.includes?(".")
   receiver_name, method_name = from.split(".")

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
   method_name = from
 end %}

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
