module HeadChef
  class Sync
    def self.sync(branch, environment)
      # Retrieves berksfile for branch
      berksfile = HeadChef.berksfile(branch)

      # Berksfile#update to ensure Berksfile.lock has latest cookbook
      # dependencies
      HeadChef.ui.say('Updating Berksfile.lock...', :cyan)
      Berkshelf.ui.mute { berksfile.update() }

      # Check if environment exits, if not create it
      unless HeadChef.chef_server.environment.find(chef_environment_name)
        HeadChef.chef_server.environment.create(name: chef_environment_name)
      end

      # Upload cookbooks before applying environment
      HeadChef.ui.say('Uploading cookbooks to chef server...', :cyan)
      berksfile.upload()

      # Apply without lock options argument
      HeadChef.ui.say("Applying Berksfile.lock cookbook version to " \
                      "environment #{environment}...", :cyan)
      berksfile.apply(chef_environment_name, {})
    end
  end
end
