Feature: head-chef env sync
  Background:
    Given the current git branch is named "test"

  Scenario: Sync without existing chef envrionment
    Given the Chef Server does not have an environment named "test"
    And the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | cookbook_path |
    When I run `head-chef env sync`
    Then the Chef Server should have an environment named "test"
    And the environment "test" should have the following cookbook version constraints:
      | test_cookbook | 0.1.0 |

  Scenario: Sync with existing chef environment
    Given the Chef Server has an environment named "test"
    And the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | cookbook_path |
    When I run `head-chef env sync`
    Then the environment "test" should have the following cookbook version constraints:
      | test_cookbook | 0.1.0 |

  Scenario: Sync with existing chef environment overwrites previous environment cookbook verion constraints
    Given the Chef Server has an environment named "test"
    And the environment "test" has the following cookbook version constraints:
      | other_cookbook | 0.1.0 |
    And the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | cookbook_path |
    When I run `head-chef env sync`
    Then the environment "test" should have the following cookbook version constraints:
      | test_cookbook | 0.1.0 |
    Then the environment "test" should not have the following cookbook version constraints:
      | other_cookbook | 0.1.0 |

  Scenario: Sync without cookbook on Chef Server
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | cookbook_path |
    And the Chef Server does not have the following cookbooks uploaded:
      | test_cookbook | 0.1.0 |
    When I run `head-chef env sync`
    Then the Chef Server should have the following cookbooks uploaded:
      | test_cookbook | 0.1.0 |

  Scenario: Sync with cookbook on Chef Server
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | cookbook_path |
    And the Chef Server has the following cookbooks uploaded:
      | test_cookbook | 0.1.0 | cookbook_path |
    When I run `head-chef env sync`
    Then the Chef Server should have the following cookbooks uploaded:
      | test_cookbook | 0.1.0 |

  Scenario: Sync with cookbook conflict without force option
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 | conflict_path |
    And the Chef Server has the following cookbooks uploaded:
      | test_cookbook | 0.1.0 | cookbook_path |
    When I run `head-chef env sync`
    Then the output should contain "conflict"

  Scenario: Sync with cookbook conflict with force option
    Given the Berksfile has the following cookbooks:
      | test_cookbook | 0.1.0 |  cookbook_path|
    And the Chef Server has the following cookbooks uploaded:
      | test_cookbook | 0.1.0 | cookbook_path |
    When I run `head-chef env sync --force`
    Then the Chef Server should have the following cookbooks uploaded:
      | test_cookbook | 0.1.0 |
