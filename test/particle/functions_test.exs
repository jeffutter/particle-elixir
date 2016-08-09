defmodule Particle.FunctionsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes/particle/functions")
    ExVCR.Config.filter_sensitive_data("Bearer .+", "TOKEN")
    ExVCR.Config.filter_sensitive_data("(.*)" <> (System.get_env("device_id") || "DEVICE_ID") <> "(.*)", "\\1DEVICE_ID\\2")
    ExVCR.Config.filter_sensitive_data("(?:\\d{1,3}\\.){3}\\d{1,3}", "0.0.0.0")
    HTTPoison.start
    :ok
  end

  describe "post with a valid function" do
    test "it returns the value of the function call" do
      use_cassette "post" do
        device_id = System.get_env("device_id") || "DEVICE_ID"
        response = Particle.Functions.post(device_id, "power", "off")
        assert {:ok, r} = response
        assert r.return_value == 1
      end
    end
  end

  describe "post with an invalid function" do
    test "it returns an error tuple" do
      use_cassette "missing_function" do
        device_id = System.get_env("device_id") || "DEVICE_ID"
        response = Particle.Functions.post(device_id, "MISSING", "off")
        assert response == {:error, "Function MISSING not found", 404}
      end
    end
  end
end
