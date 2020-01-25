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
      ],
      "paths" => %{
        "/" => %{
          "$ref" => "http://some.ref.com",
          "summary" => "I am summarizing this path",
          "description" => "I am describing this path",
          "get" => %{
            "tags" => ["tag_a", "tag_b"],
            "summary" => "I am summarizing this operation",
            "description" => "I am describing this operation",
            "externalDocs" => %{
              "url" => "http://external.docs.com",
              "description" => "I am describing these external docs"
            },
            "operationId" => "operation-id",
            "parameters" => [
              %{
                "name" => "key",
                "in" => "query",
                "description" => "Some description",
                "required" => true,
                "deprecated" => false,
                "allowEmptyValue" => false
              }
            ],
            "requestBody" => %{
              "description" => "Some description",
              "content" => %{
                "application/json" => %{
                  "schema" => %{
                    "nullable" => true,
                    "discriminator" => %{
                      "propertyName" => "type",
                      "mapping" => %{
                        "dog" => "#/components/schemas/Dog"
                      }
                    },
                    "readOnly" => true,
                    "writeOnly" => true,
                    "xml" => %{
                      "name" => "XML name",
                      "namespace" => "XML namespace",
                      "prefix" => "XML prefix",
                      "attribute" => true,
                      "wrapped" => true
                    },
                    "externalDocs" => %{
                      "url" => "http://external.docs.com",
                      "description" => "I am describing these external docs"
                    },
                    "example" => %{
                      "key" => "value"
                    },
                    "deprecated" => false
                  },
                  "example" => %{
                    "key" => "value"
                  },
                  "examples" => %{
                    "key" => %{
                      "summary" => "Example summary",
                      "description" => "Example description",
                      "value" => %{"some" => "value"},
                      "externalValue" => "https://external.value.com"
                    }
                  }
                }
              }
            }
          }
        }
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
                  ],
                  paths: %{
                    "/" => %V3.PathItem{
                      ref: "http://some.ref.com",
                      summary: "I am summarizing this path",
                      description: "I am describing this path",
                      get: %V3.Operation{
                        tags: ["tag_a", "tag_b"],
                        summary: "I am summarizing this operation",
                        description: "I am describing this operation",
                        external_docs: %V3.ExternalDocumentation{
                          url: "http://external.docs.com",
                          description: "I am describing these external docs"
                        },
                        operation_id: "operation-id",
                        parameters: [
                          %V3.Parameter{
                            name: "key",
                            in: :query,
                            description: "Some description",
                            required: true,
                            deprecated: false,
                            allow_empty_value: false
                          }
                        ],
                        request_body: %V3.RequestBody{
                          description: "Some description",
                          content: %{
                            "application/json" => %V3.MediaType{
                              schema: %V3.Schema{
                                nullable: true,
                                discriminator: %V3.Discriminator{
                                  property_name: "type",
                                  mapping: %{
                                    "dog" => "#/components/schemas/Dog"
                                  }
                                },
                                read_only: true,
                                write_only: true,
                                xml: %V3.XML{
                                  name: "XML name",
                                  namespace: "XML namespace",
                                  prefix: "XML prefix",
                                  attribute: true,
                                  wrapped: true
                                },
                                external_docs: %V3.ExternalDocumentation{
                                  url: "http://external.docs.com",
                                  description: "I am describing these external docs"
                                },
                                example: %{
                                  "key" => "value"
                                },
                                deprecated: false
                              },
                              example: %{
                                "key" => "value"
                              },
                              examples: %{
                                "key" => %V3.Example{
                                  summary: "Example summary",
                                  description: "Example description",
                                  value: %{"some" => "value"},
                                  external_value: "https://external.value.com"
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }}
    end
  end
end
