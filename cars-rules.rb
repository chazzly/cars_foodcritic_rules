rule "CARS001", "Remote file resource called without sanity check (not_if, or only_if)" do
  tags %w{recipe}
  recipe do |recp|
    pres = find_resources(recp, :type => 'remote_file').find_all do |cmd|
      condition = Nokogiri::XML(cmd.to_xml).xpath('//ident[@value="only_if" or @value="not_if"][parent::fcall or parent::command or ancestor::if]')
      condition.empty?
    end.map{|cmd| match(cmd)}
  end
end

rule 'CARS002', 'Missing CHANGELOG entry for current version' do
  tags %w{style changelog}
  v_found = false
  cb_ver = 'x'
  cookbook do |cb|
    metapath = File.join(cb, 'metadata.rb')
    filepath = File.join(cb, 'CHANGELOG.md')
    #puts "cars-2 - #{filepath} - #{filepath.class}"
    m = File.readlines(metapath)
    m.collect do |mline|
      if mline.include?('version')
        cb_ver = mline.split[1].gsub(/['"]/,'')
      end
    end
    unless cb_ver == 'x'
      f = File.readlines(filepath)
      f.collect do |line|
        v_found = true if line.include?(cb_ver)
      end
    end
    unless v_found
      [ file_match(filepath) ] 
    end
  end
end

rule 'CARS003', 'OS Support not specified.' do
  tags %w{metadata os}
  metadata do |ast, filename|
    #puts "Cars-3 - #{filename} - #{filename.class}"
    support_list = ast.xpath('//command[ident/@value="supports"]') 
    if support_list.empty?
      [	file_match(filename) ]
    end
  end
end
