# external requires
require 'berkshelf'
require 'ridley'
require 'grit'
require 'thor'

# internal requires
require_relative 'head_chef/tasks'
require_relative 'head_chef/ui'
require_relative 'head_chef/version'

#@TODO: establish head_chef exit codes
#Create custom errors
module HeadChef
  class << self
    attr_accessor :master_cookbook
    attr_accessor :chef_server
    attr_accessor :ui

    DEFAULT_BERKSFILE_LOCATION = './Berksfile'
    REMOTE_BERKSFILE_DIR = '.head_chef'

    def ui
      @ui ||= Thor::Base.shell.new
    end

    def chef_server
      @chef_server ||= Ridley.from_chef_config()
    end

    def master_cookbook
      begin
        @master_cookbook ||= Grit::Repo.new('.')
      rescue Grit::InvalidGitRepositoryError
        HeadChef.ui.error 'head_chef must be run in root of git repo'
        Kernel.exit(1337)
      end
    end

    def current_branch
      master_cookbook.head.name
    end

    def berksfile(branch)
      if current_branch == branch
        Berkshelf::Berksfile.from_file(DEFAULT_BERKSFILE_LOCATION)
      else
        begin
          berksfile_contents = master_cookbook.git.
            native(:show, {raise: true}, "#{branch}:Berksfile")
        rescue Grit::Git::CommandFailed => e
          HeadChef.ui.error e.message
          Kernel.exit(1337)
        end

        # File writing logic can be resolved by update to Berkshelf::Berksfile
        unless Dir.exists? REMOTE_BERKSFILE_DIR
          Dir.mkdir(REMOTE_BERKSFILE_DIR)
        end

        berksfile = File.open("#{REMOTE_BERKSFILE_DIR}/Berksfile", 'w') do |file|
          file.write(berksfile_contents)
          file
        end

        Berkshelf::Berksfile.from_file(berksfile.path)
      end
    end

    def cleanup
      FileUtils.rm_rf(REMOTE_BERKSFILE_DIR) if Dir.exists? REMOTE_BERKSFILE_DIR
    end
  end
end
