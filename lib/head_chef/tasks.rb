Dir["#{File.dirname(__FILE__)}/tasks/*.rb"].sort.each do |path|
  require_relative "tasks/#{File.basename(path, '.rb')}"
end
