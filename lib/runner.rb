require './app/models/git_pull_file_writer.rb'
require './app/models/git_pull_parser.rb'
require './app/models/changed_file.rb'
require "sinatra/activerecord"

class Runner
  attr_reader :path_to_file, :path_to_project, :output, :file, :parser

  def initialize(path_to_file: nil, path_to_project: ".")
    @path_to_file = path_to_file
    @path_to_project = path_to_project
  end

  def run
    @file = generate_output_file

    return if file.blank?

    @output = file.read

    parse_output_and_save_changed_files unless output.blank?
  end

  def parser
    @parser ||= GitPullParser.new
  end

  private

  def generate_output_file
    if path_to_file
      set_output_from_passed_in_file
    else
      set_output_from_git_pull
    end
  end

  def set_output_from_passed_in_file
    puts "Parsing the output of #{path_to_file}...\n\n"
    File.open(path_to_file)
  end

  def set_output_from_git_pull
    puts "\nPulling from git in directory: \"#{path_to_project}\"\n\n"
    new_file = git_pull_and_write_to_file

    if !new_file
      puts "Already up to date.\n\n"
      return
    end
    puts "\nWriting the output to a file...\n"
    puts "File path: #{new_file.path}"

    new_file.rewind
    new_file
  end

  def git_pull_and_write_to_file
    GitPullFileWriter.new(path_to_project:).pull
  end

  def parse_output_and_save_changed_files
    puts "\nGitPullFileWriter output:\n\n#{output}"

    parser.parse_from_file(file.path)
    file.close

    return if !parser.files_changed?

    puts "\nCreating #{parser.changed_files.length} records in the database...\n\n"

    if parser.save_changed_files!
      puts "\nRecords created successfully.\n\n"
    else
      puts "\nThere was an error saving the records: #{parser.errors.full_messages.join(", ")}.\n\n"
    end
  end

end
