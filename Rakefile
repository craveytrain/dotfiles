require 'rake'

# Set up some defaults
$skip_all = false
$overwrite_all = false
$backup_all = false
$home = ENV["HOME"]
$dotfiles = File.dirname(__FILE__)

def check_for_file(target)
  base      = File.basename(target).sub(/^\./,'')
  overwrite = false
  backup    = false

  if File.exists?(target) || File.symlink?(target)
    unless $skip_all || $overwrite_all || $backup_all
      puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip rest, [o]verwrite, [O]verwrite rest, [b]ackup, [B]ackup rest"
      case STDIN.gets.chomp
      when 'o' then overwrite = true
      when 'b' then backup = true
      when 'O' then $overwrite_all = true
      when 'B' then $backup_all = true
      when 'S' then $skip_all = true
      end
    end

    FileUtils.rm_rf(target) if overwrite || $overwrite_all
    mv(target, File.join($home, ".#{base}.backup")) if backup || $backup_all
  end
end


desc "Symlink up the files"
task :linkify do
  linkables = Dir.glob('*/**{.symlink}')

  # Create symlinks
  linkables.each do |linkable|
    file      = File.basename linkable,'.symlink'
    target    = File.join $home, ".#{file}"
    
    if File.symlink?(target)
      if File.readlink(target) != File.join($dotfiles, linkable)
        check_for_file(target)
        symlink(File.join($dotfiles, linkable), target) unless $skip_all
      end
    else
      check_for_file(target)
      symlink(File.join($dotfiles, linkable), target) unless $skip_all 
    end
  end
end

desc "Copy partials to the correct dir"
task :tokenize do
  partials = Dir.glob('*/**{.partial}')

  # Create full files from partials
  partials.each do |partial|
    file   = File.basename partial,'.partial'
    target = File.join $home, ".#{file}"

    check_for_file(target)

    unless $skip_all
      cp(File.join($dotfiles, partial), target)

      privatename = File.join($home, '.localrc', file)

      # Concat files
      if File.exists?(privatename)
        puts "Appending #{privatename}"
        `cat #{privatename} >> #{target}`
      end
    end
  end
end

desc "Copy directories and symlink contents"
task :copy do
  copyables = Dir.glob('*/**{.copy}')

  copyables.each do |copyable|
    dir        = File.basename copyable, '.copy'
    target_dir = File.join $home, ".#{dir}"

    Dir.mkdir(target_dir) unless File.directory?(target_dir)

    Dir[File.join(copyable, '**')].each do |file|
      base        = File.basename file
      target_file = File.join target_dir, base
      full_file = File.join $dotfiles, file

      unless File.symlink?(target_file) && (File.readlink(target_file) == full_file)
        check_for_file(target_file)
        symlink(full_file, target_file) unless $skip_all
      end
    end
  end
end

desc "Create empty placeholder dirs"
task :placehold do

  empty_dirs = [
	  "#{$home}/.backup",
	  "#{$home}/.undo"
  ]

  # Create placeholder directories
  empty_dirs.each do |dir|
	  unless File.exists?(dir) and File::directory?(dir)
		  Dir.mkdir(dir)
	  end
  end
end

desc "Hook our dotfiles into system-standard positions."
task :install => [:copy, :linkify, :tokenize, :placehold]

task :default => 'install'
