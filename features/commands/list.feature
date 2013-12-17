Feature: head-chef env list
  Background:
    Given the current git branch is named "test"

  Scenario: Listing cookbook and version constraints for existing Chef environment
    Given the Chef Server has an environment named "test"
    And the environment "test" has the following cookbook version constraints:
      | cookbook | 0.0.1 |
    When I run `head-chef env list`
    Then the output should contain "cookbook: 0.0.1"

  Scenario: Listing cookbook and version constraints for non-existent Chef environment
    Given the Chef Server does not have an environment named "test"
    When I run `head-chef env list`
    Then the output should contain "not found"

  Scenario: Calling list command with environment option
    Given the Chef Server has an environment named "other_branch"
    When I run `head-chef env list --environment=other_branch`
    Then the output should contain "COOKBOOKS:"
