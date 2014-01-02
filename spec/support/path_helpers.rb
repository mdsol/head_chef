module HeadChef
  module RSpec
    module PathHelpers
      def tmp_path
        HeadChef.root.join('tmp')
      end

      def fixtures_path
        HeadChef.root.join('spec/fixtures')
      end

      def berkshelf_path
        tmp_path.join('.berkshelf').expand_path
      end

      def cookbook_store
        fixtures_path.join('cookbooks').expand_path
      end

      def cookbook_path(cookbook_name)
        "#{cookbook_store}/#{cookbook_name}"
      end

      def file_content_conflict_path(cookbook_name)
        "#{cookbook_path(cookbook_name)}_file_content_conflict"
      end

      def file_list_conflict_path(cookbook_name)
        "#{cookbook_path(cookbook_name)}_file_list_conflict"
      end

      def clean_tmp_path
        FileUtils.rm_rf(tmp_path)
        FileUtils.mkdir_p(tmp_path)
      end
    end
  end
end
