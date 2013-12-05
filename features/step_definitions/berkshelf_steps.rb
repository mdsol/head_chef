require 'erubis'

Given(/^the Berksfile has the following cookbooks:$/) do |cookbooks|
  berksfile_template = Erubis::Eruby.new(File.read('../spec/fixtures/Berksfiles/template.erb'))
  context = {
    cookbooks: cookbooks.raw
  }

  File.open('Berksfile', 'w') do |file|
    file.write(berksfile_template.evaluate(context))
  end
end


Given(/^the Berksfile does not have the following cookbooks:$/) do |cookbooks|
  tmp = Tempfile.new('Berksfile.tmp')

  File.open('Berksfile', 'r').each do |line|
    writeable = true

    cookbooks.raw.each do |name|
      writeable = false if (line =~ /#{name.first}/)
    end

    tmp.write(line) if writeable
  end

  tmp.close
  FileUtils.mv(tmp.path, 'Berksfile')
  tmp.unlink
end
