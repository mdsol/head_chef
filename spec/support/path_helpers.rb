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

      def clean_tmp_path
        FileUtils.rm_rf(tmp_path)
        FileUtils.mkdir_p(tmp_path)
      end
    end
  end
end
