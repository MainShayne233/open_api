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
          "email" => "contact@me.com"
        },
        "license" => %{
          "name" => "License Name",
          "url" => "http://license.url.com"
        },
        "version" => "3.0.0"
      },
      "servers" => [
        %{
          "url" => "https://dev.server.com",
          "description" => "Development server"
        },
        %{
          "url" => "https://staging.server.com",
          "description" => "Staging server"
        },
        %{
          "url" => "https://{username}.gigantic-server.com:{port}/{basePath}",
          "description" => "Production server",
          "variables" => %{
            "username" => %{
              "default" => "demo",
              "description" =>
                "this value is assigned by the service provider, in this example `gigantic-server.com`"
            },
            "port" => %{
              "enum" => [
                "8443",
                "443"
              ],
              "default" => "8443"
            },
            "basePath" => %{
              "default" => "v2"
            }
          }
        }
      ]
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
                      email: "contact@me.com"
                    },
                    license: %V3.License{
                      name: "License Name",
                      url: "http://license.url.com"
                    },
                    version: "3.0.0"
                  },
                  servers: [
                    %V3.Server{
                      url: "https://dev.server.com",
                      description: "Development server"
                    },
                    %V3.Server{
                      url: "https://staging.server.com",
                      description: "Staging server"
                    },
                    %V3.Server{
                      url: "https://{username}.gigantic-server.com:{port}/{basePath}",
                      description: "Production server",
                      variables: %{
                        "username" => %V3.ServerVariable{
                          default: "demo",
                          description:
                            "this value is assigned by the service provider, in this example `gigantic-server.com`"
                        },
                        "port" => %V3.ServerVariable{
                          enum: [
                            "8443",
                            "443"
                          ],
                          default: "8443"
                        },
                        "basePath" => %V3.ServerVariable{
                          default: "v2"
                        }
                      }
                    }
                  ]
                }}
    end
  end
end
