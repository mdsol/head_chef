require 'head_chef'
require 'hashie'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.color_enabled = true
  config.formatter = :documentation

  #config.order = 'random'
end

HeadChef.ui.mute!
