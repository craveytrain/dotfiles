require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install do
  linkables = Dir.glob('*/**{.symlink}')
  partials = Dir.glob('*/**{.partial}')

  skip_all = false
  overwrite_all = false
  backup_all = false
  home = ENV["HOME"]

  empty_dirs = [
	  "#{home}/.backup",
	  "#{home}/.undo"
  ]

  # Create symlinks
  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/').last.split('.symlink').last
    target = "#{home}/.#{file}"

    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    `ln -s "$PWD/#{linkable}" "#{target}"`
  end
  
  # Create full files from partials
  partials.each do |partial|
    overwrite = false
    backup = false
    
    filename = partial.split('/').last.split('.partial').last
    target = "#{home}/.#{filename}"
    
    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.get.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        end
      end
      
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{filename}" "$HOME/.#{filename}.backup"` if backup || backup_all
    end
    
    unless skip_all
      puts "Concatting .#{filename}"
      `cp #{partial} #{target}`
    end
    
    privatename = "#{home}/.localrc/#{filename}"
    
    # Concat files
    if File.exists?(privatename)
      `cat #{privatename} >> #{target}`
      
      # privatefile = File.readlines(privatename)
      # File.open(target, 'a') do |f|
      #   f.write("\n" + privatefile)
      # end
    end
  end

  # Create placeholder directories
  empty_dirs.each do |dir|
	  unless File.exists?(dir) and File::directory?(dir)
		  Dir.mkdir(dir)
	  end
  end

end
task :default => 'install'
