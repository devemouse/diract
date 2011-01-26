require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase
   context "diract" do
      setup do
         prepare_conf
      end

      should "be able to describe given file" do
         flunk "not implemented"
      end

      teardown do
         clean
      end
   end
end
