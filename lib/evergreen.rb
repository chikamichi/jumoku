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

require 'graphy'

module Evergreen
  # evergreen internals: graph builders and additionnal behaviors
  autoload :TreeAPI,                     'evergreen/tree_api'
  autoload :RawTreeBuilder,              'evergreen/raw_tree'

  #autoload :TreeBuilder,                 'evergreen/builders/tree'

  autoload :RawTree,                     'evergreen/classes/tree_classes'

  autoload :Branch,                      'evergreen/branch.rb'
  
  # support and extensions
  require 'evergreen/support'
  require 'ext/ext'
end
