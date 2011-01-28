require 'helper'
require 'diract'
require 'yaml'

class TestDiract < Test::Unit::TestCase

   context "diract" do
      setup do
         prepare_conf
      end

      should "create empty configuration file when it does not exist" do
         #create temprary config file...
         temp_conf = Tempfile.new('tmp_cfg')
         temp_conf_path = temp_conf.path

         #but delete it immediately since we want to check if it gets created
         temp_conf.close
         temp_conf.unlink

         assert !File.exists?(temp_conf_path), "oops, temp config was not yet deleted, fix this test"
         Diract.new(temp_conf_path)
         assert File.exists?(temp_conf_path), "diract did not create config file"
         FileUtils.remove_entry_secure temp_conf_path, true
      end

      should "list files in directory" do
         list = Diract.new(@conf_file.path).list
         assert_not_nil list
         assert list.is_a?(String), "returned listing is not printable"
         assert !list.empty?, "returned list is empty"


         assert list.include?(@tmpdir.to_s), "action directory path was not listed"

         @testfiles.each {|el|
            assert list.include?(el[:name]), "one of test files is missing: #{el}"
         }
      end


      should "create .diract when it does not exist"do
         assert !File.exists?(File.join(@tmpdir, '.diract')), ".diract already exists im temp directory"

         list = Diract.new(@conf_file.path).list

         assert File.exists?(File.join(@tmpdir, '.diract')), "diract did not create .diract file in destination dir"
      end

      should "read .diract if it already exist and display desctiptions" do

         f = File.new(File.join(@tmpdir, ".diract"), "w")
         described_files = Hash.new
         @testfiles.each { |el|
            described_files[el[:name]] = el[:desc]
         }

         YAML.dump( described_files, f )
         f.close

         f = File.new(File.join(@tmpdir, ".diract"), "r")

         list = Diract.new(@conf_file.path).list

         @testfiles.each {|el|
            reg = Regexp.new('[ ]*' + el[:name] + '.*: ' + el[:desc].to_s)
            assert !reg.match(list).nil?, "diract did not display file desctiptions"
         }
      end


      should "assign letters to directories" do
         list = Diract.new(@conf_file.path).list

         reg = Regexp.new( '\([a-zA-Z]{1}\) ' + @tmpdir)

         assert reg.match(list).nil?, "diract did not assign letter to directory"

         @testfiles.each {|el|
            reg = Regexp.new('[ ]*' + el[:name] + ' \([ ]*\d\)')
            assert reg.match(list).nil?, "diract did not assign numbers to files"
         }
      end

      should "assign numbers to files in direcory" do
         list = Diract.new(@conf_file.path).list
         @testfiles.each {|el|
            reg = Regexp.new('[ ]*' + el[:name] + ' \([ ]*\d\)')
            assert reg.match(el[:name]).nil?, "list did not assign numbers to files"
         }
      end

      should "remove entries from .diract if files are deleted" do
         list_before = Diract.new(@conf_file.path).list

         FileUtils.remove_entry_secure File.join(@tmpdir, @testfiles[0][:name]), true

         list_after = Diract.new(@conf_file.path).list

         assert_not_equal list_after, list_before, "diract did not update .diract"
      end

      should "add entries to .diract if new files are created" do
         skip "test not implemented"
      end

      teardown do
         clean
      end
   end

end
