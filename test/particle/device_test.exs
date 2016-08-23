defmodule Particle.DeviceTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes/particle/device")
    ExVCR.Config.filter_sensitive_data("Bearer .+", "TOKEN")
    ExVCR.Config.filter_sensitive_data("(.*)" <> (System.get_env("device_id") || "DEVICE_ID") <> "(.*)", "\\1DEVICE_ID\\2")
    ExVCR.Config.filter_sensitive_data("(?:\\d{1,3}\\.){3}\\d{1,3}", "0.0.0.0")
    :ok
  end

  describe "get with an existing device_id" do
    test "it returns a Particle.Device struct" do
      use_cassette "get" do
        device_id = System.get_env("device_id") || "DEVICE_ID"

        response = Particle.Device.get(device_id)
        assert {:ok, device} = response
        assert device.id == "DEVICE_ID"
      end
    end
  end

  describe "get with a non-existing device_id" do
    test "it returns an error tuple" do
      use_cassette "missing_get" do
        response = Particle.Device.get("MISSING")
        assert response == {:error, %Particle.Error{reason: "Permission Denied", code: 403, info: "I didn't recognize that device name or ID, try opening https://api.particle.io/v1/devices?access_token=undefined"}}
      end
    end
  end
end
