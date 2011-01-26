require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase

   context "diract" do
      setup do
         prepare_conf
      end

      should "list files in directory" do
         list = Diract.new(@conf_file.path).list
         assert_not_nil list
         assert list.is_a?(String), "returned listing is not printable"
         assert !list.empty?, "returned list is empty"

         assert list.include?(@tmpdir.to_s), "action directory path was not listed"

         @testfiles.each {|el|
            assert list.include?(el), "one of test files is missing: #{el}"
         }
      end

      should "assign letters to directories" do
         list = Diract.new(@conf_file.path).list

         reg = Regexp.new( '\([a-zA-Z]{1}\) ' + @tmpdir)

         assert reg.match(list).nil?, "diract did not assign letter to directory"

         @testfiles.each {|el|
            reg = Regexp.new('[ ]*' + @testfiles[0] + ' \([ ]*\d\)')
            assert reg.match(list).nil?, "diract did not assign numbers to files"
         }
      end

      should "assign numbers to files in direcory" do
         list = Diract.new(@conf_file.path).list
         @testfiles.each {|el|
            reg = Regexp.new('[ ]*' + @testfiles[0] + ' \([ ]*\d\)')
            assert reg.match(el).nil?, "list did not assign numbers to files"
         }
      end

      teardown do
         clean
      end
   end

end
