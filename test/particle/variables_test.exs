defmodule Particle.VariablesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes/particle/variables")
    ExVCR.Config.filter_sensitive_data("Bearer .+", "TOKEN")
    ExVCR.Config.filter_sensitive_data("(.*)" <> (System.get_env("device_id") || "DEVICE_ID") <> "(.*)", "\\1DEVICE_ID\\2")
    ExVCR.Config.filter_sensitive_data("(?:\\d{1,3}\\.){3}\\d{1,3}", "0.0.0.0")
    :ok
  end

  describe "get with a valid device_id and variable_name" do
    test "it returns the value of the variable" do
      use_cassette "get" do
        device_id = System.get_env("device_id") || "DEVICE_ID"
        response = Particle.Variables.get(device_id, "power")
        assert {:ok, r} = response
        assert r.result == 0
      end
    end
  end

  describe "get with an invalid device_id" do
    test "it returns an error tuple" do
      use_cassette "get_invalid_device_id" do
        response = Particle.Variables.get("MISSING", "power")
        assert response == {:error, %Particle.Error{reason: "Permission Denied", code: 403, info: "I didn't recognize that device name or ID, try opening https://api.particle.io/v1/devices?access_token=undefined"}}
      end
    end
  end

  describe "get with an invalid variable_name" do
    test "it returns an error tuple" do
      use_cassette "get_invalid_variable_name" do
        device_id = System.get_env("device_id") || "DEVICE_ID"
        response = Particle.Variables.get(device_id, "MISSING")
        assert response == {:error, %Particle.Error{reason: "Variable not found", code: 404}}
      end
    end
  end

  describe "get_all_with_values" do
    test "it returns a map of variables with their values" do
      use_cassette "get_all_with_values" do
        device_id = System.get_env("device_id") || "DEVICE_ID"
        response = Particle.Variables.get_all_with_values(device_id)
        assert {:ok, r} = response
        assert r == %{min_average: 90.7249984741211, power: 0, temp_off: 65, temp_on: 60, temperature: 90.7249984741211}
      end
    end
  end
end
