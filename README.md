# alias_method.cr
Crystal does not provide a ready-to-use mechanism for creating method aliases, and the general Crystal code style recommendation is that one should avoid having multiple names that invoke the same method. However, there are times where creating method aliases is useful. This shard creates an alias_method macro that can be used to easily create method aliases which are functionally identical to the original method.
