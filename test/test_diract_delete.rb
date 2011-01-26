require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase
   context "diract" do
      setup do
         prepare_conf
      end

      should "fake" do
         list =  Diract.new(@conf_file.path).list
         assert_not_nil list
         puts list if $DEBUG
      end

      teardown do
         clean
      end
   end
end
