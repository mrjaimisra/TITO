class GitPullParser
  attr_reader :changed_files

  ChangedFile = Struct.new(:additions, :deletions)
  def parse(output)
    lines = lines_representing_changed_files(output)

    @changed_files = lines.map do |line|
      additions = parse_addition_or_deletion(line, "+")
      deletions = parse_addition_or_deletion(line, "-")
      ChangedFile.new(additions: additions, deletions: deletions)
    end

    changed_files
  end

  def files_changed?
    @changed_files.length > 0
  end

  private

  def lines_representing_changed_files(output)
    output.split(/\n/).filter_map { |line| line if line.include?("|") }
  end

  def parse_addition_or_deletion(line, delimiter)
    line.split("|").last.split(delimiter).first.strip.to_i
  end
end
