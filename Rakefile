require 'squib'

desc 'Build black-and-white only'
task default: [:bw]

desc 'Build both bw and color'
task all: [:bw, :color]

desc 'Build black-and-white only'
task :bw do
  puts "=== Building black and white deck ==="
  ENV['SQUIB_BUILD_GROUPS'] = 'bw'
  load 'src/deck.rb'
end

desc 'Build the color version only'
task :color do
  puts "=== Building color deck ==="
  ENV['SQUIB_BUILD_GROUPS'] = 'color'
  load 'src/deck.rb'
end

desc 'Post to dropbox'
task :dropbox do
  puts "=== Uploading to Dropbox ==="
  load 'src/upload_dropbox.rb'
end

desc 'Travis build'
task :travis => [:all, :dropbox]
