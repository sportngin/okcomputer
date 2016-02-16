require 'grape'
require 'spec_helper'
require 'rack/test'
require 'okcomputer'
require "ok_computer/registry"

class ApplicationApi < Grape::API
  mount ::OkComputer::GrapeApi => '/'
end

def app
  ApplicationApi
end

describe OkComputer::GrapeApi do
  include Rack::Test::Methods

  describe "GET 'index'" do
    let(:checks) do
      double(:all_checks, {
        to_text: "text of the results",
        to_json: "json of the results",
        success?: nil,
      })
    end

    before do
      OkComputer::Registry.stub(:all) { checks }
      checks.should_receive(:run)
    end

    it "performs the basic up check when format: text" do
      get '/', format: :txt
      last_response.body.should == checks.to_text
    end

    it "performs the basic up check when format: html" do
      get '/', format: :html
      last_response.body.should == checks.to_text
    end

    it "performs the basic up check with accept text/html" do
      header 'Accept', 'text/html'
      get '/'
      last_response.body.should == checks.to_text
    end

    it "performs the basic up check with accept text/plain" do
      header 'Accept', 'text/plain'
      get '/'
      last_response.body.should == checks.to_text
    end

    it "performs the basic up check as JSON" do
      get '/', format: :json
      last_response.body.should == checks.to_json
    end

    it "performs the basic up check as JSON with accept application/json" do
      header 'Accept', 'application/json'
      get '/'
      last_response.body.should == checks.to_json
    end

    it "returns a failure status code if any check fails" do
      checks.stub(:success?) { false }
      get '/', format: :txt
      last_response.ok?.should be false
    end

    it "returns a success status code if all checks pass" do
      checks.stub(:success?) { true }
      get '/', format: :txt
      last_response.ok?.should be true
    end
  end

  describe "GET 'show'" do
    let(:check_type) { "basic" }
    let(:check) do
      double(:single_check, {
        to_text: "text of check",
        to_json: "json of check",
        success?: nil,
      })
    end

    context "existing check-type" do
      before do
        OkComputer::Registry.should_receive(:fetch).with(check_type) { check }
        check.should_receive(:run)
      end

      it "performs the given check and returns text when format: text" do
        get "/#{check_type}", format: :txt
        last_response.body.should == check.to_text
      end

      it "performs the given check and returns text when format: html" do
        get "/#{check_type}", format: :html
        last_response.body.should == check.to_text
      end

      it "performs the given check and returns text with accept text/html" do
        header 'Accept', 'text/html'
        get "/#{check_type}"
        last_response.body.should == check.to_text
      end

      it "performs the given check and returns text with accept text/plain" do
        header 'Accept', 'text/plain'
        get "/#{check_type}"
        last_response.body.should == check.to_text
      end

      it "performs the given check and returns JSON" do
        get "/#{check_type}", format: :json
        last_response.body.should == check.to_json
      end

      it "performs the given check and returns JSON with accept application/json" do
        header 'Accept', 'application/json'
        get "/#{check_type}"
        last_response.body.should == check.to_json
      end

      it "returns a success status code if the check passes" do
        check.stub(:success?) { true }
        get "/#{check_type}", format: :txt
        last_response.ok?.should be true
      end

      it "returns a failure status code if the check fails" do
        check.stub(:success?) { false }
        get "/#{check_type}", format: :txt
        last_response.ok?.should be false
      end
    end

    it "returns a 404 if the check does not exist" do
      get "/non-existent", format: :txt

      last_response.body.should == "No check registered with 'non-existent'"
      last_response.status.should == 404
    end

    it "returns a JSON 404 if the check does not exist" do
      get "/non-existent", format: :json
      last_response.body.should == { error: "No check registered with 'non-existent'" }.to_json
      last_response.status.should == 404
    end
  end

  describe 'newrelic_ignore' do
    let(:checks) do
      double(:all_checks, {
        to_text: "text of the results",
        to_json: "json of the results",
        success?: nil,
      })
    end

    before do
      OkComputer::Registry.stub(:all) { checks }
      checks.should_receive(:run)
    end

    context "when NewRelic is installed" do
      before do
        stub_const('NewRelic::Agent', Module.new)
      end

      context "when analytics_ignore is true" do
        before { OkComputer.stub(:analytics_ignore){ true } }

        it "should tell NewRelic to ignore_transaction" do
          NewRelic::Agent.should_receive(:ignore_transaction)
          get '/', format: :txt
        end
      end

      context "when analytics_ignore is false" do
        before { OkComputer.stub(:analytics_ignore){ false } }

        it "should not tell NewRelic to ignore_transaction" do
          NewRelic::Agent.should_not_receive(:ignore_transaction)
          get '/', format: :txt
        end
      end
    end

    context "when NewRelic is not installed" do
      before { OkComputer.stub(:analytics_ignore){ true } }

      it "should not tell NewRelic to ignore_transaction" do
        expect(defined?(NewRelic::Agent)).to be_falsy
        get '/', format: :txt
      end
    end
  end

end
