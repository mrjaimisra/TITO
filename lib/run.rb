require './app/models/git_pull_file_writer.rb'
require './app/models/git_pull_parser.rb'
require './app/models/changed_file.rb'
require 'sinatra/activerecord'

puts "Pulling from git and writing the output to a file...\n\n"
file = GitPullFileWriter.new(path_to_project: ARGV[0]).pull
if !file
  puts "Already up to date."
  exit
end
output = File.open(file.path).read
file.close
puts output
parser = GitPullParser.new
parser.parse(output)
puts parser.save_changed_files!
