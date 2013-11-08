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

      diff_hash = Diff.diff(branch, environment)
      #@TODO: better way to display results
      # should be method in this class, or to_s for collection
      # of new objects?
      Diff.pretty_print_diff_hash(diff_hash)
    end

    desc 'sync', 'Syncs <branch> with <environment>'
    long_desc <<-EOD
      Syncs <branch> with <environment>.

      By default, uses current branch and matching enviroment
    EOD
    option :force, banner: '', desc: 'Force upload of cookbooks to chef server'
    def sync
      branch = options[:branch] || HeadChef.current_branch
      environment = options[:environment] || branch
      force = options[:force] ? true : false

      Sync.sync(branch, environment, force)
    end
  end
end
