libpath = File.expand_path(File.dirname(__FILE__))
$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__)) || $:.include?(libpath)

require 'pathname'
require 'pp'
require 'active_support'
require 'facets'
require 'plexus'

# Jumoku provides you with several modules and classes to build and manipulate
# tree graphs. Two basic implementations are available: undirected trees
# ({RawUndirectedTree}) and directed trees ({RawDirectedTree}).
#
# {Tree} is derived from the undirected flavour and sticks to the mathematical
# tree definition. {Arborescence} is derived from the directed flavour and is
# likely to be used as the basis to modelize hierarchy structures, such as a
# family tree, a file browser…
#
# Note that a node can be any Object. There is no "node type", therefore
# arguments which re expected to be nodes are simply labelled as "`node`"
# within this documentation. A nice object type to use as a node may be an
# OpenStruct or an [OpenObject](http://facets.rubyforge.org/apidoc/api/more/classes/OpenObject.html)
# (from the Facets library), both turning nodes into versatile handlers.
#
module Jumoku
  # API, core implementations
  autoload :TreeAPI,                  'jumoku/tree_api'
  autoload :Shared,                   'jumoku/builders/shared'
  autoload :Extended,                 'jumoku/builders/extended'

  # branch types
  autoload :UndirectedBranch,         'jumoku/support/branch'
  autoload :DirectedBranch,           'jumoku/support/branch'

  # tree builders
  autoload :RawUndirectedTreeBuilder, 'jumoku/builders/raw_undirected_tree'
  autoload :RawDirectedTreeBuilder,   'jumoku/builders/raw_directed_tree'
  autoload :TreeBuilder,              'jumoku/builders/tree'
  autoload :ArborescenceBuilder,      'jumoku/builders/arborescence'

  # tree classes
  autoload :RawDirectedTree,          'jumoku/classes/tree_classes'
  autoload :RawUndirectedTree,        'jumoku/classes/tree_classes'
  autoload :Tree,                     'jumoku/classes/tree_classes'
  autoload :Arborescence,             'jumoku/classes/tree_classes'

  # support
  require 'jumoku/support/support'
  require 'jumoku/ext/ext'
end
