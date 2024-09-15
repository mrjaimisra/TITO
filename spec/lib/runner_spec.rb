require './lib/runner.rb'
require 'tempfile'

RSpec.describe Runner do
  it "accepts a passed in file path" do
    path_to_file = "path/to/file"

    runner = Runner.new(path_to_file:)

    expect(runner.path_to_file).to eq(path_to_file)
  end

  it "accepts a path to a project directory" do
    path_to_project = "path/to/project"

    runner = Runner.new(path_to_project:)

    expect(runner.path_to_project).to eq(path_to_project)
  end

  it "runs a git pull for a passed in file" do
    path_to_file = "spec/fixtures/git_pulls/git_pull_output-1726356709.txt"

    runner = Runner.new(path_to_file: path_to_file)
    allow(runner).to receive(:puts).and_call_original
    runner.run

    expect(runner).to have_received(:puts).with("Parsing the output of #{path_to_file}...\n\n")
    expect(runner.file.path).to eq(path_to_file)
    expect(runner.output).to eq(File.read(path_to_file))
  end

  it "runs a git pull for a project directory" do
    path_to_project = "."
    file_path = "spec/fixtures/git_pulls/git_pull_output-1726356709.txt"
    output = File.read(file_path)
    tempfile = Tempfile.new
    tempfile.write(output)

    runner = Runner.new(path_to_project: path_to_project)
    allow(runner).to receive(:puts).and_call_original
    allow(runner).to receive(:git_pull_and_write_to_file).and_return(tempfile)
    runner.run

    tempfile.close
    expect(runner.file).to eq(tempfile)
    expect(runner.output).to eq(output)
    expect(runner).to have_received(:puts).with("Pulling from git and writing the output to a file...\n\n")
  end

  it "parses the output of a git pull when a file is passed in" do
    path_to_file = "spec/fixtures/git_pulls/git_pull_output-1726356709.txt"
    output = File.read(path_to_file)

    runner = Runner.new(path_to_file:)
    allow(runner).to receive(:puts).and_call_original
    runner.run

    expect(runner).to have_received(:puts).with("\nGitPullFileWriter output:\n\n#{output}")
    expect(runner.parser.files_changed?).to eq(true)
    expect(runner.parser.changed_files.length).to eq(6)
    expect(runner.parser.changed_files.first.file_path).to eq(".gitignore")
  end

  it "parses the output of a git pull when a project directory is passed in" do
    path_to_project = "."
    output = File.read("spec/fixtures/git_pulls/git_pull_output-1726356709.txt")
    tempfile = Tempfile.new
    tempfile.write(output)

    runner = Runner.new(path_to_project:)
    allow(runner).to receive(:puts).and_call_original
    allow(runner).to receive(:git_pull_and_write_to_file).and_return(tempfile)
    runner.run

    expect(runner).to have_received(:puts).with("\nGitPullFileWriter output:\n\n#{output}")
    expect(runner.parser.files_changed?).to eq(true)
    expect(runner.parser.changed_files.length).to eq(6)
    expect(runner.parser.changed_files.first.file_path).to eq(".gitignore")
  end
end
