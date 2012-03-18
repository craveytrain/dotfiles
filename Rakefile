require 'rake'

# Set up some defaults
skip_all = false
overwrite_all = false
backup_all = false
home = ENV["HOME"]
dotfiles = File.dirname(__FILE__)

desc "Symlink up the files"
task :linkify do
  linkables = Dir.glob('*/**{.symlink}')
  
  # Create symlinks
  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = File.basename(linkable,'.symlink')
    target = File.join(home, ".#{file}")

    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip rest, [o]verwrite, [O]verwrite rest, [b]ackup, [B]ackup rest"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        end
      end

      FileUtils.rm_rf(target) if overwrite || overwrite_all
      mv(target, File.join(home, "#{file}.backup")) if backup || backup_all
    end
    
    symlink(File.join(dotfiles, linkable), target) unless skip_all
  end
end

desc "Create empty placeholder dirs"
task :placehold do

  empty_dirs = [
	  "#{home}/.backup",
	  "#{home}/.undo"
  ]
  
  # Create placeholder directories
  empty_dirs.each do |dir|
	  unless File.exists?(dir) and File::directory?(dir)
		  Dir.mkdir(dir)
	  end
  end
end

desc "Copy partials to the correct dir"
task :tokenize do
  partials = Dir.glob('*/**{.partial}')
  
  # Create full files from partials
  partials.each do |partial|
    overwrite = false
    backup = false
    
    file = File.basename(partial,'.partial')
    target = File.join(home, ".#{file}")
    
    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip rest, [o]verwrite, [O]verwrite rest, [b]ackup, [B]ackup rest"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        end
      end
      
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      mv(target, File.join(home, "#{file}.backup")) if backup || backup_all
    end
    
    unless skip_all
      cp(File.join(dotfiles, partial), target)
      
      privatename = File.join(home, '.localrc', file)
      
      # Concat files
      if File.exists?(privatename)
        puts "Appending #{privatename}"
        `cat #{privatename} >> #{target}`
      end
    end
    
  end
end

desc "Hook our dotfiles into system-standard positions."
task :install => [:linkify, :tokenize, :placehold] do
end

task :default => 'install'
