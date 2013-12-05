# external requires
require 'berkshelf'
require 'ridley'
require 'grit'
require 'thor'
require 'semantic'
require 'pathname'

# internal requires
require_relative 'head_chef/tasks'
require_relative 'head_chef/cookbook'
require_relative 'head_chef/cookbook_diff'
require_relative 'head_chef/ui'
require_relative 'head_chef/version'

#@TODO: establish head_chef exit codes
#Create custom errors
module HeadChef

  BERKSFILE_LOCATION = 'Berksfile'.freeze
  BERKSFILE_COOKBOOK_DIR = '.head_chef'.freeze

  class << self
    def root
      @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end

    def ui
      @ui ||= Thor::Base.shell.new
    end

    def chef_server
      @chef_server ||= Ridley.from_chef_config()
    end

    # @TODO: refactor?
    # Is grit necessary to get current branch, is shell command sufficient?
    # This can look up dir's until it finds .git dir
    def master_cookbook
      begin
        @master_cookbook ||= Grit::Repo.new('.')
      rescue Grit::InvalidGitRepositoryError
        puts Dir.pwd
        HeadChef.ui.error 'head_chef must be run in root of git repo'
        Kernel.exit(1337)
      end
    end

    def current_branch
      master_cookbook.head.name
    end

    def berksfile
      @berksfile ||= Berkshelf::Berksfile.from_file(BERKSFILE_LOCATION)
    end

    def cleanup
      if Dir.exists?(BERKSFILE_COOKBOOK_DIR)
        FileUtils.rm_rf(BERKSFILE_COOKBOOK_DIR)
      end
    end
  end
end
