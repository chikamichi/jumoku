$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'evergreen'
require 'spec'
#require 'spec/autorun'

include Evergreen

Spec::Runner.configure do |config|
end
