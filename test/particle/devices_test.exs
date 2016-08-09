defmodule Particle.DevicesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes/particle/devices")
    ExVCR.Config.filter_sensitive_data("Bearer .+", "TOKEN")
    ExVCR.Config.filter_sensitive_data("(.*)" <> (System.get_env("device_id") || "DEVICE_ID") <> "(.*)", "\\1DEVICE_ID\\2")
    ExVCR.Config.filter_sensitive_data("(?:\\d{1,3}\\.){3}\\d{1,3}", "0.0.0.0")
    HTTPoison.start
    :ok
  end

  describe "get" do
    test "it returns an array of Particle.Device structs" do
      use_cassette "get" do
        response = Particle.Devices.get
        assert {:ok, devices} = response
        assert devices |> Enum.at(0) |> Map.get(:id) == "DEVICE_ID"
      end
    end
  end
end
