module HeadChef
  class Env < Thor
    class_option :environment,
      aliases: '-e',
      banner: '<environment>',
      desc: 'Applies to the specified environment',
      type: :string

    class_option :branch,
      aliases: '-b',
      banner: '<branch>',
      desc: 'Uses the specified branch',
      type: :string

    desc 'diff', 'Shows diff between <branch> and <environment>'
    long_desc <<-EOD
      Shows diff between <branch> and <environment>.

      By default, uses current branch and matching enviroment
    EOD
    def diff
      branch = options[:branch] || HeadChef.current_branch
      environment = options[:environment] || branch

      Diff.diff(branch, environment)
    end

    desc 'sync', 'Syncs <branch> with <environment>'
    long_desc <<-EOD
      Syncs <branch> with <environment>.

      By default, uses current branch and matching enviroment
    EOD
    def sync
      branch = options[:branch] || HeadChef.current_branch
      environment = options[:environment] || branch

      Sync.sync(branch, environment)
    end
  end
end
