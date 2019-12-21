defmodule OpenAPI.V3.DocumentTest do
  use ExUnit.Case

  alias OpenAPI.V3

  setup do
    valid_document = %{
      "openapi" => "3.0.0",
      "info" => %{
        "title" => "MyAPI",
        "description" => "My API that does things",
        "termsOfService" => "http://terms.of.service.com",
        "contact" => %{
          "name" => "Contact Name",
          "url" => "http://contact.url.com",
          "email" => "contact@me.com",
        },
        "license" => %{
          "name" => "License Name",
          "url" => "http://license.url.com",
        },
        "version" => "3.0.0"
      }
    }

    %{valid_document: valid_document}
  end

  describe "cast/1" do
    test "should cast a valid open API document into a Document.t()", %{valid_document: document} do
      assert V3.Document.cast(document) ==
               {:ok,
                %V3.Document{
                  openapi: "3.0.0",
                  info: %V3.Info{
                    title: "MyAPI",
                    description: "My API that does things",
                    terms_of_service: "http://terms.of.service.com",
                    contact: %V3.Contact{
                      name: "Contact Name",
                      url: "http://contact.url.com",
                      email: "contact@me.com",
                    },
                    license: %V3.License{
                      name: "License Name",
                      url: "http://license.url.com",
                    },
                    version: "3.0.0"
                  }
                }}
    end
  end
end
