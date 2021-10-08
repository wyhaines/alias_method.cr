module AliasMethod
  VERSION = "0.1.0"
end

class NoMethodError < Exception
end

# This macro aliases a given method name to a new name.
macro alias_method(to, from, yield_arity = 0)
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

  {% # Figure out where the method lives....

 if to.includes?(".")
   to_receiver_name, to_method_name = from.split(".")

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
 end %}

  {% new_name = nil %}
  {% methods = receiver ? receiver.methods.select { |m| m.name.id == method_name } : [] of Nil %}
  {% for method in methods %}
  {%
    method_args = method.args
    method_arg_names = method.args.map { |a| a.name.id }
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
      block_arg_arity = block_type == "block" ? (left.split(",").reject { |arg| arg.empty? }.size - 1) : (yield_arity - 1)

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
    new_name ||= "#{method.name.id}_#{method.column_number}X#{method.line_number}"
  %}
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
  
  {{
    method.visibility.id == "public" ? "".id : method.visibility.id
  }} def {{
           receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/, "").gsub(/:Module/, "")}.".id
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
# a method in Crystal, so what this macro does is to redefine the method
# to return, at runtime, a method undefined exception.
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

  {% new_name = nil %}
  {% methods = receiver ? receiver.methods.select { |m| m.name.id == method_name } : [] of Nil %}
  {% for method in methods %}
  {%
    method_args = method.args
    method_arg_names = method.args.map { |a| a.name.id }
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
      block_arg_arity = block_type == "block" ? (left.split(",").reject { |arg| arg.empty? }.size - 1) : (yield_arity - 1)

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
