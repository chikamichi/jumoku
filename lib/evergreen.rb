$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pathname'
require 'pp'

#require 'active_support/core_ext/module/attribute_accessors'
#require 'active_support/core_ext/class/attribute_accessors'
#require 'active_support/lib/active_support/secure_random'
require 'active_support'

require 'facets/openobject'
require 'facets/hash'
require 'facets/array'
require 'facets/enumerable'

require 'graphy'

module Evergreen
  # evergreen internals: graph builders and additionnal behaviors
  autoload :TreeAPI,                     'evergreen/tree_api'
  autoload :RawTreeBuilder,              'evergreen/builders/raw_tree'
  autoload :TreeBuilder,                 'evergreen/builders/tree'

  autoload :RawTree,                     'evergreen/classes/tree_classes'
  autoload :Tree,                        'evergreen/classes/tree_classes'

  autoload :Branch,                      'evergreen/support/branch'
  
  # support and extensions
  require 'evergreen/support/support'
  # extensions to ruby core
  require 'evergreen/ext/ext'
end
