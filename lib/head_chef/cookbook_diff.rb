module HeadChef
  class CookbookDiff
    attr_reader :diff_hash

    def initialize
      @diff_hash = { add: [],
                     update: [],
                     remove: [],
                     revert: [],
                     conflict: [] }
    end

    # @TODO: cleanup
    # @TODO: switch statements
    def add(cookbook)
      # Removal is the only operation that does not require a diff, as no
      # cookbook will be uploaded
      if cookbook.chef_version && !cookbook.berkshelf_version
        @diff_hash[:remove] << cookbook and return
      end

      unless cookbook.diff
        @diff_hash[:conflict] << cookbook and return
      end

      if cookbook.berkshelf_version && !cookbook.chef_version
        @diff_hash[:add] << cookbook and return
      end

      berkshelf_version = Semantic::Version.new(cookbook.berkshelf_version)
      chef_version = Semantic::Version.new(cookbook.chef_version)

      if berkshelf_version > chef_version
        @diff_hash[:update] << cookbook and return
      elsif berkshelf_version < chef_version
        @diff_hash[:revert] << cookbook and return
      end
    end

    def conflicts
      @diff_hash[:conflict]
    end

    def conflicts?
      !@diff_hash[:conflict].empty?
    end

    def pretty_print
      colors = { add: :green,
                 update: :green,
                 remove: :red,
                 revert: :red,
                 conflict: :red }

      [:add, :update, :remove, :revert, :conflict].each do |method|
        color = colors[method]

        unless @diff_hash[method].empty?
          HeadChef.ui.say("#{method.to_s.upcase}:", color)
          diff_hash[method].each do |cookbook|
            HeadChef.ui.say("  #{cookbook.to_s}", color)
          end
        end
      end
    end
  end
end
