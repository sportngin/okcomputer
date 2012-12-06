require "spec_helper"

module OKComputer
  describe CheckCollection do
    let(:foocheck) { stub(:check) }
    let(:barcheck) { stub(:check) }
    let(:registry) { {foo: foocheck, bar: barcheck} }

    subject { CheckCollection.new registry }

    context ".new registry" do
      it "remembers the registry of checks given to it" do
        subject.registry.should == registry
      end
    end

    context "#checks" do
      it "returns the checks from its registry" do
        subject.checks.should == registry.values
      end
    end

    context "#to_text" do
      it "returns the #to_text of each check on a new line" do
        foocheck.stub(:to_text) { "foo" }
        barcheck.stub(:to_text) { "bar" }
        subject.to_text.should == [foocheck.to_text, barcheck.to_text].join("\n")
      end
    end

    context "#to_json" do
      it "returns the #to_json of each check in a JSON array" do
        foocheck.stub(:to_json) { {"foo" => "foo result"}.to_json }
        barcheck.stub(:to_json) { {"bar" => "bar result"}.to_json }
        subject.to_json.should == "[#{foocheck.to_json},#{barcheck.to_json}]"
      end
    end
  end
end
