module HeadChef
  class Sync
    def self.sync(branch, environment)
      # Retrieves berksfile for branch
      berksfile = HeadChef.berksfile(branch)

      # Apply without lock options argument
      berksfile.apply(environment, {})
    end
  end
end
