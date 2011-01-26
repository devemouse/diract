require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase
   context "diract" do
      setup do
         prepare_conf
      end

      should "delete file of given parameter (a0) and return it's name and desctiption" do
         f = File.new(File.join(@tmpdir, ".diract"), "w")
         described_files = Hash.new
         @testfiles.each { |el|
            described_files[el[:name]] = el[:desc]
         }

         YAML.dump( described_files, f )
         f.close
         diract = Diract.new(@conf_file.path)

         assert File.exists?(File.join(@tmpdir, @testfiles[0][:name])), "something is wrong, test file was not created in setup"

         assert_equal @testfiles[0][:name] + ': ' + @testfiles[0][:desc], diract.delete("a0"), "diract did not retutn file path it deleted"

         assert !File.exists?(File.join(@tmpdir, @testfiles[0][:name])), "diract did not delete requested file"
      end

      teardown do
         clean
      end
   end
end
