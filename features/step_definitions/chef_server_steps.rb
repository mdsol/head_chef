require 'ridley'
World(HeadChef::RSpec::ChefServer)

Given(/^the Chef Server has an environment named "(.*?)"$/) do |name|
  chef_environment(name, { 'description' => 'This is an environment' })
end

Then(/^the Chef Server should have an environment named "(.*?)"$/) do |name|
  # To avoid error warning, raise_error requires a proc
  lambda { chef_server.data_store.get(['environments', name]) }.should_not raise_error
end

Given(/^the Chef Server does not have an environment named "(.*?)"$/) do |name|
  if chef_server.data_store.exists?(['environments', name])
    chef_server.data_store.delete(['environments', name])
  end
end

Given(/^the environment "(.*?)" has the following cookbook version constraints:$/) do |name, locks|
  cookbook_versions = {}.tap do |h|
    locks.rows_hash.each do |cookbook, version|
      h[cookbook] = version
    end
  end

  chef_environment(name, { 'cookbook_versions' => cookbook_versions })
end

Given(/^the environment "(.*?)" does not have the following cookbook version constraints:$/) do |name, locks|
  list = chef_environment_locks(name)

  if list
    locks.raw.each do |cookbook_name, version|
      if list.key?(cookbook_name) && list[cookbook_name] == version
        list.delete(cookbook_name)
      end
    end

    chef_environment(name, { 'cookbook_versions' => list })
  end
end

Then(/^the environment "(.*?)" should have the following cookbook version constraints:$/) do |name, locks|
  list = chef_environment_locks(name)

  locks.raw.each do |cookbook, version|
    expect(list[cookbook]).to eq(version)
  end
end

Then(/^the environment "(.*?)" should not have the following cookbook version constraints:$/) do |name, locks|
  list = chef_environment_locks(name)

  locks.raw.each do |cookbook, version|
    expect(list[cookbook]).not_to eq(version)
  end
end

Given(/^the Chef Server has the following cookbooks uploaded:$/) do |cookbooks|
  ridley = Ridley.from_chef_config()

  cookbooks.raw.each do |name, version, path|
    ridley.cookbook.upload(path)
  end
end

Given(/^the Chef Server does not have the following cookbooks uploaded:$/) do |cookbooks|
  ridley = Ridley.from_chef_config()

  cookbooks.raw.each do |name, version|
    ridley.cookbook.delete(name, version)
  end
end

Given(/^the Chef Server should have the following cookbooks uploaded:$/) do |cookbooks|
  list = chef_cookbooks

  cookbooks.raw.each do |name, version|
    expect(list[name]).to include(version)
  end
end
