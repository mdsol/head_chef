require 'digest'

module HeadChef
  class Cookbook #extend Ridley::Chef::Cookbook?
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
      unless cookbook_resource
        # Cookbook not present on chef server
        return true
      end

      # Get cookbook from berkshelf cookbook cache
      # NOTE: requires berks install/update to be run to ensure cache is
      # populate from lockfile
      # NOTE: Berkshelf 3.0 can load cookbooks from lockfile without loading
      # cache
      # User manage berksfile? For now, yes
      berkshelf_cookbook = HeadChef.berksfile.cached_cookbooks.find do |cb|
        cb.name == "#{@name}-#{@berkshelf_version}"
      end
      unless berkshelf_cookbook
        # Cookbook will not be uploading since it is not in
        # Berksfile.lock
        return true
      end

      berkshelf_cookbook_path = berkshelf_cookbook.path

      # Diff files
      cookbook_files_mashes = files_from_manifest(cookbook_resource.manifest)
      cookbook_files_mashes.each do |cookbook_file_mash|

        berkshelf_cookbook_file = "#{berkshelf_cookbook_path}/#{cookbook_file_mash.path}"
        berkshelf_cookbook_checksum = checksum_file(berkshelf_cookbook_file) if File.exists?(berkshelf_cookbook_file)

        unless berkshelf_cookbook_checksum == cookbook_file_mash.checksum
          # Conflict present in cookbooks
          return false
        end
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

    def checksum_file(file)
      File.open(file, 'rb') { |f| checksum_io(f, Digest::MD5.new) }
    end

    def checksum_io(io, digest)
      while chunk = io.read(1024 * 8)
        digest.update(chunk)
      end
      digest.hexdigest
    end

    def files_from_manifest(manifest)
      file_mashes = []

      manifest.each do |folder, mashes|
        mashes.each do |mash|
          file_mashes << mash
        end
      end

      file_mashes
    end
  end
end
