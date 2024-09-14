class GitPullFileWriter
  attr_reader :file_class, :path_to_project, :pull_directory

  def initialize(file_class: File, path_to_project: ".")
    @file_class = file_class
    @path_to_project = path_to_project
  end

  def pull
    git_diff_stat_output = ""

    Dir.chdir(path_to_project) do
      @pull_directory = Dir.pwd
      old_commit_SHA = `git rev-parse HEAD`
      git_pull_output = `git pull`
      return if git_pull_output.downcase.include?("Already up to date.".downcase)

      git_diff_stat_output = `git diff --numstat #{old_commit_SHA}`
    end

    write_to_file(git_diff_stat_output)
  end

  def write_to_file(output)
    file_name = "git_pulls/git_pull_output-#{Time.now.to_i}.txt"
    output_file = file_class.new(file_name, "w+")

    output_file.write(output)

    output_file
  end
end
