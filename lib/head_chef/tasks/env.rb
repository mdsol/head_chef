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
    long_desc <<-d
      Shows diff between <branch> and <environment>.

      By default, uses current branch and matching enviroment
    d
    def diff
      puts 'Not yet implemented...'
    end

    desc 'sync', 'Syncs <branch> with <environment>'
    long_desc <<-d
      Syncs <branch> with <environment>.

      By default, uses current branch and matching enviroment
    d
    def sync
      branch = options[:branch] || HeadChef.current_branch
      environment = options[:environment] || branch

      Sync.sync(branch, environment)
    end
  end
end
