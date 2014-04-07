require 'spec_helper'

describe OKComputer::OkComputerController do

  routes { OKComputer::Engine.routes }

  describe "GET 'index'" do
    let(:checks) do
      double(:all_checks, {
        to_text: "text of the results",
        to_json: "json of the results",
        success?: nil,
      })
    end

    before do
      OKComputer::Registry.stub(:all) { checks }
      checks.should_receive(:run)
      # not testing authentication here
      controller.class.skip_before_filter :authenticate
    end

    it "performs the basic up check when format: text" do
      get :index, format: :text
      response.body.should == checks.to_text
    end

    it "performs the basic up check when format: html" do
      get :index, format: :html
      response.body.should == checks.to_text
    end

    it "performs the basic up check with accept text/html" do
      request.accept = "text/html"
      get :index
      response.body.should == checks.to_text
    end

    it "performs the basic up check with accept text/plain" do
      request.accept = "text/plain"
      get :index
      response.body.should == checks.to_text
    end

    it "performs the basic up check as JSON" do
      get :index, format: :json
      response.body.should == checks.to_json
    end

    it "performs the basic up check as JSON with accept application/json" do
      request.accept = "application/json"
      get :index
      response.body.should == checks.to_json
    end

    it "returns a failure status code if any check fails" do
      checks.stub(:success?) { false }
      get :index, format: :text
      response.should_not be_success
    end

    it "returns a success status code if all checks pass" do
      checks.stub(:success?) { true }
      get :index, format: :text
      response.should be_success
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
        OKComputer::Registry.should_receive(:fetch).with(check_type) { check }
        check.should_receive(:run)
      end

      it "performs the given check and returns text when format: text" do
        get :show, check: check_type, format: :text
        response.body.should == check.to_text
      end

      it "performs the given check and returns text when format: html" do
        get :show, check: check_type, format: :html
        response.body.should == check.to_text
      end

      it "performs the given check and returns text with accept text/html" do
        request.accept = "text/html"
        get :show, check: check_type
        response.body.should == check.to_text
      end

      it "performs the given check and returns text with accept text/plain" do
        request.accept = "text/plain"
        get :show, check: check_type
        response.body.should == check.to_text
      end

      it "performs the given check and returns JSON" do
        get :show, check: check_type, format: :json
        response.body.should == check.to_json
      end

      it "performs the given check and returns JSON with accept application/json" do
        request.accept = "application/json"
        get :show, check: check_type
        response.body.should == check.to_json
      end

      it "returns a success status code if the check passes" do
        check.stub(:success?) { true }
        get :show, check: check_type, format: :text
        response.should be_success
      end

      it "returns a failure status code if the check fails" do
        check.stub(:success?) { false }
        get :show, check: check_type, format: :text
        response.should_not be_success
      end
    end

    it "returns a 404 if the check does not exist" do
      get :show, check: "non-existant", format: :text
      response.body.should == "No check registered with 'non-existant'"
      response.code.should == "404"
    end

    it "returns a JSON 404 if the check does not exist" do
      get :show, check: "non-existant", format: :json
      response.body.should == { error: "No check registered with 'non-existant'" }.to_json
      response.code.should == "404"
    end

    it "returns a failure status code if given a status check not already registered"
  end

  describe 'newrelic_ignore' do

    let(:load_class) do
      load OKComputer::Engine.root.join("app/controllers/o_k_computer/ok_computer_controller.rb")
    end

    before do
      OKComputer.send(:remove_const, 'OkComputerController')
    end

    context "#newrelic_ignore" do

      context "#when NewRelic is installed" do
        before do
          stub_const('NewRelic::Agent::Instrumentation::ControllerInstrumentation', Module.new)
        end

        it "should inject newrelic_ignore" do
          Object.any_instance.should_receive(:newrelic_ignore).with(no_args())
          load_class
        end
      end

      context "#when NewRelic is not installed" do
        it "should not inject newrelic_ignore" do
          Object.any_instance.should_not_receive(:newrelic_ignore)
          load_class
        end
      end
    end
  end
end
