require "helper"

describe PortalCommunicator do
  before do
    Chef::Log.stubs(:error)
  end

  # initialisation

  it "raises error when endpoint is not specified" do
    assert_raises ArgumentError do
      PortalCommunicator.new.client_post
    end
  end

end
