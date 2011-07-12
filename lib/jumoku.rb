libpath = File.expand_path(File.dirname(__FILE__))
$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__)) || $:.include?(libpath)

require 'pathname'
require 'pp'
require 'active_support'
require 'facets'
require 'hashery'
require 'plexus'

# Jumoku provides you with several modules and classes to build and manipulate
# tree-graphs.
#
# A tree is a structure composed of branches binding nodes. Branches may be
# directed (arcs) or undirected (edges). When a there is only one general
# direction (flow), there is a root node, and one or several leaf nodes. A
# directed, uni-flow tree where each node only branches in once and branches
# out once is called a path. For more information on what a tree-graph is and
# how you could make use of it, see the README.
#
# Two basic implementations are available: undirected trees
# ({RawUndirectedTree}) and directed trees ({RawDirectedTree}). They offer
# limited features, so one will certainly drop to their civilized siblings:
#
#  * {Tree} is derived from an undirected tree and sticks to the mathematical
# tree definition.
#  * {Arborescence} is derived from a directed tree and is likely to be used
# as the basis to modelize hierarchy structures, such as a family tree, a file
# browser…
#
# A node can be any Object: there is no "node type". A nice object "type" to
# use as a node may be an OpenStruct or an OpenHash (from the Facets library),
# but really any object is valid.
#
# Jumoku allows you to enable some strategies when creating a new tree. For
# instance, you may enable an edge/arc labeling strategy, which will cause
# indexing of branches as they are added. Jumoku provides a few basic
# strategies mixin, and one may implement custom ones.
#
module Jumoku
  # core implementations
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

  # strategies
  autoload :EdgeLabeling,             'jumoku/strategies/edge_labeling'
  EdgeLabeling.autoload :Simple,      'jumoku/strategies/edge_labeling/simple'

  # support
  require 'jumoku/support/ruby_compatibility'
  require 'jumoku/support/support'
  require 'jumoku/ext/ext'
end
