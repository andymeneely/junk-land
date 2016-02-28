require 'squib'

desc 'Build black-and-white only'
task default: [:bw]

desc 'Build both bw and color'
task all: [:bw, :color]

desc 'Build black-and-white only'
task :bw do
  puts "=== Building black and white deck ==="
  ENV['pallete'] = 'bw'
  load 'src/deck.rb'
end

desc 'Build the color version only'
task :color do
  puts "=== Building color deck ==="
  ENV['pallete'] = 'color'
  load 'src/deck.rb'
end
