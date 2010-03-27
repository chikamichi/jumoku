**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:

* it's class-based, hence its difficult to "mixin" behavior
* the API is quite poorly designed (CamelCased, painful chained accessors, ...)
* it's not versatile enough

What would be great is a modular library providing us with tree behaviors (modules) and raw tree classes to inherit from if we ever need to.

One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

## Examples

The simplest (raw) tree would ship with only generic methods to create and access/traverse nodes. These methods from `Evergreen::As::RawTree` would be shared by all other specialized tree kinds, so that this module would be Evergreen's base module.

    module MyTree
      include Evergreen::As::RawTree
      # you may extend as well, depending on your needs

      # (re)def things as you wish!

      # hint: this module will likely be included or extended in some class of your choice
    end

or:

    class MyTree
      include Evergreen::As::RawTree
    end

or:

    class MyTree < Evergreen::Tree::Raw
      # basically this RawTree class does the same as the module above
    end

You could also be more specific about your needs:

    myTree = Evergreen::Tree::Raw.new(:branching_number => 3) # 3 children per node at most

    myTree = Evergreen::Tree::Binary.new(:traversal => :post_order)

## Code organisation

Idea:

    Evergreen                                       lib/evergreen/

      Public API:
      ::As (modules)                                  as/
        ::RawTree                                       raw.rb
        ::BinaryTree                                    binary/
        ::AVL                                             self_balancing.rb (avl, red-black, ... modules)
        ::RedBlackTree                                  
      ::Tree (classes)                                types/
        ::Raw                                           raw.rb
        ::Binary                                        binaries.rb
        ::AVL
        ::RedBlack

      Private (implementation) API:
      ::Behaviors (modules, extended)                 behaviors/
        ::Search                                          
          ::Recursive                                     search_algo.rb
          ::Iterative                                     traversal_algo.rb
        ::Traversal                                       shape_algo.rb
          ::PreOrder
          ::InOrder
          ::PostOrder
          ::DepthFirst
          ::BreadthFirst
        ::Shape
          ::Height
          ::Branching

A user may interact with two namespaces from the Evergreen public API:

* The `As` namespace gathers modules to mix-in via `include` or `extend`
* The `Tree` namespace gathers classes to inherit from. Those classes are "factories" which mixed-in a generic tree behavior from the `As` namespace.

A private API acts as the backbone of the public API, providing the actual implementation of each tree kinds. It is responsible for defining fine-grained behaviors to be branched to the generic `RawTree` module, so as to generate the specialized tree structures (binary, AVL, and so on). The `Behaviors` namespace gathers:

* search algorithms
* traversal algorithms
* shapers (handle branching number, reorder algorithms, ...)

So, for instance, the AVL tree made made available in the `Evergreen::As::AVL` module is actually designed the following way:

* including the generic `Evergreen::As::RawTree` module (which does *not* rely on any `Behaviors`)
* extending appropriate behaviors : `Behaviors::Shape::HeightBalanced` (at least).

If the user wants to, he can picks whatever additionnal behavior he wants:

    tree = Evergreen::Tree::AVL(:traversal => :post_order, :search => :iterative)

    # equivalent to:

    tree = Evergreen::Tree::Binary(:type => :avl, :traversal => :post_order, :search => :iterative)

    # or even:

    tree = Evergreen::Tree::Raw(:branching_number => 2, :height => :balanced, :traversal => :post_order, :search => :iterative)


