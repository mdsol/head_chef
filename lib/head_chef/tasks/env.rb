module HeadChef
  class Env < Thor
    class_option :environment,
      aliases: '-e',
      banner: '<environment>',
      desc: 'Applies to the specified environment',
      type: :string

    desc 'diff', 'Shows cookbook diff between Berksfile and Chef <environment>'
    long_desc <<-EOD
      Shows cookbook version diff between Berksfile and Chef <environment>

      By default, matches current git branch name against Chef enviroment.
    EOD
    def diff
      environment = options[:environment] || HeadChef.current_branch

      diff_hash = Diff.diff(environment)
      #@TODO: better way to display results
      # should be method in this class, or to_s for collection
      # of new objects?
      Diff.pretty_print_diff_hash(diff_hash)
    end

    desc 'sync', 'Syncs Berksfile with Chef <environment>'
    long_desc <<-EOD
      Syncs Berksfile cookbook with Chef <environment>

      By default, matches current git branch and against Chef enviroment. Chef
      environment will be created if it does not exist.
    EOD
    option :force, banner: '', desc: 'Force upload of cookbooks to chef server'
    def sync
      environment = options[:environment] || HeadChef.current_branch
      force = options[:force] ? true : false

      Sync.sync(environment, force)
    end
  end
end
