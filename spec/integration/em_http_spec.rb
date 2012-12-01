require "spec_helper"
require "integration/support/server"

describe HTTPI::Adapter::EmHttpRequest do

  # em_http is not supported on ruby 1.8
  unless RUBY_VERSION =~ /1\.8/
    require "em-synchrony"

    subject(:adapter) { :em_http }

    around :each do |example|
      EM.synchrony do
        example.run
        EM.stop
      end
    end

    context "http requests" do
      before :all do
        WebMock.allow_net_connect!
        @server = IntegrationServer.run
      end

      after :all do
        @server.stop
      end

      it "sends and receives HTTP headers" do
        request = HTTPI::Request.new(@server.url + "x-header")
        request.headers["X-Header"] = "HTTPI"

        response = HTTPI.get(request, adapter)
        response.body.should include("HTTPI")
      end

      it "executes GET requests" do
        response = HTTPI.get(@server.url, adapter)
        response.body.should eq("get")
        response.headers["Content-Type"].should eq("text/plain")
      end

      it "executes POST requests" do
        response = HTTPI.post(@server.url, "<some>xml</some>", adapter)
        response.body.should eq("post")
        response.headers["Content-Type"].should eq("text/plain")
      end

      it "executes HEAD requests" do
        response = HTTPI.head(@server.url, adapter)
        response.code.should == 200
        response.headers["Content-Type"].should eq("text/plain")
      end

      it "executes PUT requests" do
        response = HTTPI.put(@server.url, "<some>xml</some>", adapter)
        response.body.should eq("put")
        response.headers["Content-Type"].should eq("text/plain")
      end

      it "executes DELETE requests" do
        response = HTTPI.delete(@server.url, adapter)
        response.body.should eq("delete")
        response.headers["Content-Type"].should eq("text/plain")
      end

      it "supports basic authentication" do
        request = HTTPI::Request.new(@server.url + "basic-auth")
        request.auth.basic("admin", "secret")

        response = HTTPI.get(request, adapter)
        response.body.should eq("basic-auth")
      end

      # it does not support digest authentication
    end

    # it does not support ssl authentication

  end
end
