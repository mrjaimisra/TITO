require 'spec_helper'
require './app/models/git_pull_file_writer'
require 'tempfile'

RSpec.describe GitPullFileWriter do
  it "runs git pull and writes the output to a file" do
    git_pull_file_writer = GitPullFileWriter.new(file_class: StringIO)
    git_pull_example_output = File.read("spec/fixtures/git_pulls/git_pull-output-1725121785.txt")
    allow(git_pull_file_writer).to receive(:`).and_call_original
    allow(git_pull_file_writer).to receive(:`).with("git rev-parse HEAD").and_return("")
    allow(git_pull_file_writer).to receive(:`).with("git pull").and_return("")
    allow(git_pull_file_writer).to receive(:`).with("git diff --numstat ").and_return(git_pull_example_output)

    file = git_pull_file_writer.pull

    expect(file.string).to eq(git_pull_example_output)
  end

  it "generates the correct file name" do
    git_pull_file_writer = GitPullFileWriter.new
    allow(git_pull_file_writer).to receive(:`).and_call_original
    allow(git_pull_file_writer).to receive(:`).with("git rev-parse HEAD").and_return("")
    allow(git_pull_file_writer).to receive(:`).with("git pull").and_return("")
    allow(git_pull_file_writer).to receive(:`).with("git diff --stat=1000,1000 ").and_return("")
    current_time = Time.new("2024-08-31 12:05:00.00 -0600")
    allow(Time).to receive(:now).and_return(current_time)

    file = git_pull_file_writer.pull
    file_name = file.path
    File.delete(file)

    expect(file_name).to eq("git_pulls/git_pull_output-1725127500.txt")
  end

  it "changes into the directory of the project being tracked before running git pull" do
    git_pull_file_writer = GitPullFileWriter.new(
      file_class: StringIO,
      path_to_project: "./spec",
    )
    allow(git_pull_file_writer).to receive(:`).and_call_original
    allow(git_pull_file_writer).to receive(:`).with("git rev-parse HEAD").and_return("")
    allow(git_pull_file_writer).to receive(:`).with("git pull").and_return("")
    allow(git_pull_file_writer).to receive(:`).with("git diff --stat=1000,1000 ").and_return("")

    git_pull_file_writer.pull

    expect(git_pull_file_writer.pull_directory).to eq(File.expand_path("./spec"))
  end

  it "doesn't save a file if the output of git pull is \"Already up to date.\"" do
    git_pull_file_writer = GitPullFileWriter.new
    allow(git_pull_file_writer).to receive(:`).and_call_original
    allow(git_pull_file_writer).to receive(:`).with("git pull").and_return("Already up to date.")

    file = git_pull_file_writer.pull

    expect(file).to be_nil
  end
end
