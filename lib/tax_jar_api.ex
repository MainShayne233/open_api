defmodule TaxJarAPI do
  use OpenAPI,
    schema: %{
      "components" => %{
        "securitySchemes" => %{
          "oauth2" => %{
            "flows" => %{
              "implicit" => %{
                "authorizationUrl" => "http://yourauthurl.com",
                "scopes" => %{"scope_name" => "Enter your scopes here"}
              }
            },
            "type" => "oauth2"
          }
        }
      },
      "info" => %{
        "description" => "defaultDescription",
        "title" => "defaultTitle",
        "version" => "0.0.1"
      },
      "openapi" => "3.0.1",
      "paths" => %{
        "/v2/taxes" => %{
          "post" => %{
            "description" => "Auto generated using Swagger Inspector",
            "requestBody" => %{
              "content" => %{
                "application/json" => %{
                  "examples" => %{
                    "0" => %{
                      "value" =>
                        "{\n    \"from_country\": \"US\",\n    \"from_zip\": \"92093\",\n    \"from_state\": \"CA\",\n    \"from_city\": \"La Jolla\",\n    \"from_street\": \"9500 Gilman Drive\",\n    \"to_country\": \"US\",\n    \"to_zip\": \"90002\",\n    \"to_state\": \"CA\",\n    \"to_city\": \"Los Angeles\",\n    \"to_street\": \"1335 E 103rd St\",\n    \"amount\": 15,\n    \"shipping\": 1.5,\n    \"nexus_addresses\": [\n      {\n        \"id\": \"Main Location\",\n        \"country\": \"US\",\n        \"zip\": \"92093\",\n        \"state\": \"CA\",\n        \"city\": \"La Jolla\",\n        \"street\": \"9500 Gilman Drive\"\n      }\n    ],\n    \"line_items\": [\n      {\n        \"id\": \"1\",\n        \"quantity\": 1,\n        \"product_tax_code\": \"20010\",\n        \"unit_price\": 15,\n        \"discount\": 0\n      }\n    ]\n  }"
                    }
                  },
                  "schema" => %{
                    "properties" => %{
                      "amount" => %{"type" => "integer"},
                      "from_city" => %{"type" => "string"},
                      "from_country" => %{"type" => "string"},
                      "from_state" => %{"type" => "string"},
                      "from_street" => %{"type" => "string"},
                      "from_zip" => %{"type" => "string"},
                      "line_items" => %{
                        "items" => %{
                          "properties" => %{
                            "discount" => %{"type" => "integer"},
                            "id" => %{"type" => "string"},
                            "product_tax_code" => %{"type" => "string"},
                            "quantity" => %{"type" => "integer"},
                            "unit_price" => %{"type" => "integer"}
                          },
                          "type" => "object"
                        },
                        "type" => "array"
                      },
                      "nexus_addresses" => %{
                        "items" => %{
                          "properties" => %{
                            "city" => %{"type" => "string"},
                            "country" => %{"type" => "string"},
                            "id" => %{"type" => "string"},
                            "state" => %{"type" => "string"},
                            "street" => %{"type" => "string"},
                            "zip" => %{"type" => "string"}
                          },
                          "type" => "object"
                        },
                        "type" => "array"
                      },
                      "shipping" => %{"type" => "number"},
                      "to_city" => %{"type" => "string"},
                      "to_country" => %{"type" => "string"},
                      "to_state" => %{"type" => "string"},
                      "to_street" => %{"type" => "string"},
                      "to_zip" => %{"type" => "string"}
                    },
                    "type" => "object"
                  }
                }
              }
            },
            "responses" => %{
              "200" => %{
                "content" => %{
                  "application/json" => %{
                    "examples" => %{
                      "0" => %{
                        "value" =>
                          "{\"tax\":{\"order_total_amount\":16.5,\"shipping\":1.5,\"taxable_amount\":15.0,\"amount_to_collect\":1.43,\"rate\":0.095,\"has_nexus\":true,\"freight_taxable\":false,\"tax_source\":\"destination\",\"jurisdictions\":{\"country\":\"US\",\"state\":\"CA\",\"county\":\"LOS ANGELES\",\"city\":\"LOS ANGELES\"},\"breakdown\":{\"taxable_amount\":15.0,\"tax_collectable\":1.43,\"combined_tax_rate\":0.095,\"state_taxable_amount\":15.0,\"state_tax_rate\":0.0625,\"state_tax_collectable\":0.94,\"county_taxable_amount\":15.0,\"county_tax_rate\":0.01,\"county_tax_collectable\":0.15,\"city_taxable_amount\":0.0,\"city_tax_rate\":0.0,\"city_tax_collectable\":0.0,\"special_district_taxable_amount\":15.0,\"special_tax_rate\":0.0225,\"special_district_tax_collectable\":0.34,\"line_items\":[{\"id\":\"1\",\"taxable_amount\":15.0,\"tax_collectable\":1.43,\"combined_tax_rate\":0.095,\"state_taxable_amount\":15.0,\"state_sales_tax_rate\":0.0625,\"state_amount\":0.94,\"county_taxable_amount\":15.0,\"county_tax_rate\":0.01,\"county_amount\":0.15,\"city_taxable_amount\":0.0,\"city_tax_rate\":0.0,\"city_amount\":0.0,\"special_district_taxable_amount\":15.0,\"special_tax_rate\":0.0225,\"special_district_amount\":0.34}]}}}"
                      }
                    },
                    "schema" => %{
                      "properties" => %{
                        "tax" => %{
                          "properties" => %{
                            "amount_to_collect" => %{"type" => "number"},
                            "breakdown" => %{
                              "properties" => %{
                                "city_tax_collectable" => %{"type" => "number"},
                                "city_tax_rate" => %{"type" => "number"},
                                "city_taxable_amount" => %{"type" => "number"},
                                "combined_tax_rate" => %{"type" => "number"},
                                "county_tax_collectable" => %{"type" => "number"},
                                "county_tax_rate" => %{"type" => "number"},
                                "county_taxable_amount" => %{"type" => "number"},
                                "line_items" => %{
                                  "items" => %{
                                    "properties" => %{
                                      "city_amount" => %{"type" => "number"},
                                      "city_tax_rate" => %{"type" => "number"},
                                      "city_taxable_amount" => %{"type" => "number"},
                                      "combined_tax_rate" => %{"type" => "number"},
                                      "county_amount" => %{"type" => "number"},
                                      "county_tax_rate" => %{"type" => "number"},
                                      "county_taxable_amount" => %{
                                        "type" => "number"
                                      },
                                      "id" => %{"type" => "string"},
                                      "special_district_amount" => %{
                                        "type" => "number"
                                      },
                                      "special_district_taxable_amount" => %{
                                        "type" => "number"
                                      },
                                      "special_tax_rate" => %{"type" => "number"},
                                      "state_amount" => %{"type" => "number"},
                                      "state_sales_tax_rate" => %{
                                        "type" => "number"
                                      },
                                      "state_taxable_amount" => %{
                                        "type" => "number"
                                      },
                                      "tax_collectable" => %{"type" => "number"},
                                      "taxable_amount" => %{"type" => "number"}
                                    },
                                    "type" => "object"
                                  },
                                  "type" => "array"
                                },
                                "special_district_tax_collectable" => %{
                                  "type" => "number"
                                },
                                "special_district_taxable_amount" => %{
                                  "type" => "number"
                                },
                                "special_tax_rate" => %{"type" => "number"},
                                "state_tax_collectable" => %{"type" => "number"},
                                "state_tax_rate" => %{"type" => "number"},
                                "state_taxable_amount" => %{"type" => "number"},
                                "tax_collectable" => %{"type" => "number"},
                                "taxable_amount" => %{"type" => "number"}
                              },
                              "type" => "object"
                            },
                            "freight_taxable" => %{"type" => "boolean"},
                            "has_nexus" => %{"type" => "boolean"},
                            "jurisdictions" => %{
                              "properties" => %{
                                "city" => %{"type" => "string"},
                                "country" => %{"type" => "string"},
                                "county" => %{"type" => "string"},
                                "state" => %{"type" => "string"}
                              },
                              "type" => "object"
                            },
                            "order_total_amount" => %{"type" => "number"},
                            "rate" => %{"type" => "number"},
                            "shipping" => %{"type" => "number"},
                            "tax_source" => %{"type" => "string"},
                            "taxable_amount" => %{"type" => "number"}
                          },
                          "type" => "object"
                        }
                      },
                      "type" => "object"
                    }
                  }
                },
                "description" => "Auto generated using Swagger Inspector"
              }
            },
            "servers" => [%{"url" => "https://api.taxjar.com"}]
          },
          "servers" => [%{"url" => "https://api.taxjar.com"}]
        },
        "/v2/transactions/orders" => %{
          "get" => %{
            "description" => "Auto generated using Swagger Inspector",
            "parameters" => [
              %{
                "example" => "2019%2F02%2F01",
                "in" => "query",
                "name" => "to_transaction_date",
                "schema" => %{"type" => "string"}
              },
              %{
                "example" => "2019%2F01%2F01",
                "in" => "query",
                "name" => "from_transaction_date",
                "schema" => %{"type" => "string"}
              }
            ],
            "responses" => %{
              "200" => %{"description" => "Auto generated using Swagger Inspector"}
            },
            "servers" => [%{"url" => "https://api.taxjar.com"}]
          },
          "servers" => [%{"url" => "https://api.taxjar.com"}]
        }
      },
      "servers" => [%{"url" => "https://api.taxjar.com"}]
    }
end
