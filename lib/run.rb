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
    puts "Already up to date.\n\n"
    exit
  end
  puts "File path: #{file.path}"
  file.rewind
end

output = file.read
puts "\nGitPullFileWriter output:\n\n#{output}"

parser = GitPullParser.new
parser.parse_from_file(file.path)
file.close

exit if !parser.files_changed?

puts "\nCreating #{parser.changed_files.length} records in the database...\n\n"

if parser.save_changed_files!
  puts "\nRecords created successfully.\n\n"
else
  puts "\nThere was an error saving the records: #{parser.errors.full_messages.join(", ")}.\n\n"
end
