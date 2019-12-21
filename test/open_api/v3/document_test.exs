defmodule OpenAPI.V3.DocumentTest do
  use ExUnit.Case
  alias OpenAPI.V3.Document

  setup do
    document = %{}
    %{document: document}
  end

  describe "cast/1" do
    test "should cast a valid open API document into a Document.t()", %{document: document} do
      assert {:ok, %Document{}} = Document.cast(document)
    end
  end
end
