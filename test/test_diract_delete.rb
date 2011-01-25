require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase
   context "diract" do
      setup do
         prepare_conf
      end


      should "fake" do
         list =  Diract.new("diract.conf").list
         assert_not_nil list
         puts list
      end

      teardown do
         clean
      end
   end
end
