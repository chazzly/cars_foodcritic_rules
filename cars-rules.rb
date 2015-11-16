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
    # puts "Cars-3 - #{filename} - #{filename.class}"
    support_list = ast.xpath('//command[ident/@value="supports"]') 
    if support_list.empty?
      [	file_match(filename) ]
    end
  end
end

rule 'CARS004', 'Invalid data bag JSON' do
  ## This is stolen entirely from john-karp and his pending pull request
  ## https://github.com/acrmp/foodcritic/pull/270
  require 'json'
  tags %w(correctness files)
  cookbook do |dir|
    Dir[File.join(dir, 'data_bags', '*', '*.json')].reject do |file|
      begin
        contents = File.open(file, 'rb').read
        bag = JSON.parse(contents)
        bag.fetch('id', nil) == File.basename(file, '.json')
      rescue JSON::ParserError
        false
      end
    end.map { |file| file_match(file) }
  end
end

rule 'CARS005', 'Metadata depends does specify version constraint' do
  tags %w{metadata}
  v_missing = false
  cookbook do |cb|
    metapath = File.join(cb, 'metadata.rb')
    f=open(metapath)
    while mline=f.gets
      if mline.include?('depends')
        deps = mline.split
        if deps.length != 3
          v_missing = true
          lnno = $.
        end
      end
    end
    if v_missing
      [ {:filename=>metapath, :matched=>metapath, :line=>lnno, :column=>1 } ]
    end
  end
end

rule 'CARS006', 'Valid Cookbook version is not defined' do
  tags %w{metadata}
  cookbook do |cb|
    v_missing = true
    pass = true
    noln = 0
    metafile = File.join(cb, 'metadata.rb')
    f=open(metafile)
    while mline=f.gets
      if mline.include?('version')
        lnno = $.
        vers = mline.split
        if vers.length > 1
          parts = vers[1].gsub(/\s|'|"/, '').split('.')
          if parts.length > 1
            parts.each do |p|
              if !/\A\d+\z/.match(p)
                pass = false
              end
            end
            if pass
              v_missing = false
            end
          end
        end
      end
    end
    if v_missing
      [ {:filename=>metafile, :matched=>metafile, :line=>lnno, :column=>1 } ]
    end
  end
end

rule 'CARS007', 'File mode not specified as a string.' do
  tags %w{recipe, correctness,files}
  recipe do |recp|
    pres = find_resources(recp, :type => 'remote_file').find_all do |cmd|
      condition = Nokogiri::XML(cmd.to_xml).xpath('//ident[@value="only_if" or @value="not_if"][parent::fcall or parent::command or ancestor::if]')
      condition.empty?
    end.map{|cmd| match(cmd)}
  end
     
end

