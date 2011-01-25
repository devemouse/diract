require 'helper'
require 'diract'

class TestDiract < Test::Unit::TestCase

  should "list anything" do
     assert_not_nil Diract.new("diract.conf").list
  end
end
