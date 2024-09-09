class GitPullParser
  attr_reader :changed_files, :additions, :deletions

  ChangedFile = Struct.new(:additions, :deletions)
  def parse(output)
    @additions = 0
    @deletions = 0
    lines = lines_representing_changed_files(output)

    @changed_files = lines.map do |line|
      parse_additions_and_deletions(line)

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

  def parse_additions_and_deletions(line)
    line.split("|").last.split(" ").last.chars.each do |plus_or_minus|
      case plus_or_minus
      when "+"
        @additions += 1
      when "-"
        @deletions += 1
      end
    end
  end
end
