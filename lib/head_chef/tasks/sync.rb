module HeadChef
  class Sync
    def self.sync(branch, environment, force)
      # Check if environment exits, if not create it
      # Perform first, if it fails no need to continue
      unless HeadChef.chef_server.environment.find(environment)
        HeadChef.chef_server.environment.create(name: environment)
      end

      # Diff now performs all Berkshelf/lockfile dependency operations
      HeadChef.ui.say("Determing side effects of sync with chef environment "\
                      "#{environment}...", :cyan)
      diff_hash = HeadChef.ui.mute { Diff.diff(branch, environment) }

      unless force
        unless diff_hash[:conflict].empty?
          HeadChef.ui.error 'The following cookbooks are in conflict:'
          diff_hash[:conflict].each do |cookbook_hash|
            HeadChef.ui.error "#{cookbook_hash[:cookbook_name]}: #{cookbook_hash[:version]}"
          end
          HeadChef.ui.error 'Use --force to sync environment'
          Kernel.exit(1337)
        end
      end

      # Retrieve berksfile
      berksfile = HeadChef.berksfile(branch)

      # Upload cookbooks before applying environment
      # @TODO:
      # pass in cookbook diff, only cookbook bumps/rewrites, no removals
      # force upload only on conflict cookbooks, otherwise just upload
      HeadChef.ui.say('Uploading cookbooks to chef server...', :cyan)
      berksfile.upload({force: force})

      # Apply without lock options argument
      HeadChef.ui.say("Applying Berksfile.lock cookbook version to " \
                      "environment #{environment}...", :cyan)
      berksfile.apply(environment, {})
    end
  end
end
