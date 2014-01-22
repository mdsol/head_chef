require 'digest'
require 'set'

module HeadChef
  class Cookbook
    #@TODO: add enum for methods

    attr_reader :name
    attr_reader :berkshelf_version # Berkshelf.lock version
    attr_reader :chef_version # Chef server version

    def initialize(name, berkshelf_version, chef_version)
      @name = name
      @berkshelf_version = berkshelf_version
      @chef_version = chef_version
    end

    # Returns true if upload will have no conflicts, false otherwise
    def diff
      # Get file checksums from chef server
      cookbook_resource = HeadChef.chef_server.cookbook.find(@name, @berkshelf_version)
      # Cookbook not present on chef server
      return true unless cookbook_resource

      # Get cookbook from berkshelf cookbook cache
      # NOTE: requires berks install/update to be run to ensure cache is
      # populate from lockfile
      # NOTE: Berkshelf 3.0 can load cookbooks from lockfile without loading
      # cache
      # User manage berksfile? For now, yes
      berkshelf_cookbook = HeadChef.berksfile.cached_cookbooks.find do |cb|
        cb.name == "#{@name}-#{@berkshelf_version}"
      end
      # Cookbook will not be uploaded since it is not in Berksfile.lock
      return true unless berkshelf_cookbook

      cookbook_files_mashes = files_from_manifest(cookbook_resource.manifest)

      # Diff file lists
      cookbook_files = Set.new(cookbook_files_mashes.map(&:path))
      berkshelf_files = Set.new(remove_ignored_files(berkshelf_cookbook.path))

      return false unless berkshelf_files == cookbook_files

      # Diff file contents
      cookbook_files_mashes.each do |cookbook_file_mash|
        berkshelf_cookbook_file = "#{berkshelf_cookbook.path}/#{cookbook_file_mash.path}"
        berkshelf_cookbook_checksum = checksum_file(berkshelf_cookbook_file) if File.exists?(berkshelf_cookbook_file)

        return false unless berkshelf_cookbook_checksum == cookbook_file_mash.checksum
      end

      true
    end

    def to_s
      if @chef_version && @berkshelf_version && (@chef_version != @berkshelf_version)
        "#{@name}: #{@chef_version} => #{@berkshelf_version}"
      else
        "#{@name}: #{@chef_version || @berkshelf_version}"
      end
    end

    private

    def files_from_manifest(manifest)
      manifest.values.flatten
    end

    # Taken from Chef
    def checksum_file(file)
      File.open(file, 'rb') { |f| checksum_io(f, Digest::MD5.new) }
    end

    def checksum_io(io, digest)
      while chunk = io.read(1024 * 8)
        digest.update(chunk)
      end
      digest.hexdigest
    end

    def remove_ignored_files(path)
      file_list = Dir.chdir(path) do
        Dir['**/{*,.*}'].select { |f| File.file?(f) }
      end

      ignore_file = File.join(path, 'chefignore')
      ignore_globs = parse_ignore_file(ignore_file)

      remove_ignores_from(file_list, ignore_globs)
    end

    def remove_ignores_from(file_list, ignore_globs)
      file_list.reject do |file|
        ignored?(file, ignore_globs)
      end
    end

    def ignored?(file_name, ignores)
      ignores.any? { |glob| File.fnmatch?(glob, file_name) }
    end

    def parse_ignore_file(ignore_file)
      [].tap do |ignore_globs|
        if File.exist?(ignore_file) && File.readable?(ignore_file) &&
        (File.file?(ignore_file) || File.symlink?(ignore_file))
          File.foreach(ignore_file) do |line|
            ignore_globs << line.strip unless line =~ /^\s*(?:#.*)?$/
          end
        end
      end
    end

  end
end
