$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pathname'
require 'pp'
require 'active_support'
require 'facets'
require 'graphy'

module Evergreen
  # evergreen internals: graph builders and additionnal behaviors
  autoload :TreeAPI,        'evergreen/tree_api'
  autoload :RawTreeBuilder, 'evergreen/builders/raw_tree'
  autoload :TreeBuilder,    'evergreen/builders/tree'
  autoload :RawTree,        'evergreen/classes/tree_classes'
  autoload :Tree,           'evergreen/classes/tree_classes'
  autoload :Branch,         'evergreen/support/branch'

  require 'evergreen/support/support'
  require 'evergreen/ext/ext'
end
