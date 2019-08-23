defmodule Wallaby.Session do
  @moduledoc false

  @type t :: %__MODULE__{
    id: String.t,
    session_url: String.t,
    url: String.t,
    server: pid | :none,
    screenshots: list,
    driver: module,
    use_w3c: boolean
  }

  defstruct [:id, :url, :session_url, :driver, server: :none, screenshots: [], use_w3c: false]
end
