module HeadChef
  class Diff
    def self.diff(branch, environment)
      # Retrieve dependencies from chef server first,
      # as if environment does not exist ,we can exit
      HeadChef.ui.say("Loading environment #{environment} from chef server...",
                     :cyan)
      chef_environment = HeadChef.chef_server.environment.find(environment)

      if chef_environment
        chef_versions = chef_environment.cookbook_versions
      else
        #@TODO: implement HeadChef errors w/ codes
        HeadChef.ui.error "Environment #{environment} not found on chef server."
        exit(1337)
      end
      # Retrieves berksfile for branch
      berksfile = HeadChef.berksfile(branch)

      # Ensure lockfile is built
      HeadChef.ui.say('Updating Berksfile.lock...', :cyan)
      Berkshelf.ui.mute { berksfile.update }

      HeadChef.ui.say('Calculating diff...', :cyan)

      # Retrieve dependencies from lockfile
      lockfile_versions = berksfile.lockfile.to_hash[:sources]

      # Iterate through Berkshelf::Dependency hash
      diff = {add: [],
              update: [],
              remove: [],
              revert: []}

      lockfile_versions.each do |cookbook_name, cookbook_source|
        lockfile_version = cookbook_source.locked_version.to_s
        chef_version = chef_versions[cookbook_name]

        if chef_version
          if lockfile_version > chef_version
            diff[:update] << { cookbook_name: cookbook_name,
                              old_version: chef_version,
                              new_version: lockfile_version }
          elsif lockfile_version < chef_version
            diff[:revert] << { cookbook_name: cookbook_name,
                              old_version: chef_version,
                              new_version: lockfile_version }
          end

          chef_versions.delete(cookbook_name)
        else
          diff[:add] << { cookbook_name: cookbook_name,
                         version: lockfile_version }
        end
      end

      chef_versions.each do |cookbook_name, cookbook_version|
        diff[:remove] << { cookbook_name: cookbook_name,
                          version: cookbook_version }
      end

      self.pretty_print_diff_hash(diff)
    end

    private

    # @TODO: CLEANUP!... This is gross
    def self.pretty_print_diff_hash(diff_hash)
      # Print hash in order of Add, Update, Remove, Revert
      HeadChef.ui.say("ADD:", :green) unless diff_hash[:add].empty?
      diff_hash[:add].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:version]}", :green)
      end

      HeadChef.ui.say("UPDATE:", :green) unless diff_hash[:update].empty?
      diff_hash[:update].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:old_version]} => #{h[:new_version]}", :green)
      end

      HeadChef.ui.say("REMOVE:", :red) unless diff_hash[:remove].empty?
      diff_hash[:remove].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:version]}", :red)
      end

      HeadChef.ui.say("REVERT:", :red) unless diff_hash[:revert].empty?
      diff_hash[:revert].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:old_version]} => #{h[:new_version]}", :red)
      end

    end
  end
end
