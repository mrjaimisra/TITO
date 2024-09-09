class GitPullFileWriter
  attr_reader :file_class, :path_to_project, :pull_directory

  def initialize(file_class: File, path_to_project: ".")
    @file_class = file_class
    @path_to_project = path_to_project
  end

  def pull
    output = ""

    Dir.chdir(path_to_project) do
      @pull_directory = Dir.pwd
      output = `git pull`
    end

    write_to_file(output)
  end

  def write_to_file(output)
    return if output.downcase.include?("Already up to date.".downcase)

    file_name = "git_pulls/git_pull_output-#{Time.now.to_i}.txt"
    output_file = file_class.new(file_name, "w+")

    output_file.write(output)

    output_file
  end
end
