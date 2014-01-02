module HeadChef
  class Sync
    def self.sync(environment, force)
      # Check if environment exits, if not create it
      # Perform first, if it fails no need to continue
      unless HeadChef.chef_server.environment.find(environment)
        HeadChef.chef_server.environment.create(name: environment)
      end

      # Diff now performs all Berkshelf/lockfile dependency operations
      HeadChef.ui.say("Determing side effects of sync with chef environment "\
                      "#{environment}...", :cyan)
      cookbook_diff = HeadChef.ui.mute { Diff.diff(environment) }

      unless force
        if cookbook_diff.conflicts?
          HeadChef.ui.error 'The following cookbooks are in conflict:'
          cookbook_diff.conflicts.each do |cookbook|
            HeadChef.ui.error "#{cookbook.name}: #{cookbook.berkshelf_version}"
          end
          HeadChef.ui.error 'Use --force to sync environment'
          Kernel.exit(1337)
        end
      end

      # Retrieve berksfile
      berksfile = HeadChef.berksfile

      HeadChef.ui.say('Uploading cookbooks to chef server...', :cyan)
      berksfile.upload({force: force})

      # Apply without lock options argument
      HeadChef.ui.say("Applying Berksfile.lock cookbook version to " \
                      "environment #{environment}...", :cyan)
      berksfile.apply(environment, {})
    end
  end
end
