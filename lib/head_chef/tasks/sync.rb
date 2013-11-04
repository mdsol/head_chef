module HeadChef
  class Sync
    def self.sync(branch, environment)
      # Check if environment exits, if not create it
      # Perform first, if it fails no need to continue
      unless HeadChef.chef_server.environment.find(environment)
        HeadChef.chef_server.environment.create(name: environment)
      end

      # Retrieves berksfile for branch
      berksfile = HeadChef.berksfile(branch)

      # Berksfile#update to ensure Berksfile.lock has latest cookbook
      # dependencies
      HeadChef.ui.say('Updating Berksfile.lock...', :cyan)
      Berkshelf.ui.mute { berksfile.update() }

      # Upload cookbooks before applying environment
      HeadChef.ui.say('Uploading cookbooks to chef server...', :cyan)
      berksfile.upload()

      # Apply without lock options argument
      HeadChef.ui.say("Applying Berksfile.lock cookbook version to " \
                      "environment #{environment}...", :cyan)
      berksfile.apply(environment, {})
    end
  end
end
