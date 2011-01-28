require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase
   context "diract" do
      setup do
         prepare_conf
      end

      should "be able to describe given file" do
         f = File.new(File.join(@tmpdir, ".diract"), "w")
         described_files = Hash.new
         @testfiles.each { |el|
            described_files[el[:name]] = el[:desc]
         }

         YAML.dump( described_files, f )
         f.close

         diract = Diract.new(@conf_file.path)

         new_description =  "XXX_description_XXX"

         assert_equal @testfiles[2][:name] + ": " + new_description, diract.describe("a2", new_description)

         list = Diract.new(@conf_file.path).list

         @testfiles[2][:desc] = new_description

         #puts list
         @testfiles.each {|el|
            reg = Regexp.new('[ ]*' + el[:name] + '.*: ' + el[:desc].to_s)
            assert !reg.match(list).nil?, "diract did not update file desctiptions"
         }
      end

      teardown do
         clean
      end
   end
end
