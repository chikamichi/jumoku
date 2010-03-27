**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:
* it's class-based, hence its difficult to "mixin" behavior
* the API is quite poorly designed (CamelCased, painful chained accessors, ...)
* it's not versatile enough

What would be great is a modular library providing us with tree behaviors (modules) and raw tree classes to inherit from if we ever need to.

One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

## Examples

The simplest (raw) tree would ship with only generic purpose methods to create and access/traverse nodes.

    module MyTree
      include Evergreen::Behavior::RawTree
      # alias: include Evergreen::RawTree
      # you may extend as well, depending on your needs
    end

    class MyTree < Evergreen::Type::RawTree
      # basically this RawTree class does the same as the module above
    end

But you could also be more specific about your needs:

    myTree = Evergreen::Type::RawTree.new(:branching_number => 3) # 3 children per node at most

    myTree = Evergreen::Type::BinaryTree.new(:traversal => :post_order)

    myTree = Evergreen::Type::RawTree.new do 

