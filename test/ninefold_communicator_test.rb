require "helper"

describe NinefoldCommunicator do
  before do
    Chef::Log.stubs(:error)
  end

  # initialisation

  it "raises error when endpoint is not specified" do
    assert_raises ArgumentError do
      NinefoldCommunicator.new.client_post
    end
  end

end
