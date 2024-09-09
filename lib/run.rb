require './git_pull_file_writer'

puts "Pulling from git and writing the output to a file...\n\n"
puts GitPullFileWriter.new.pull
