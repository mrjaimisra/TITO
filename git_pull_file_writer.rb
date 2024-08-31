class GitPullFileWriter
  attr_reader :file_class

  def initialize(file_class: File)
    @file_class = file_class
  end

  def pull
    output = `git pull`

    write_to_file(output)
  end

  def write_to_file(output)
    file_name = "git_pulls/git_pull_output-#{Time.now.to_i}.txt"
    output_file = file_class.new(file_name, "w")

    output_file.write(output)

    output_file
  end
end
