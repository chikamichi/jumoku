require 'rake'
require 'yard'
require 'pathname'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "evergreen"
    gem.summary = %Q{A fully fledged tree library for Ruby.}
    gem.description = %Q{Evergreen provides you with tree behaviors to mixin and tree classes to inherit from. Raw tree, common binary trees, custom trees...}
    gem.email = "jd@vauguet.fr"
    gem.homepage = "http://github.com/chikamichi/evergreen"
    gem.authors = ["Jean-Denis Vauguet"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "evergreen #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'spec/**/*.rb', 'README.md', 'TODO.md', 'CREDITS.md', 'LICENSE', 'VERSION']
end

Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
  measurement.output = 'measurement/report.txt'
end

Yardstick::Rake::Verify.new do |verify|
  verify.threshold = 100
end

# stolen from Rails lib/rails/tasks/annotations.rake spec
require 'rails/source_annotation_extractor'

desc "Enumerate all annotations"
task :notes do
  SourceAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO", :tag => true
end

namespace :notes do
  ["OPTIMIZE", "FIXME", "TODO"].each do |annotation|
    desc "Enumerate all #{annotation} annotations"
    task annotation.downcase.intern do
      SourceAnnotationExtractor.enumerate annotation
    end
  end

  desc "Enumerate a custom annotation, specify with ANNOTATION=CUSTOM"
  task :custom do
    SourceAnnotationExtractor.enumerate ENV['ANNOTATION']
  end
end

