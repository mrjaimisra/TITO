class GitPullParser
  attr_reader :changed_files

  ChangedFile = Struct.new(:additions)
  def parse(output)
    lines = lines_representing_changed_files(output)

    @changed_files = lines.map do |line|
      additions = parse_additions(line)
      ChangedFile.new(additions: additions)
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

  def parse_additions(line)
    line.split("|").last.split("+").last.strip.to_i
  end
end
