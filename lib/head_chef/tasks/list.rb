module HeadChef
  class List
    def self.list(environment)
      chef_environment = HeadChef.chef_server.environment.find(environment)

      unless chef_environment
        HeadChef.ui.error "Environment #{environment} not found on chef server."
        Kernel.exit(1337)
      end

      HeadChef.ui.say("COOKBOOKS:")
      chef_environment.cookbook_versions.sort.each do |cookbook, version|
        HeadChef.ui.say("  #{cookbook}: #{version}")
      end
    end
  end
end
