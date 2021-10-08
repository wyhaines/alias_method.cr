crystal_doc_search_index_callback({"repository_name":"alias_method","body":"![Alias_Method.cr CI](https://img.shields.io/github/workflow/status/wyhaines/alias_method.cr/Alias_Method.cr%20CI?style=for-the-badge&logo=GitHub)\n[![GitHub release](https://img.shields.io/github/release/wyhaines/alias_method.cr.svg?style=for-the-badge)](https://github.com/wyhaines/alias_method.cr/releases)\n![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/wyhaines/alias_method.cr/latest?style=for-the-badge)\n\n# Alias_Method.cr\n\nCrystal does not natively support the creation of method aliases. This is by design, and the general philosophy of the language is that any given method should only be called by a single name.\n\nHowever, there are times when one might want to create method aliases. It is certainly possible to hand-write code to do this, but this shard provides a single-line way of aliasing a method. It works for both instance methods and for class methods.\n\n## Installation\n\n1. Add the dependency to your `shard.yml`:\n\n   ```yaml\n   dependencies:\n     alias_method:\n       github: wyhaines/alias_method.cr\n   ```\n\n2. Run `shards install`\n\n## Usage\n\n```crystal\nrequire \"alias_method\"\n```\n\nThe `alias_method(to, from, yield_arity)` macro is used to create method aliases. For most usage, only the `to` and the `from` arguments are required. The `yield_arity` argument is optional, only applies when aliasing a method that yields, and defaults to `0`.\n\nWhen a method contains a `yield` statement, that method accepts a block. However, because the block is not captured, the macro does not know what the expected call signature of the block is. So, when it constructs the block forwarding code, it has no way of knowing how many arguments the code expects the block to have. So, when aliasing methods that yield, one must provide that arity information to the macro if the arity is anything other than zero.\n\n```crystal\nclass MyClass\n  def self.add(x, y)\n    x + y\n  end\n\n  def with(arg)\n    yield arg\n  end\n\n  # Spanish translations of the method names:\n  alias_method \"suma\", \"self.add\", 1\n  alias_method \"con\", \"with\"\nend\n\nfoo = Foo.new\n\nputs Foo.suma(123, 456)\nputs(foo.con(7) do |x|\n  x ** x\nend)\n```\n\nThe macro will not throw any errors if the method being aliased can not be found.\n\n```crystal\nclass MyClass\n  alias_method \"nada\", \"nothing\"\nend\n```\n\nThe shard also implements a `remove_method` macro that can be used to (sort of) remove methods. Crystal does not actually provide any ability to truly undefine a method, so this macro redefines the removed method to throw a `NoMethodError` exception.\n\n```crystal\nclass MyClass\n  def self.add(x, y)\n    x + y\n  end\n\n  def with(arg)\n    yield arg\n  end\n\n  # Spanish translations of the method names:\n  alias_method \"suma\", \"self.add\"\n  alias_method \"con\", \"with\"\n\n  # Remove the English versions.\n  remove_method \"with\"\n  remove_method \"self.add\"\nend\n```\n\n## Development\n\nIf you wish to contribute to this shard, please fork the repository, and work from a branch within your own fork. When your work is complete (and has appropriate specs), submit a PR. Thank you!\n\n## Contributing\n\n1. Fork it (<https://github.com/wyhaines/alias_method/fork>)\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## Contributors\n\n- [Kirk Haines](https://github.com/wyhaines) - creator and maintainer\n\n![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/wyhaines/alias_method.cr?style=for-the-badge)\n![GitHub issues](https://img.shields.io/github/issues/wyhaines/alias_method.cr?style=for-the-badge)\n","program":{"html_id":"alias_method/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"superclass":null,"ancestors":[],"locations":[],"repository_name":"alias_method","program":true,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[{"html_id":"alias_method(to,from,yield_arity=0)-macro","name":"alias_method","doc":"The `alias_method(to, from, yield_arity)` macro is used to create method\naliases. For most usage, only the `to` and the `from` arguments are\nrequired. The `yield_arity` argument is optional, only applies when\naliasing a method that yields, and defaults to `0`.\n\nWhen a method contains a `yield` statement, that method accepts a block.\nHowever, because the block is not captured, the macro does not know what\nthe expected call signature of the block is. So, when it constructs the\nblock forwarding code, it has no way of knowing how many arguments the\ncode expects the block to have. So, when aliasing methods that yield, one\nmust provide that arity information to the macro if the arity is anything\nother than zero.\n\n```crystal\nclass MyClass\n  def self.add(x, y)\n    x + y\n  end\n\n  def with(arg)\n    yield arg\n  end\n\n  # Spanish translations of the method names:\n  alias_method \"suma\", \"self.add\", 1\n  alias_method \"con\", \"with\"\nend\n\nfoo = Foo.new\n\nputs Foo.suma(123, 456)\nputs(foo.con(7) do |x|\n  x ** x\nend)\n```\n\nThe macro will not throw any errors if the method being aliased can not be\nfound.\n\n```crystal\nclass MyClass\n  alias_method \"nada\", \"nothing\"\nend\n```","summary":"<p>The <code><a href=\"toplevel.html#alias_method(to,from,yield_arity=0)-macro\">alias_method(to, from, yield_arity)</a></code> macro is used to create method aliases.</p>","abstract":false,"args":[{"name":"to","doc":null,"default_value":"","external_name":"to","restriction":""},{"name":"from","doc":null,"default_value":"","external_name":"from","restriction":""},{"name":"yield_arity","doc":null,"default_value":"0","external_name":"yield_arity","restriction":""}],"args_string":"(to, from, yield_arity = 0)","args_html":"(to, from, yield_arity = <span class=\"n\">0</span>)","location":{"filename":"src/alias_method.cr","line_number":54,"url":"https://github.com/wyhaines/alias_method.cr/blob/7d46005ff634b2fac45e24c1dc4e37d4251103b8/src/alias_method.cr#L54"},"def":{"name":"alias_method","args":[{"name":"to","doc":null,"default_value":"","external_name":"to","restriction":""},{"name":"from","doc":null,"default_value":"","external_name":"from","restriction":""},{"name":"yield_arity","doc":null,"default_value":"0","external_name":"yield_arity","restriction":""}],"double_splat":null,"splat_index":null,"block_arg":null,"visibility":"Public","body":"  \n{% method_name = nil %}\n\n  \n{% if from.includes?(\".\")\n  receiver_name, method_name = from.split(\".\")\n  if receiver_name == \"self\"\n    receiver = @type.class\n  else\n    receiver = nil\n    search_paths = [@top_level]\n    unless receiver_name[0..1] == \"::\"\n      search_paths << @type.class\n    end\n    search_paths.each do |search_path|\n      unless receiver\n        found_the_receiver = true\n        parts = receiver_name.split(\"::\")\n        parts.each do |part|\n          if found_the_receiver\n            constant_id = search_path.constants.find do |c|\n              c.id == part\n            end\n            if !constant_id\n              found_the_receiver = false\n            else\n              search_path = search_path.constant(constant_id)\n              if search_path.nil?\n                found_the_receiver = false\n              end\n            end\n          end\n        end\n        if found_the_receiver\n          receiver = search_path.class\n        end\n      end\n    end\n  end\nelse\n  receiver = @type\n  method_name = from\nend %}\n\n\n  \n{% if to.includes?(\".\")\n  to_receiver_name, to_method_name = from.split(\".\")\n  if to_receiver_name == \"self\"\n    to_receiver = @type.class\n  else\n    to_receiver = nil\n    search_paths = [@top_level]\n    unless receiver_name[0..1] == \"::\"\n      search_paths << @type.class\n    end\n    search_paths.each do |search_path|\n      unless to_receiver\n        found_the_to_receiver = true\n        parts = to_receiver_name.split(\"::\")\n        parts.each do |part|\n          if found_the_to_receiver\n            constant_id = search_path.constants.find do |c|\n              c.id == part\n            end\n            if !constant_id\n              found_the_to_receiver = false\n            else\n              search_path = search_path.constant(constant_id)\n              if search_path.nil?\n                found_the_to_receiver = false\n              end\n            end\n          end\n        end\n        if found_the_to_receiver\n          to_receiver = search_path.class\n        end\n      end\n    end\n  end\nelse\n  to_receiver = @type\n  to_method_name = to\nend %}\n\n\n  \n{% new_name = nil %}\n\n  \n{% methods = receiver ? receiver.methods.select do |m|\n  m.name.id == method_name\nend : [] of Nil %}\n\n  \n{% for method in methods %}\n  {% method_args = method.args\nmethod_arg_names = method.args.map do |__arg0|\n  __arg0.name.id\nend\nif method.accepts_block? && method.block_arg\n  block_arg = \"&#{method.block_arg.id}\".id\n  block_arg_name = \"&#{method.block_arg.name.id}\"\nelse\n  block_arg = nil\n  block_arg_name = nil\nend\nif block_arg\n  method_args << block_arg\n  method_arg_names << block_arg_name\nend\nblock_arg_arity = nil\nblock_arg_ary = [] of String\nblock_arg_list = \"\"\nblock_call_list = \"\"\nblock_type = nil\nif method.accepts_block?\n  block_type = method.block_arg ? \"block\" : \"yield\"\n  left = ((method.block_arg.id.gsub(/[\\w\\d_]+\\s+:\\s+.\\s*/, \"\")).split(\"->\"))[0].id\n  block_arg_arity = block_type == \"block\" ? (  (left.split(\",\")).reject(&.empty?).size - 1) : (  yield_arity - 1)\n  if block_arg_arity > -1\n    letters = [\"a\", \"b\", \"c\", \"d\", \"e\", \"f\", \"g\", \"h\", \"i\", \"j\", \"k\", \"l\", \"m\", \"n\", \"o\", \"p\", \"q\", \"r\", \"s\", \"t\", \"u\", \"v\", \"w\", \"x\", \"y\", \"z\"]\n    (0..block_arg_arity).each do |n|\n      block_arg = \"\"\n      work = n\n      block_arg = letters[work % 26]\n      work = (work // 26) - 1\n      (0..3).each do\n        if work >= 0\n          block_arg = letters[work % 26] + block_arg\n          work = (work // 26) - 1\n        end\n      end\n      block_arg_ary << block_arg\n    end\n    block_call_list = (block_arg_ary.join(\", \")).id\n    block_arg_list = \"|#{block_call_list}|\"\n  end\nend\nunless new_name\n  new_name = \"#{method.name.id}_#{method.column_number}X#{method.line_number}\"\n  {lxesxs: /\\s*\\<\\s*/, exqualxs: /\\s*\\=\\s*/, exxclamatioxn: /\\s*\\!\\s*/, txildxe: /\\s*\\~\\s*/, gxreatexr: /\\s*\\>\\s*/, pxluxs: /\\s*\\+\\s*/, mxinuxs: /\\s*\\-\\s*/, axsterisxk: /\\s*\\*\\s*/, sxlasxh: /\\s*\\/\\s*/, pxercenxt: /\\s*\\%\\s*/, axmpersanxd: /\\s*\\&\\s*/, qxuestioxn: /\\s*\\?\\s*/, lxbrackext: /\\s*\\[\\s*/, rxbrackext: /\\s*\\]\\s*/}.each do |label, punctuation|\n    new_name = new_name.gsub(punctuation, label.stringify)\n  end\nend\n %}\n  # Original method recreation, under a new name.\n  {{ method.visibility.id == \"public\" ? \"\".id : method.visibility.id }} def {{ receiver == @type ? \"\".id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}{{ new_name.id }}{{ !method_args.empty? ? \"(\".id : \"\".id }}{{ (method_args.join(\", \")).id }}{{ !method_args.empty? ? \")\".id : \"\".id }}{{ method.return_type.id != \"\" ? \" : #{method.return_type.id}\".id : \"\".id }}\n  {{ method.body }}\n  end\n\n  # Create the aliases.\n  {{ method.visibility.id == \"public\" ? \"\".id : method.visibility.id }} def {{ receiver == @type ? \"\".id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}{{ method_name.id }}{{ !method_args.empty? ? \"(\".id : \"\".id }}{{ (method_args.join(\", \")).id }}{{ !method_args.empty? ? \")\".id : \"\".id }}{{ method.return_type.id != \"\" ? \" : #{method.return_type.id}\".id : \"\".id }}\n    # Rewrite the original method.\n    {{ receiver == @type ? \"\".id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}{{ new_name.id }}{{ !method_args.empty? ? \"(\".id : \"\".id }}{{ (method_arg_names.join(\", \")).id }}{{ !method_args.empty? ? \")\".id : \"\".id }}{{ method.accepts_block? && (block_type == \"yield\") ? \"{#{block_arg_list.id} yield(#{block_call_list.id})}\".id : \"\".id }}\n  end\n\n  {{ method.visibility.id == \"public\" ? \"\".id : method.visibility.id }} def {{ receiver == @type ? \"\".id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}{{ to_method_name.id }}{{ !method_args.empty? ? \"(\".id : \"\".id }}{{ (method_args.join(\", \")).id }}{{ !method_args.empty? ? \")\".id : \"\".id }}{{ method.return_type.id != \"\" ? \" : #{method.return_type.id}\".id : \"\".id }}\n    # And write the alias method.\n    {{ receiver == @type ? \"\".id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}{{ new_name.id }}{{ !method_args.empty? ? \"(\".id : \"\".id }}{{ (method_arg_names.join(\", \")).id }}{{ !method_args.empty? ? \")\".id : \"\".id }}{{ method.accepts_block? && (block_type == \"yield\") ? \"{#{block_arg_list.id} yield(#{block_call_list.id})}\".id : \"\".id }}\n  end\n\n  {% end %}\n\n  \n{% if flag?(:DEBUG)\n  debug\nend %}\n\n\n"}},{"html_id":"remove_method(from)-macro","name":"remove_method","doc":"This macro removes a method. It is not possible to actually undefined\na method in Crystal, so this macro redefines the method to return, at\nruntime, a NoMethodError exception.\n\nMethod removal works on both class methods and instance methods.","summary":"<p>This macro removes a method.</p>","abstract":false,"args":[{"name":"from","doc":null,"default_value":"","external_name":"from","restriction":""}],"args_string":"(from)","args_html":"(from)","location":{"filename":"src/alias_method.cr","line_number":308,"url":"https://github.com/wyhaines/alias_method.cr/blob/7d46005ff634b2fac45e24c1dc4e37d4251103b8/src/alias_method.cr#L308"},"def":{"name":"remove_method","args":[{"name":"from","doc":null,"default_value":"","external_name":"from","restriction":""}],"double_splat":null,"splat_index":null,"block_arg":null,"visibility":"Public","body":"  \n{% method_name = nil %}\n\n  \n{% if from.includes?(\".\")\n  receiver_name, method_name = from.split(\".\")\n  if receiver_name == \"self\"\n    receiver = @type.class\n  else\n    receiver = nil\n    search_paths = [@top_level]\n    unless receiver_name[0..1] == \"::\"\n      search_paths << @type.class\n    end\n    search_paths.each do |search_path|\n      unless receiver\n        found_the_receiver = true\n        parts = receiver_name.split(\"::\")\n        parts.each do |part|\n          if found_the_receiver\n            constant_id = search_path.constants.find do |c|\n              c.id == part\n            end\n            if !constant_id\n              found_the_receiver = false\n            else\n              search_path = search_path.constant(constant_id)\n              if search_path.nil?\n                found_the_receiver = false\n              end\n            end\n          end\n        end\n        if found_the_receiver\n          receiver = search_path.class\n        end\n      end\n    end\n  end\nelse\n  receiver = @type\n  method_name = from\nend %}\n\n\n  \n{% methods = receiver ? receiver.methods.select do |m|\n  m.name.id == method_name\nend : [] of Nil %}\n\n  \n{% for method in methods %}\n  {% method_args = method.args\nmethod_arg_names = method.args.map do |__arg2|\n  __arg2.name.id\nend\nif method.accepts_block? && method.block_arg\n  block_arg = \"&#{method.block_arg.id}\".id\n  block_arg_name = \"&#{method.block_arg.name.id}\"\nelse\n  block_arg = nil\n  block_arg_name = nil\nend\nif block_arg\n  method_args << block_arg\n  method_arg_names << block_arg_name\nend\n %}\n\n  # Redefine the method to simply raise.\n  {{ method.visibility.id == \"public\" ? \"\".id : method.visibility.id }} def {{ receiver == @type ? \"\".id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}{{ method_name.id }}{{ !method_args.empty? ? \"(\".id : \"\".id }}{{ (method_args.join(\", \")).id }}{{ !method_args.empty? ? \")\".id : \"\".id }}{{ method.return_type.id != \"\" ? \" : #{method.return_type.id}\".id : \"\".id }}\n    # Rewrite the method to simply raise an undefined exception.\n    raise NoMethodError.new(\"undefined method \\`{{ method_name.id }}' for {{ @type ? @type.id : \"#{(receiver.id.gsub(/\\.class/, \"\")).gsub(/:Module/, \"\")}.\".id }}\")\n  end\n\n  {% end %}\n\n  \n{% if flag?(:DEBUG)\n  debug\nend %}\n\n\n"}}],"types":[{"html_id":"alias_method/AliasMethod","path":"AliasMethod.html","kind":"module","full_name":"AliasMethod","name":"AliasMethod","abstract":false,"superclass":null,"ancestors":[],"locations":[{"filename":"src/alias_method.cr","line_number":1,"url":"https://github.com/wyhaines/alias_method.cr/blob/7d46005ff634b2fac45e24c1dc4e37d4251103b8/src/alias_method.cr#L1"}],"repository_name":"alias_method","program":false,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[{"id":"VERSION","name":"VERSION","value":"\"0.1.0\"","doc":null,"summary":null}],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[]},{"html_id":"alias_method/NoMethodError","path":"NoMethodError.html","kind":"class","full_name":"NoMethodError","name":"NoMethodError","abstract":false,"superclass":{"html_id":"alias_method/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"alias_method/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"alias_method/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"alias_method/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/alias_method.cr","line_number":7,"url":"https://github.com/wyhaines/alias_method.cr/blob/7d46005ff634b2fac45e24c1dc4e37d4251103b8/src/alias_method.cr#L7"}],"repository_name":"alias_method","program":false,"enum":false,"alias":false,"aliased":null,"aliased_html":null,"const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":"This exception will be thrown if a method that has been removed via\nthe `remove_method` macro is called.","summary":"<p>This exception will be thrown if a method that has been removed via the <code><a href=\"toplevel.html#remove_method(from)-macro\">remove_method</a></code> macro is called.</p>","class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[]}]}})