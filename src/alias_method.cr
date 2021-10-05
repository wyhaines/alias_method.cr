module AliasMethod
  VERSION = "0.1.0"
end

# This macro aliases a given method name to a new name.
macro alias_method(to, from)
  {% puts "Aliasing #{from} -> #{to}" %}
  {% method_name = nil %}
  {%
    # Figure out where the method lives....
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
                constant_id = search_path.constants.find {|c| c.id == part}
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
    end
  %}
  {% new_name = nil %}
  {% puts "Got receiver #{receiver} -> #{from}" %}
  {% methods = receiver ? receiver.methods.select {|m| m.name.id == method_name} : [] of Nil %}
  {% for method in methods %}
  {%
    method_args = method.args
    if method.accepts_block? && method.block_arg
      block_arg = "&#{method.block_arg.id}".id
    else
      block_arg = nil
    end

    if block_arg
      method_args << block_arg
    end

    new_name ||= "#{method.name.id}_#{method.column_number}X#{method.line_number}"
  %}
  {{ method.visibility.id == "public" ? "".id : method.visibility.id }} def {{ receiver == @type ? "".id : "#{receiver.id.gsub(/\.class/,"").gsub(/:Module/,"")}.".id }}{{ new_name.id }}{{ !method_args.empty? ? "(".id : "".id }}{{ method_args.join(", ").id }}{{ !method_args.empty? ? ")".id : "".id }}{{ method.return_type.id != "" ? " : #{method.return_type.id}".id : "".id }}
  {{ method.body.id }}
  end
  
  {% end %}
  {% debug if flag? :DEBUG %}
end

# This macro removes a method. It is not possible to actually undefined
# a method in Crystal, so what this macro does is to redefine the method
# to return, at runtime, a method undefined exception.
macro remove_method(name)
end