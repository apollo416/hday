Feature: Add new Crop

Scenario: A valid request
    Given the address is: "/crops"
     When the message is sent as a POST message
     Then the response content encoding should be "utf-8"
      And the response status code should be "Created"
      And the response should be a json document
      And the response should be a valid "Crop" resource
      And the crop should be present on the server

Scenario: A invalid request
    Given the address is: "/crops"
     When the message is sent as a GET message
     Then the response content encoding should be "utf-8"
      And the response status code should be "Method Not Allowed"
