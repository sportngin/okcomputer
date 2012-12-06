require 'spec_helper'

describe OkComputerController do
  describe "GET 'index'" do
    let(:checks) { stub(:all_checks)}

    before do
      OKComputer::Registry.stub(:all) { checks }
    end

    it "performs the basic up check" do
      checks.stub(:to_text) { "text of the results" }
      get :index, format: :text
      response.body.should == checks.to_text
    end

    it "performs the basic up check as JSON" do
      checks.stub(:to_json) { "json of the results" }
      get :index, format: :json
      response.body.should == checks.to_json
    end

    it "returns a failure status code if any check fails"

    it "returns a success status code if all checks pass"
  end

  describe "GET 'show'" do
    let(:check_type) { "basic" }
    let(:check) { stub(:single_check) }

    before do
      OKComputer::Registry.should_receive(:fetch).with(check_type) { check }
    end

    it "performs the given check and returns text" do
      check.stub(:to_text) { "text of check" }
      get :show, check: check_type, format: :text
      response.body.should == check.to_text
    end

    it "performs the given check and returns JSON" do
      check.stub(:to_json) { "json of check" }
      get :show, check: check_type, format: :json
      response.body.should == check.to_json
    end

    it "returns a success status code if the check passes"
    it "returns a failure status code if the check fails"
    it "returns a failure status code if given a status check not already registered"
  end
end
