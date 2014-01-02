require 'head_chef/cli'
require 'aruba/cucumber'
Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

World(HeadChef::RSpec::PathHelpers)

CHEF_SERVER_PORT = 6267

Before do
  clean_tmp_path

  # Set up paths
  Dir.chdir(tmp_path) # ruby dir
  @dirs                 = tmp_path # aruba dir
  ENV['PWD']            = tmp_path.to_s # bash dir
  ENV['BERKSHELF_PATH'] = berkshelf_path.to_s # berkshelf dir

  # Write Berksfile and Berksfile.lock
  FileUtils.cp fixtures_path.join('Berksfiles/default').expand_path, 
    tmp_path.join('Berksfile').expand_path

  # Write .chef/knife.rb
  FileUtils.cp_r fixtures_path.join('dot_chef').expand_path, 
    tmp_path.join('.chef').expand_path

  # Create temp git repo
  `GIT_DIR="#{tmp_path.join('.git').expand_path}" git init --quiet`

  HeadChef::RSpec::ChefServer.start(port: CHEF_SERVER_PORT)

  @aruba_timeout_seconds = 10
end

After do
  HeadChef::RSpec::ChefServer.reset!

  if File.exists?(tmp_path.join('Berksfile.lock').expand_path)
    FileUtils.rm tmp_path.join('Berksfile.lock').expand_path 
  end
end
