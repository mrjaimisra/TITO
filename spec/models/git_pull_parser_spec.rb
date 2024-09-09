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
end
