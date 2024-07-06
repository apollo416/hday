Feature: Add new Crop

Scenario: A valid request
    Given the address is: "/crops"
     When the message is sent as a POST message
     Then the response content encoding should be "utf-8"
      And the response status code should be "201"
      And the response should be a json document
      And the response should contain the key "id"
      And the response should contain the key "cultivar"
      And the response should contain the key "cultivar_start"
      And the response should contain the key "cultivar_end"
      And the response should contain the key "created"
      And the response should contain the key "generation"
      And the response should contain the key "maturation_time"
      And the field "id" should be an UUIDv4
      But the field "cultivar" should be empty
      And the field "cultivar_start" should be empty
      And the field "cultivar_end" should be empty
      But the field created should be a timestamp

Scenario: A invalid request
    Given the address is: "/crops"
     When the message is sent as a GET message
     Then the response content encoding should be "utf-8"
      And the response status code should be "405"
