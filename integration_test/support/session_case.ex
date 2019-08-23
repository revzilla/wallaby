defmodule Wallaby.Integration.SessionCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL
      import Wallaby.Integration.SessionCase
    end
  end

  setup :inject_test_session

  @doc """
  Starts a test session with the default opts for the given driver
  """
  def start_test_session(opts \\ []) do
    session_opts =
      "WALLABY_DRIVER"
      |> System.get_env()
      |> default_opts_for_driver
      |> Keyword.merge(opts)

    with {:ok, session} <- retry(2, fn -> Wallaby.start_session(session_opts) end),
      do: {:ok, session}
  end

  @doc """
  Injects a test session into the test context
  """
  def inject_test_session(%{skip_test_session: true}), do: :ok
  def inject_test_session(_context) do
    {:ok, session} = start_test_session()

    {:ok, %{session: session}}
  end

  defp retry(0, f), do: f.()
  defp retry(times, f) do
    case f.() do
      {:ok, session} -> {:ok, session}
      _ -> retry(times - 1, f)
    end
  end

  defp default_opts_for_driver(driver), do: default_opts_for_driver(driver, System.get_env("USE_W3C"))
  defp default_opts_for_driver("phantom", nil), do: []
  defp default_opts_for_driver("selenium", nil) do
    [
      capabilities: %{
        browserName: "firefox",
        "moz:firefoxOptions": %{
          args: ["-headless"]
        }
      }
    ]
  end
  defp default_opts_for_driver("selenium", _use_w3c) do
    [
      use_w3c: true,
      capabilities: %{
        firstMatch: [
          %{
            browserName: "firefox",
            "moz:firefoxOptions": %{
              args: [
                "-headless"
              ]
            }
          }
        ]
      }
    ]
  end
  defp default_opts_for_driver("chrome", nil), do: []
  defp default_opts_for_driver("chrome", _use_w3c), do: [use_w3c: true]
  defp default_opts_for_driver(other, _) do
    raise "Unknown value for WALLABY_DRIVER environment variable: #{other}"
  end
end
