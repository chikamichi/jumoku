# -*- encoding: utf-8 -*-
require './lib/jumoku/version'

Gem::Specification.new do |s|
  s.name = %q{jumoku}
  s.version = Jumoku::VERSION
  s.author = "Jean-Denis Vauguet <jd@vauguet.fr>"
  s.description = %q{Jumoku provides you with tree behaviors to mixin and tree classes to inherit from. Raw tree, common binary trees, custom trees...}
  s.email = %q{jd@vauguet.fr}
  s.files = Dir["lib/**/*"] + Dir["vendor/**/*"] + Dir["spec/**/*"] + ["Gemfile", "LICENSE", "Rakefile", "README.md"]
  s.homepage = %q{http://github.com/chikamichi/jumoku}
  s.summary = %q{A fully fledged tree library for Ruby.}
  s.add_dependency "activesupport"
  s.add_dependency "facets"
  s.add_dependency "hashery"
  s.add_dependency "plexus"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
end

