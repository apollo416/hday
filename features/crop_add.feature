Feature: Add new crop

Scenario Outline: Adding a new crop to the field
    Given the endpoint artists
    And the request body is
    """
    {
        "name": "<name>",
        "type": "<type>",
        "area": "<area>"
    }
    """
    When the request is sent
    Then the response status code is 201