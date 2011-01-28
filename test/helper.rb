require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'diract'
require 'fileutils'
require 'tmpdir'
require 'tempfile'

class Test::Unit::TestCase
   def prepare_conf(num_of_dirs = 1)
      @conf_file = Tempfile.new('foo')
      @testfiles = [ {:name => "file1", :desc => "f1 description1"},
                     {:name => "file2", :desc => "f2 description"},
                     {:name => "file3", :desc => nil},
                     {:name => "file4", :desc => "f4 description3"} ]

      if num_of_dirs > 1
         @tmpdir = Array.new(num_of_dirs)

         @tmpdir.map! { |dir|
            dir = Dir.mktmpdir

            @testfiles.each { |el|
               add_test_file(el[:name], dir)
            }

            @conf_file.puts dir
         }

      else
         @tmpdir = Dir.mktmpdir

         @testfiles.each { |el|
            add_test_file(el[:name])
         }

         @conf_file.puts @tmpdir
      end
      @conf_file.close
   end

   def add_test_file(name = '', path = @tmpdir)
      unless name.empty?
         f = File.new(File.join(path, name), "w")
         f.close
      end
   end

   def clean
      if @tmpdir.is_a?(Array)
         @tmpdir.each { |el|
            FileUtils.remove_entry_secure el, true
         }
      else
         FileUtils.remove_entry_secure @tmpdir, true
      end
      @conf_file.close
      @conf_file.unlink
   end
end
