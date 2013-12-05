Given(/^the current git branch is named "(.*?)"$/) do |name|
  system "git checkout -b #{name} --quiet"
end
