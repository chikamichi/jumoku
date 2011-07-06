libpath = File.expand_path(File.dirname(__FILE__))
$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__)) || $:.include?(libpath)
$: << libpath + '/../vendor/git/plexus/lib'
puts $:.inspect

require 'pathname'
require 'pp'
require 'active_support'
require 'facets'
require 'plexus'

module Jumoku
  # jumoku internals: graph builders and additionnal behaviors
  autoload :TreeAPI,        'jumoku/tree_api'
  autoload :RawTreeBuilder, 'jumoku/builders/raw_tree'
  autoload :TreeBuilder,    'jumoku/builders/tree'
  autoload :RawTree,        'jumoku/classes/tree_classes'
  autoload :Tree,           'jumoku/classes/tree_classes'
  autoload :Branch,         'jumoku/support/branch'

  require 'jumoku/support/support'
  require 'jumoku/ext/ext'
end
