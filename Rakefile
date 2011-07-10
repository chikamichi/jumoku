# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r jumoku.rb"
end
