class GitPullParser
  attr_reader :changed_files, :additions, :deletions

  ChangedFile = Struct.new(:additions, :deletions, :number_of_changes, :total_line_length)
  def parse(output)
    @additions = 0
    @deletions = 0
    lines = lines_representing_changed_files(output)

    @changed_files = lines.map do |line|
      parse_additions_and_deletions(line)
      number_of_changes = number_of_line_changes_in_output(line)
      total_line_length = total_line_length_for_file(line)

      ChangedFile.new(
        additions: additions,
        deletions: deletions,
        number_of_changes: number_of_changes,
        total_line_length: total_line_length,
      )
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

  def number_of_line_changes_in_output(line)
    line.split("|").last.split(" ").first.to_i
  end

  def total_line_length_for_file(line)
    file_path = line.split("|").first.strip
    total_lines = File.readlines(file_path)
    total_lines.length
  end
end
