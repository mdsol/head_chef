require 'erubis'

Given(/^the Berksfile has the following cookbooks:$/) do |cookbooks|
  berksfile_template = Erubis::Eruby.new(File.read('../spec/fixtures/Berksfiles/template.erb'))


  berkshelf_entries = cookbooks.raw.map do |cookbook|
    cookbook_path = self.send(cookbook[2].to_sym, cookbook[0])

    cookbook[2] = "path: '#{cookbook_path}'"
    cookbook
  end

  context = {
    cookbooks: berkshelf_entries
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
