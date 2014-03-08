module HeadChef
  class Diff
    def self.diff(environment)
      HeadChef.ui.info("Loading environment #{environment} from chef server...")
      chef_environment = HeadChef.chef_server.environment.find(environment)

      if chef_environment
        chef_versions = chef_environment.cookbook_versions
      else
        HeadChef.ui.error("Environment #{environment} not found on chef server.")
        Kernel.exit(1337)
      end

      # Run berks install to populate cached cookbook list
      # @NOTE: for now it is up to user to maintain Berksfile
      HeadChef.ui.info('Loading cookbooks from berkshelf...')
      cached_cookbooks = Berkshelf.ui.mute { HeadChef.berksfile.install }

      HeadChef.ui.say('Calculating diff...', :cyan)
      cookbook_diff = CookbookDiff.new

      cached_cookbooks.each do |berkshelf_cookbook|
        cookbook_name = berkshelf_cookbook.name.chomp("-#{berkshelf_cookbook.version}")

        if chef_versions[cookbook_name]
          chef_version = chef_versions[cookbook_name][/[\d\.]+$/]
        else
          chef_version = nil
        end

        cookbook_diff.add(Cookbook.new(cookbook_name, berkshelf_cookbook.version, chef_version))
        chef_versions.delete(cookbook_name)
      end

      chef_versions.each do |cookbook_name, cookbook_version|
        cookbook_diff.add(Cookbook.new(cookbook_name, nil, cookbook_version))
      end

      cookbook_diff
    end
  end
end
