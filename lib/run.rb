require './app/models/git_pull_file_writer.rb'
require './app/models/git_pull_parser.rb'
require './app/models/changed_file.rb'

# app.rb
require "sinatra/activerecord"

passed_in_file_path = ARGV[1]
if passed_in_file_path
  puts "Parsing the output of #{passed_in_file_path}...\n\n"
  file = File.open(passed_in_file_path)
  output = file.read
else
  puts "Pulling from git and writing the output to a file...\n\n"
  file = GitPullFileWriter.new(path_to_project: ARGV[0]).pull
  if !file
    puts "Already up to date."
    exit
  end
  output = File.read(file.path)
  require 'pry'; binding.pry
end
file.close
puts output
parser = GitPullParser.new
parser.parse(output)
puts "\n\nCreating #{parser.changed_files.length} records in the database...\n\n"
parser.save_changed_files!
