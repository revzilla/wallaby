defmodule Wallaby.Integration.Element.TouchScrollTest do
  use Wallaby.Integration.SessionCase, async: true

  setup %{session: session} do
    page = visit(session, "touch.html")

    {:ok, %{page: page}}
  end

  describe "touch_scroll/3" do
    test "Touches the given element, scrolls by the given offset and stops touching", %{page: page} do
      refute visible?(page, Query.text("Start"))
      refute visible?(page, Query.text("Move"))
      refute visible?(page, Query.text("End"))

      element = find(page, Query.text("Touch me!"))

      Element.touch_scroll(element, 105, 105)

      assert visible?(page, Query.text("Start"))
      assert visible?(page, Query.text("Move"))
      assert visible?(page, Query.text("End"))
    end
  end
end
