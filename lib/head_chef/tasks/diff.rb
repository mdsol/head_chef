require 'digest/md5'
require 'pathname'

module HeadChef
  class Diff
    @diff_hash = { add: [],
                   update: [],
                   remove: [],
                   revert: [],
                   conflict: [] }

    class << self
      attr_accessor :diff_hash
    end

    def self.diff(environment)
      HeadChef.ui.say("Loading environment #{environment} from chef server...",
                     :cyan)
      chef_environment = HeadChef.chef_server.environment.find(environment)

      if chef_environment
        chef_versions = chef_environment.cookbook_versions
      else
        HeadChef.ui.error("Environment #{environment} not found on chef server.")
        Kernel.exit(1337)
      end

      # Loads Berksfile into memory
      berksfile = HeadChef.berksfile

      # Rebuild Berksfile.lock to ensure latest cookbooks/dependencies
      lockfile = berksfile.lockfile

      HeadChef.ui.say('Building Berksfile.lock...', :cyan)

      if File.exists?(lockfile.filepath)
        File.delete(lockfile.filepath)

        # Reinitialize berksfile/lockfile since old lockfile was present
        berksfile = HeadChef.berksfile
        lockfile = berksfile.lockfile
      end

      Berkshelf.ui.mute { berksfile.install }

      HeadChef.ui.say('Calculating diff...', :cyan)

      # Retrieve dependencies from lockfile
      lockfile_versions = lockfile.to_hash[:sources]

      # Iterate through Berkshelf::Dependency hash
      lockfile_versions.each do |cookbook_name, cookbook_source|

        lockfile_version = Semantic::Version.new(cookbook_source.locked_version.to_s)

        # If cookbook version exists on chef server,check it against lockfile
        # version
        if chef_versions[cookbook_name]
          chef_version = Semantic::Version.new(chef_versions[cookbook_name])

          if lockfile_version > chef_version
            diff_hash[:update] << { cookbook_name: cookbook_name,
                                    old_version: chef_version,
                                    new_version: lockfile_version }
          elsif lockfile_version < chef_version
            diff_hash[:revert] << { cookbook_name: cookbook_name,
                                    old_version: chef_version,
                                    new_version: lockfile_version }
          elsif lockfile_version == chef_version
            cookbook_hash = self.content_diff(cookbook_name, chef_version, lockfile)
            diff_hash[:conflict] << cookbook_hash if cookbook_hash
          end

          chef_versions.delete(cookbook_name)
        else
          # Cookbook does not exists on chef server, and therefore will be added
          # to environment
          diff_hash[:add] << { cookbook_name: cookbook_name,
                               version: lockfile_version }
        end
      end

      # Cookbooks in chef environment not in lockfile will be removed from 
      # environment
      chef_versions.each do |cookbook_name, cookbook_version|
        diff_hash[:remove] << { cookbook_name: cookbook_name,
                                version: cookbook_version }
      end

      diff_hash
    end

    def self.content_diff(cookbook_name, cookbook_version, lockfile)
      # Retrieve cookbook from chef server
      chef_cookbook = HeadChef.chef_server.cookbook.find(cookbook_name, cookbook_version)

      # If cookbook exists on chef server, download it
      # Else cookbook is present in lockfile, and will be added to environment
      if chef_cookbook
        chef_cookbook.download(".head_chef/#{cookbook_name}")
      else
        diff_hash[:add] << { cookbook_name: cookbook_name, version: cookbook_version }
        return nil
      end

      # Calculate checksums to verify if contents are the same
      # Process involves comparing each file in cookbook from chef server exists
      # and has the same content as cookbook in berkshelf store
      #
      # @TODO:
      #   consider chef ignore files?
      #   use head_chef cookbook cache?
      #   ignore lock files?

      # Get paths of cookbooks
      chef_cookbook_path = ".head_chef/#{cookbook_name}"

      berkshelf_cookbook_hash = lockfile.find(cookbook_name).to_hash
      berkshelf_cookbook_path = "#{Berkshelf.berkshelf_path}/cookbooks/#{cookbook_name}-#{berkshelf_cookbook_hash[:ref] || berkshelf_cookbook_hash[:locked_version]}"

      # Get all files in chef server cookbook
      cookbook_files = Dir["#{chef_cookbook_path}/**/*"].reject { |fn| File.directory?(fn) }

      # Diff contents of chef server against contents in berkshelf
      cookbook_files.each do |cookbook_file|
        common_cookbook_file = Pathname.new(cookbook_file).relative_path_from(Pathname.new(chef_cookbook_path))

        chef_cookbook_file = "#{chef_cookbook_path}/#{common_cookbook_file}"
        berkshelf_cookbook_file = "#{berkshelf_cookbook_path}/#{common_cookbook_file}"

        chef_cookbook_checksum = Digest::MD5.digest(File.read(chef_cookbook_file))
        berkshelf_cookbook_checksum = Digest::MD5.digest(File.read(berkshelf_cookbook_file)) if File.exists?(berkshelf_cookbook_file)

        # If file contents differ, inform user of the conflict]
        unless chef_cookbook_checksum == berkshelf_cookbook_checksum
          return { cookbook_name: cookbook_name, version: cookbook_version }
        end
      end

      nil
    end

    # @TODO: CLEANUP!... This is gross
    # Can be refactored by introducting cookbook class
    def self.pretty_print_diff_hash(diff_hash)
      # Print hash in order of Add, Update, Remove, Revert, Conflict
      HeadChef.ui.say("ADD:", :green) unless diff_hash[:add].empty?
      diff_hash[:add].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:version]}", :green)
      end

      HeadChef.ui.say("UPDATE:", :green) unless diff_hash[:update].empty?
      diff_hash[:update].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:old_version]} => #{h[:new_version]}", :green)
      end

      HeadChef.ui.say("REMOVE:", :red) unless diff_hash[:remove].empty?
      diff_hash[:remove].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:version]}", :red)
      end

      HeadChef.ui.say("REVERT:", :red) unless diff_hash[:revert].empty?
      diff_hash[:revert].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:old_version]} => #{h[:new_version]}", :red)
      end

      HeadChef.ui.say("CONFLICT:", :red) unless diff_hash[:conflict].empty?
      diff_hash[:conflict].each do |h|
        HeadChef.ui.say("\t#{h[:cookbook_name]}: #{h[:version]}", :red)
      end
    end
  end
end
