require './app/models/git_pull_file_writer.rb'
require './app/models/git_pull_parser.rb'
require './app/models/changed_file.rb'
require "sinatra/activerecord"

class Runner
  attr_reader :path_to_file, :path_to_project, :output, :file, :parser

  def initialize(path_to_file: "", path_to_project: "")
    @path_to_file = path_to_file
    @path_to_project = path_to_project
  end

  def run
    if path_to_file.present?
      set_output_from_passed_in_file
    else
      set_output_from_git_pull
    end

    parse_output_and_save_changed_files
  end

  def set_output_from_passed_in_file
    puts "Parsing the output of #{path_to_file}...\n\n"
    @file = File.open(path_to_file)
    @output = file.read
  end

  def git_pull_and_write_to_file
    GitPullFileWriter.new(path_to_project:).pull
  end

  def set_output_from_git_pull
    puts "Pulling from git and writing the output to a file...\n\n"
    @file = git_pull_and_write_to_file

    if !file
      puts "Already up to date.\n\n"
      exit
    end
    puts "File path: #{file.path}"

    file.rewind
    @output = file.read
  end

  def parse_output_and_save_changed_files
    puts "\nGitPullFileWriter output:\n\n#{output}"

    @parser = GitPullParser.new
    parser.parse_from_file(file.path)
    file.close

    exit if !parser.files_changed?

    puts "\nCreating #{parser.changed_files.length} records in the database...\n\n"

    if parser.save_changed_files!
      puts "\nRecords created successfully.\n\n"
    else
      puts "\nThere was an error saving the records: #{parser.errors.full_messages.join(", ")}.\n\n"
    end
  end
end
