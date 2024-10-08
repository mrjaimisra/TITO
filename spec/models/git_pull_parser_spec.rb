require 'spec_helper'
require './app/models/git_pull_parser'

RSpec.describe GitPullParser do
  it "parses git pull output from a file and can determine that files have changed" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull-output-1725121785.txt"

    git_pull_parser.parse_from_file(output_file_path)

    expect(git_pull_parser.files_changed?).to be true
  end

  it "determines how many lines of code have been added to changed files" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull-output-1725121785.txt"

    git_pull_parser.parse_from_file(output_file_path)
    lines_of_code_added_to_first_changed_file = git_pull_parser.changed_files.first.additions

    expect(lines_of_code_added_to_first_changed_file).to eq(2)
  end

  it "determines how many lines of code have been deleted from changed files" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1725856246.txt"

    git_pull_parser.parse_from_file(output_file_path)
    lines_of_code_deleted_from_first_changed_file = git_pull_parser.changed_files.first.deletions

    expect(lines_of_code_deleted_from_first_changed_file).to eq(5)
  end

  it "determines additions and deletions when both exist for the same file" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1725857145.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.additions).to eq(4)
    expect(changed_file.deletions).to eq(8)
  end

  it "ensures the number of line changes in the output matches its total number of plus and minus signs" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1725857145.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first
    number_of_plus_and_minus_signs = changed_file.additions + changed_file.deletions
    number_of_lines_changed_from_output = changed_file.number_of_changes

    expect(number_of_lines_changed_from_output).to eq(number_of_plus_and_minus_signs)
  end

  it "counts the total line length a changed file" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-fake-file-for-counting-total-line-length.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.total_line_length).to eq(14)
  end

  it "records the total flog score for a changed file if the file has the extension .rb" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-fake-file-for-recording-flog-scores.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.total_flog_score).to eq(21.7)
  end

  it "records the average flog score per method for a changed file if the file has the extension .rb" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-fake-file-for-recording-flog-scores.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.average_flog_score_per_method).to eq(4.3)
  end

  it "parses the file path for a changed file" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1725857145.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.file_path).to eq("app/models/git_pull_parser.rb")
  end

  it "parses the file name for a changed file" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1725857145.txt"

    git_pull_parser.parse_from_file(output_file_path)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.file_name).to eq("git_pull_parser.rb")
  end

  it "saves changed file events to the database for each file that has changed" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-saving-changed-file-records-to-database.txt"

    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    expect(ChangedFile.count).to eq(5)
  end

  it "parses output from a file path" do
    git_pull_parser = GitPullParser.new
    file_path = "spec/fixtures/git_pulls/git_pull_output-1725876701.txt"

    output = git_pull_parser.parse_from_file(file_path)

    expect(git_pull_parser.files_changed?).to be true
    expect(git_pull_parser.changed_files.count).to eq(3)
    expect(git_pull_parser.changed_files.first.additions).to eq(3)
    expect(git_pull_parser.changed_files.first.deletions).to eq(1)
  end

  it "sets the created at and updated at based on the timestamp in the filename" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1725856246.txt"

    created_and_updated_at = Time.at(1725856246)
    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    first_changed_file = ChangedFile.first
    expect(first_changed_file.created_at).to eq(created_and_updated_at)
    expect(first_changed_file.updated_at).to eq(created_and_updated_at)
  end

  it "sets the created at and updated at to the current time if there is no timestamp integer in the filename" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-invalid-timestamp.txt"

    now = Time.at(1725902463)
    allow(Time).to receive(:now).and_return(now)
    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    first_changed_file = ChangedFile.first
    expect(first_changed_file.created_at).to eq(now)
    expect(first_changed_file.updated_at).to eq(now)
  end

  it "does not attempt to parse total line length for a deleted file" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-deleted-file.txt"

    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    first_changed_file = ChangedFile.first
    expect(first_changed_file.total_line_length).to be_nil
  end

  it "doesn't attempt to parse total flog score for a file that doesn't exist" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-deleted-file.txt"

    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    first_changed_file = ChangedFile.first
    expect(first_changed_file.total_flog_score).to be_nil
  end

  it "doesn't attempt to parse average flog score per method for a file that doesn't exist" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-deleted-file.txt"

    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    first_changed_file = ChangedFile.first
    expect(first_changed_file.average_flog_score_per_method).to be_nil
  end

  it "doesn't create duplicate records when the same output file is parsed multiple times" do
    git_pull_parser = GitPullParser.new
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-1726356709.txt"

    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!
    git_pull_parser.parse_from_file(output_file_path)
    git_pull_parser.save_changed_files!

    expect(ChangedFile.count).to eq(6)
  end

  it "prepends the project directory path to the file path when reading the total line length for that file" do
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-testing-total-line-length-with-relative-project-path.txt"
    path_to_project = "spec/fixtures/"
    first_changed_file_path = "git_pulls/git_pull_output-for-testing-total-line-length-with-relative-project-path.txt"
    file_path_in_project_directory = "#{path_to_project}#{first_changed_file_path}"

    git_pull_parser = GitPullParser.new
    allow(git_pull_parser).to receive(:path_to_project).and_return(path_to_project)
    git_pull_parser.parse_from_file(output_file_path)

    expect(git_pull_parser.changed_files.first.total_line_length).to eq(1)
  end

  it "prepends the project directory path to the file path when running flog on that file" do
    output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-testing-flog-scores-with-relative-project-path.txt"
    path_to_project = "spec/fixtures/"
    first_changed_file_path = "for_recording_flog_scores.rb"
    file_path_in_project_directory = "#{path_to_project}#{first_changed_file_path}"

    git_pull_parser = GitPullParser.new
    allow(git_pull_parser).to receive(:path_to_project).and_return(path_to_project)
    git_pull_parser.parse_from_file(output_file_path)

    expect(git_pull_parser.changed_files.first.total_flog_score).to eq(21.7)
    expect(git_pull_parser.changed_files.first.average_flog_score_per_method).to eq(4.3)
  end

  describe "#file_path_in_project_directory" do
    it "joins a project path with file path on a '/' character" do
      output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-testing-relative-project-path.txt"
      path_to_project = "spec/fixtures"
      first_changed_file_path = "app/models/git_pull_parser.rb"
      file_path_in_project_directory = "spec/fixtures/app/models/git_pull_parser.rb"

      git_pull_parser = GitPullParser.new
      allow(git_pull_parser).to receive(:path_to_project).and_return(path_to_project)
      relative_file_path = git_pull_parser.file_path_in_project_directory(first_changed_file_path)

      expect(relative_file_path).to eq(file_path_in_project_directory)
    end

    it "does not add an extra '/' character if the project path already ends with one" do
      output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-testing-relative-project-path.txt"
      path_to_project = "spec/fixtures/"
      first_changed_file_path = "app/models/git_pull_parser.rb"
      file_path_in_project_directory = "spec/fixtures/app/models/git_pull_parser.rb"

      git_pull_parser = GitPullParser.new
      allow(git_pull_parser).to receive(:path_to_project).and_return(path_to_project)
      relative_file_path = git_pull_parser.file_path_in_project_directory(first_changed_file_path)

      expect(relative_file_path).to eq(file_path_in_project_directory)
    end

    it "does not add an extra '/' character if the file path already starts with one" do
      output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-testing-relative-project-path.txt"
      path_to_project = "spec/fixtures"
      first_changed_file_path = "/app/models/git_pull_parser.rb"
      file_path_in_project_directory = "spec/fixtures/app/models/git_pull_parser.rb"

      git_pull_parser = GitPullParser.new
      allow(git_pull_parser).to receive(:path_to_project).and_return(path_to_project)
      relative_file_path = git_pull_parser.file_path_in_project_directory(first_changed_file_path)

      expect(relative_file_path).to eq(file_path_in_project_directory)
    end

    it "does not add an extra '/' character if the project path already ends with one and the file path already starts with one" do
      output_file_path = "spec/fixtures/git_pulls/git_pull_output-for-testing-relative-project-path.txt"
      path_to_project = "spec/fixtures/"
      first_changed_file_path = "/app/models/git_pull_parser.rb"
      file_path_in_project_directory = "spec/fixtures/app/models/git_pull_parser.rb"

      git_pull_parser = GitPullParser.new
      allow(git_pull_parser).to receive(:path_to_project).and_return(path_to_project)
      relative_file_path = git_pull_parser.file_path_in_project_directory(first_changed_file_path)

      expect(relative_file_path).to eq(file_path_in_project_directory)
    end
  end
end
