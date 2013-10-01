require 'head_chef'
require 'thor'

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

    class_option :all,
      banner: '',
      desc: 'Applies each branch to matching environment'

    desc 'diff', 'Shows diff between <branch> and <environment>'
    long_desc <<-d
      Shows diff between <branch> and <environment>.

      By default, uses current branch and matching enviroment
    d
    def diff
      #@TODO
    end

    desc 'sync', 'Syncs <branch> with <environment>'
    long_desc <<-d
      Syncs <branch> with <environment>.

      By default, uses current branch and matching enviroment
    d
    def sync
      #@TODO
    end
  end

  class CLI < Thor
    desc "env", "Sync and diff branches with Chef enviroments"
    subcommand "env", Env
  end

end
