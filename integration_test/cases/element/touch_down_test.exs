defmodule Wallaby.Integration.Element.TouchDownTest do
  use Wallaby.Integration.SessionCase, async: true

  setup %{session: session} do
    page = visit(session, "touch.html")

    {:ok, %{page: page}}
  end

  describe "touch_down/1" do
    test "touches and holds given element", %{page: page} do
      element = find(page, Query.text("Touch me!"))

      refute visible?(page, Query.text("Start"))

      Element.touch_down(element)

      assert visible?(page, Query.text("Start"))
      refute visible?(page, Query.text("End"))
    end

    # test "supports multiple touches", %{page: page} do
    #   element1 = find(page, Query.text("Touch me!"))
    #   element2 = find(page, Query.text("You can also touch me!"))

    #   assert page |> find(Query.css("#log-count-touches")) |> Element.text() == "0"

    #   Element.touch_down(element1, "touch 1")

    #   assert page |> find(Query.css("#log-count-touches")) |> Element.text() == "1"

    #   Element.touch_down(element2, " touch 2")

    #   assert page |> find(Query.css("#log-count-touches")) |> Element.text() == "2"
    # end
  end
end
