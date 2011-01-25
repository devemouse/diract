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
   def prepare_conf
      @tmpdir = Dir.mktmpdir
      @file = Tempfile.new('foo')

      @file.puts @tmpdir
   end

   def clean
      FileUtils.remove_entry_secure @tmpdir, true
      @file.close
      @file.unlink
   end
end
