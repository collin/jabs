require 'rspec/jabs_spec_helper'

describe Jabs::Precompiler do
  before(:each) do
    @p = Jabs::Precompiler.new

    def johnsonize_source sexp
      @p.johnsonize(@p.source(sexp))
    end
  end

  def assert_ecma src, target
    Johnson::Parser.parse(src.to_ecma).to_ecma.should == Johnson::Parser.parse(target).to_ecma
  end

#   it "builds on ready functions" do
#     assert_ecma johnsonize_source(@p.onready), "jQuery(document).bind(\"ready\", function(){})"
#   end
# 
#   it "builds functions" do
#     assert_ecma johnsonize_source(@p.function), "function(){}"
#   end
# 
#   it "builds jquery expressions" do
#     assert_ecma johnsonize_source(@p.jquery [:string, "selector"]), "jQuery(\"selector\")"
#   end
# 
#   it "builds event binders" do 
#     assert_ecma johnsonize_source(@p.event_bind('click', [:name, "reference"])),
#                 "reference.bind(\"click\", function() {})"
#   end
# 
#   it "builds nested combinations" do
#     assert_ecma johnsonize_source(@p.onready( @p.jquery([:string, "selector"]))), 
#                 "jQuery(document).bind(\"ready\",function(){jQuery(\"selector\")})"
#   end
end
