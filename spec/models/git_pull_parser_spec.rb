require 'spec_helper'
require './app/models/git_pull_parser'

RSpec.describe GitPullParser do
  it "parses git pull output from a file and can determine that files have changed" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull-output-1725121785.txt")

    git_pull_parser.parse(output)

    expect(git_pull_parser.files_changed?).to be true
  end

  it "determines how many lines of code have been added to changed files" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull-output-1725121785.txt")

    git_pull_parser.parse(output)
    lines_of_code_added_to_first_changed_file = git_pull_parser.changed_files.first.additions

    expect(lines_of_code_added_to_first_changed_file).to eq(2)
  end

  it "determines how many lines of code have been deleted from changed files" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull_output-1725856246.txt")

    git_pull_parser.parse(output)
    lines_of_code_deleted_from_first_changed_file = git_pull_parser.changed_files.first.deletions

    expect(lines_of_code_deleted_from_first_changed_file).to eq(5)
  end

  it "determines additions and deletions when both exist for the same file" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull_output-1725857145.txt")

    git_pull_parser.parse(output)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.additions).to eq(4)
    expect(changed_file.deletions).to eq(8)
  end

  it "ensures the number of line changes in the output matches its total number of plus and minus signs" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull_output-1725857145.txt")

    git_pull_parser.parse(output)
    changed_file = git_pull_parser.changed_files.first
    number_of_plus_and_minus_signs = changed_file.additions + changed_file.deletions
    number_of_lines_changed_from_output = changed_file.number_of_changes

    expect(number_of_lines_changed_from_output).to eq(number_of_plus_and_minus_signs)
  end

  it "counts the total line length a changed file" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull_output-fake-file-for-counting-total-line-length.txt")

    git_pull_parser.parse(output)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.total_line_length).to eq(14)
  end

  it "records the total flog score for a changed file if the file has the extension .rb" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull_output-fake-file-for-recording-flog-scores.txt")

    git_pull_parser.parse(output)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.total_flog_score).to eq(21.7)
  end

  it "records the average flog score per method for a changed file if the file has the extension .rb" do
    git_pull_parser = GitPullParser.new
    output = File.read("spec/fixtures/git_pulls/git_pull_output-fake-file-for-recording-flog-scores.txt")

    git_pull_parser.parse(output)
    changed_file = git_pull_parser.changed_files.first

    expect(changed_file.average_flog_score_per_method).to eq(4.3)
  end
end
