require 'head_chef'

module HeadChef
  class Cli < Thor

    # This is the main entry point for CLI.
    # It wraps the Thor start command to provide error handling.
    class << self
      def start(given_args=ARGV, config={})
        begin
          super
          HeadChef.cleanup
        rescue Berkshelf::BerkshelfError => e
          HeadChef.ui.error e
          Kernel.exit(e.status_code)
        rescue Net::HTTP::Persistent::Error => e
          HeadChef.ui.error e
          Kernel.exit(1337)
        rescue Ridley::Errors::HTTPError => e
          HeadChef.ui.error "#{e.class}: #{e} \nEndpoint: #{e.env[:url]}"
          Kernel.exit(1337)
        end
      end
    end

    namespace 'head_chef'

    desc "env", "Sync and diff branches with Chef enviroments"
    subcommand "env", Env
  end
end
