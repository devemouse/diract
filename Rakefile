require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'metric_fu'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "diract"
  gem.homepage = "http://github.com/devemouse/diract"
  gem.license = "MIT"
  gem.summary = %Q{Action directories lister}
  gem.description = %Q{Diract lists contents of precofigured 'action' directories. Create a diract.conf file with simple list of directories and run diract.}
  gem.email = "devemouse@gmail.com"
  gem.authors = ["Dariusz Synowiec"]
  gem.files.exclude '*.conf'
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'reek/rake/task'
Reek::Rake::Task.new do |t|
  t.fail_on_error = false
end

require 'ruby-prof/task'
RubyProf::ProfileTask.new do |t|
   t.libs << 'lib' << 'test'
   t.test_files = FileList['bin/*', 'test/test*.rb']
   t.output_dir = "prof/"
   t.printer = :graph
   t.min_percent = 10
end


require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

task :test_all => [:rcov, :reek, :profile]

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "diract #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
