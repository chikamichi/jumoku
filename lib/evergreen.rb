$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'pathname'
require 'pp'

#require 'active_support/core_ext/module/attribute_accessors'
#require 'active_support/core_ext/class/attribute_accessors'
#require 'activesupport/lib/active_support/secure_random'
require 'activesupport'

require 'ext/ext'
require 'evergreen/raw_tree'

