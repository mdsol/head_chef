Feature: head-chef env diff
  Background:
    Given the current git branch is named "test"
    And the Chef Server has an environment named "test"

  Scenario: Diff with same version constraints
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | path: '/Users/mcorwin/projects/head_chef/spec/fixtures/cookbooks/test_cookbook/' |
    And the environment "test" has the following cookbook version constraints:
      | test_cookbook | 0.1.0 |
    When I run `head-chef env diff`
    Then the output should contain "identical"

  Scenario: Diff with a cookbook conflict
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | path: '/Users/mcorwin/projects/head_chef/spec/fixtures/cookbooks/test_cookbook_conflict/' |
    And the Chef Server has the following cookbooks uploaded:
      | test_cookbook | 0.1.0 | /Users/mcorwin/projects/head_chef/spec/fixtures/cookbooks/test_cookbook/ |
    And the environment "test" has the following cookbook version constraints:
      | test_cookbook | 0.1.0 |
    When I run `head-chef env diff`
    Then the output should contain "CONFLICT"

  Scenario: Diff with a cookbook add
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | path: '/Users/mcorwin/projects/head_chef/spec/fixtures/cookbooks/test_cookbook/' |
    And the environment "test" does not have the following cookbook version constraints:
      | test_cookbook | 0.1.0 |
    When I run `head-chef env diff`
    Then the output should contain "ADD"

  Scenario: Diff with a cookbook update
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | path: '/Users/mcorwin/projects/head_chef/spec/fixtures/cookbooks/test_cookbook/' |
    And the environment "test" has the following cookbook version constraints:
      | test_cookbook | 0.0.1 |
    When I run `head-chef env diff`
    Then the output should contain "UPDATE"

  Scenario: Diff with a cookbook remove
    Given the Berksfile does not have the following cookbooks:
      | test_cookbook |
    And the environment "test" has the following cookbook version constraints:
      | test_cookbook | 0.1.0 |
    When I run `head-chef env diff`
    Then the output should contain "REMOVE"

  Scenario: Diff with a cookbook revert
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | path: '/Users/mcorwin/projects/head_chef/spec/fixtures/cookbooks/test_cookbook/' |
    And the environment "test" has the following cookbook version constraints:
      | test_cookbook | 0.2.0 |
    When I run `head-chef env diff`
    Then the output should contain "REVERT"

  Scenario: Diff using environment option with existing environment
    Given the Chef Server has an environment named "environment_option"
    When I run `head-chef env diff -e=environment_option`
    Then the output should contain "Calculating diff"

  Scenario: Diff without existing environment
    Given the Chef Server does not have an environment named "test"
    When I run `head-chef env diff`
    Then the output should contain "not found"
