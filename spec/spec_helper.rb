require File.expand_path("../../lib/jumoku.rb",  __FILE__)
require File.expand_path("../behaviors/core_tree.rb",  __FILE__)
require File.expand_path("../behaviors/extended.rb",  __FILE__)

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec

  require 'jumoku'
  include Jumoku
end
