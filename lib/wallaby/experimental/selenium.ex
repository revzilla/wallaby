defmodule Wallaby.Experimental.Selenium do
  @moduledoc false
  use Supervisor

  @behaviour Wallaby.Driver

  alias Wallaby.{Element, Session}
  alias Wallaby.Experimental.Selenium.WebdriverClient
  alias Wallaby.Experimental.Selenium.W3CWebdriverClient

  @type start_session_opts ::
    {:remote_url, String.t} |
    {:capabilities, map} |
    {:create_session_fn, ((String.t, map) -> {:ok, %{}})}

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
    ]

    supervise(children, strategy: :one_for_one)
  end

  def validate do
    :ok
  end

  @spec start_session([start_session_opts]) :: {:ok, Session.t}
  def start_session(opts \\ []) do
    use_w3c = Keyword.get(opts, :use_w3c, false)
    base_url = Keyword.get(opts, :remote_url, "http://localhost:4444/wd/hub/")
    capabilities = Keyword.get(opts, :capabilities, nil)
    default_create_session_fn = if use_w3c do
      &W3CWebdriverClient.create_session/2
    else
      &WebdriverClient.create_session/2
    end
    create_session_fn = Keyword.get(opts, :create_session_fn, default_create_session_fn)

    capabilities =
      capabilities || default_capabilities()

    with {:ok, response} <- create_session_fn.(base_url, capabilities) do
      id = response["value"]["sessionId"] || response["sessionId"]

      session = %Wallaby.Session{
        session_url: base_url <> "session/#{id}",
        url: base_url <> "session/#{id}",
        id: id,
        driver: __MODULE__,
        use_w3c: use_w3c
      }

      if window_size = Keyword.get(opts, :window_size),
        do: {:ok, _} = set_window_size(session, window_size[:width], window_size[:height])

      {:ok, session}
    end
  end

  @type end_session_opts ::
    {:end_session_fn, ((Session.t) -> any)}

  @doc """
  Invoked to end a browser session.
  """
  @spec end_session(Session.t, [end_session_opts]) :: :ok
  def end_session(session, opts \\ []) do
    default_delete_session_fn = if session.use_w3c do
      &W3CWebdriverClient.delete_session/1
    else
      &WebdriverClient.delete_session/1
    end
    end_session_fn = Keyword.get(opts, :end_session_fn, default_delete_session_fn)

    end_session_fn.(session)
    :ok
  end

  def blank_page?(session) do
    case current_url(session) do
      {:ok, url} ->
        url == "about:blank"
      _ ->
        false
    end
  end

  def window_handle(%{use_w3c: true} = session), do: W3CWebdriverClient.window_handle(session)
  def window_handle(%{use_w3c: false} = session), do: WebdriverClient.window_handle(session)
  def window_handles(%{use_w3c: true} = session), do: W3CWebdriverClient.window_handles(session)
  def window_handles(%{use_w3c: false} = session), do: WebdriverClient.window_handles(session)
  def focus_window(%{use_w3c: true} = session, window_handle), do: W3CWebdriverClient.focus_window(session, window_handle)
  def focus_window(%{use_w3c: false} = session, window_handle), do: WebdriverClient.focus_window(session, window_handle)
  def close_window(%{use_w3c: true} = session), do: W3CWebdriverClient.close_window(session)
  def close_window(%{use_w3c: false} = session), do: WebdriverClient.close_window(session)
  def get_window_size(%{use_w3c: true} = session), do: W3CWebdriverClient.get_window_size(session)
  def get_window_size(%{use_w3c: false} = session), do: WebdriverClient.get_window_size(session)
  def set_window_size(%{use_w3c: true} = session, width, height), do: W3CWebdriverClient.set_window_size(session, width, height)
  def set_window_size(%{use_w3c: false} = session, width, height), do: WebdriverClient.set_window_size(session, width, height)
  def get_window_position(%{use_w3c: true} = session), do: W3CWebdriverClient.get_window_position(session)
  def get_window_position(%{use_w3c: false} = session), do: WebdriverClient.get_window_position(session)
  def set_window_position(%{use_w3c: true} = session, x, y), do: W3CWebdriverClient.set_window_position(session, x, y)
  def set_window_position(%{use_w3c: false} = session, x, y), do: WebdriverClient.set_window_position(session, x, y)
  def maximize_window(%{use_w3c: true} = session), do: W3CWebdriverClient.maximize_window(session)
  def maximize_window(%{use_w3c: false} = session), do: WebdriverClient.maximize_window(session)
  def focus_frame(%{use_w3c: true} = session, frame), do: W3CWebdriverClient.focus_frame(session, frame)
  def focus_frame(%{use_w3c: false} = session, frame), do: WebdriverClient.focus_frame(session, frame)
  def focus_parent_frame(%{use_w3c: true} = session), do: W3CWebdriverClient.focus_parent_frame(session)
  def focus_parent_frame(%{use_w3c: false} = session), do: WebdriverClient.focus_parent_frame(session)
  def accept_alert(%{use_w3c: true} = session, fun), do: W3CWebdriverClient.accept_alert(session, fun)
  def accept_alert(%{use_w3c: false} = session, fun), do: WebdriverClient.accept_alert(session, fun)
  def dismiss_alert(%{use_w3c: true} = session, fun), do: W3CWebdriverClient.dismiss_alert(session, fun)
  def dismiss_alert(%{use_w3c: false} = session, fun), do: WebdriverClient.dismiss_alert(session, fun)
  def accept_confirm(%{use_w3c: true} = session, fun), do: W3CWebdriverClient.accept_confirm(session, fun)
  def accept_confirm(%{use_w3c: false} = session, fun), do: WebdriverClient.accept_confirm(session, fun)
  def dismiss_confirm(%{use_w3c: true} = session, fun), do: W3CWebdriverClient.dismiss_confirm(session, fun)
  def dismiss_confirm(%{use_w3c: false} = session, fun), do: WebdriverClient.dismiss_confirm(session, fun)
  def accept_prompt(%{use_w3c: true} = session, input, fun), do: W3CWebdriverClient.accept_prompt(session, input, fun)
  def accept_prompt(%{use_w3c: false} = session, input, fun), do: WebdriverClient.accept_prompt(session, input, fun)
  def dismiss_prompt(%{use_w3c: true} = session, fun), do: W3CWebdriverClient.dismiss_prompt(session, fun)
  def dismiss_prompt(%{use_w3c: false} = session, fun), do: WebdriverClient.dismiss_prompt(session, fun)
  def take_screenshot(%{use_w3c: true} = session_or_element), do: W3CWebdriverClient.take_screenshot(session_or_element)
  def take_screenshot(%{use_w3c: false} = session_or_element), do: WebdriverClient.take_screenshot(session_or_element)
  def cookies(%Session{use_w3c: true} = session), do: W3CWebdriverClient.cookies(session)
  def cookies(%Session{use_w3c: false} = session), do: WebdriverClient.cookies(session)

  def current_path(%Session{use_w3c: true} = session) do
    with  {:ok, url} <- W3CWebdriverClient.current_url(session),
          uri <- URI.parse(url),
          {:ok, path} <- Map.fetch(uri, :path),
      do: {:ok, path}
  end
  def current_path(%Session{use_w3c: false} = session) do
    with  {:ok, url} <- WebdriverClient.current_url(session),
          uri <- URI.parse(url),
          {:ok, path} <- Map.fetch(uri, :path),
      do: {:ok, path}
  end

  def current_url(%Session{use_w3c: true} = session), do: W3CWebdriverClient.current_url(session)
  def current_url(%Session{use_w3c: false} = session), do: WebdriverClient.current_url(session)
  def page_source(%Session{use_w3c: true} = session), do: W3CWebdriverClient.page_source(session)
  def page_source(%Session{use_w3c: false} = session), do: WebdriverClient.page_source(session)
  def page_title(%Session{use_w3c: true} = session), do: W3CWebdriverClient.page_title(session)
  def page_title(%Session{use_w3c: false} = session), do: WebdriverClient.page_title(session)
  def set_cookie(%Session{use_w3c: true} = session, key, value), do: W3CWebdriverClient.set_cookie(session, key, value)
  def set_cookie(%Session{use_w3c: false} = session, key, value), do: WebdriverClient.set_cookie(session, key, value)
  def visit(%Session{use_w3c: true} = session, path), do: W3CWebdriverClient.visit(session, path)
  def visit(%Session{use_w3c: false} = session, path), do: WebdriverClient.visit(session, path)
  def attribute(%Element{use_w3c: true} = element, name), do: W3CWebdriverClient.attribute(element, name)
  def attribute(%Element{use_w3c: false} = element, name), do: WebdriverClient.attribute(element, name)
  def clear(%Element{use_w3c: true} = element), do: W3CWebdriverClient.clear(element)
  def clear(%Element{use_w3c: false} = element), do: WebdriverClient.clear(element)
  def click(%Element{use_w3c: true} = element), do: W3CWebdriverClient.click(element)
  def click(%Element{use_w3c: false} = element), do: WebdriverClient.click(element)
  def click(%{use_w3c: true} = parent, button), do: W3CWebdriverClient.click(parent, button)
  def click(%{use_w3c: false} = parent, button), do: WebdriverClient.click(parent, button)
  def button_down(%{use_w3c: true} = parent, button), do: W3CWebdriverClient.button_down(parent, button)
  def button_down(%{use_w3c: false} = parent, button), do: WebdriverClient.button_down(parent, button)
  def button_up(%{use_w3c: true} = parent, button), do: W3CWebdriverClient.button_up(parent, button)
  def button_up(%{use_w3c: false} = parent, button), do: WebdriverClient.button_up(parent, button)
  def double_click(%{use_w3c: true} = parent), do: W3CWebdriverClient.double_click(parent)
  def double_click(%{use_w3c: false} = parent), do: WebdriverClient.double_click(parent)
  def hover(%Element{use_w3c: true} = element), do: W3CWebdriverClient.move_mouse_to(nil, element)
  def hover(%Element{use_w3c: false} = element), do: WebdriverClient.move_mouse_to(nil, element)
  def move_mouse_by(%{use_w3c: true} = session, x_offset, y_offset), do: W3CWebdriverClient.move_mouse_to(session, nil, x_offset, y_offset)
  def move_mouse_by(%{use_w3c: false} = session, x_offset, y_offset), do: WebdriverClient.move_mouse_to(session, nil, x_offset, y_offset)
  def touch_down(%Element{use_w3c: true} = element, touch_source_id), do: W3CWebdriverClient.touch_down(element, touch_source_id)
  def touch_up(%Session{use_w3c: true} = session, touch_source_id), do: W3CWebdriverClient.touch_up(session, touch_source_id)
  def tap(%Element{use_w3c: true} = element, touch_source_id), do: W3CWebdriverClient.tap(element, touch_source_id)
  def touch_scroll(%Element{use_w3c: true} = element, x_offset, y_offset, touch_source_id), do: W3CWebdriverClient.touch_scroll(element, x_offset, y_offset, touch_source_id)
  def touch_scroll(%Element{use_w3c: false} = element, x_offset, y_offset, touch_source_id), do: WebdriverClient.touch_scroll(element, x_offset, y_offset, touch_source_id)
  def displayed(%Element{use_w3c: true} = element), do: W3CWebdriverClient.displayed(element)
  def displayed(%Element{use_w3c: false} = element), do: WebdriverClient.displayed(element)
  def selected(%Element{use_w3c: true} = element), do: W3CWebdriverClient.selected(element)
  def selected(%Element{use_w3c: false} = element), do: WebdriverClient.selected(element)
  def set_value(%Element{use_w3c: true} = element, value), do: W3CWebdriverClient.set_value(element, value)
  def set_value(%Element{use_w3c: false} = element, value), do: WebdriverClient.set_value(element, value)
  def text(%Element{use_w3c: true} = element), do: W3CWebdriverClient.text(element)
  def text(%Element{use_w3c: false} = element), do: WebdriverClient.text(element)
  def find_elements(%{use_w3c: true} = parent, compiled_query), do: W3CWebdriverClient.find_elements(parent, compiled_query)
  def find_elements(%{use_w3c: false} = parent, compiled_query), do: WebdriverClient.find_elements(parent, compiled_query)
  def execute_script(parent, script, arguments \\ [])
  def execute_script(%{use_w3c: true} = parent, script, arguments), do: W3CWebdriverClient.execute_script(parent, script, arguments)
  def execute_script(%{use_w3c: false} = parent, script, arguments), do: WebdriverClient.execute_script(parent, script, arguments)
  def execute_script_async(parent, script, arguments \\ [])
  def execute_script_async(%{use_w3c: true} = parent, script, arguments), do: W3CWebdriverClient.execute_script_async(parent, script, arguments)
  def execute_script_async(%{use_w3c: false} = parent, script, arguments), do: WebdriverClient.execute_script_async(parent, script, arguments)
  def send_keys(%{use_w3c: true} = parent, keys), do: W3CWebdriverClient.send_keys(parent, keys)
  def send_keys(%{use_w3c: false} = parent, keys), do: WebdriverClient.send_keys(parent, keys)

  defp default_capabilities() do
    %{
      browserName: "firefox",
      "moz:firefoxOptions": %{
        args: [
          "-headless"
        ]
      }
    }
  end
end
