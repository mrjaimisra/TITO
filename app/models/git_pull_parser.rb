class GitPullParser
  attr_reader :changed_files, :additions, :deletions

  ChangedFile = Struct.new(:additions, :deletions, :number_of_changes, :total_line_length, :total_flog_score)
  def parse(output)
    @additions = 0
    @deletions = 0
    lines = lines_representing_changed_files(output)

    @changed_files = lines.map do |line|
      parse_additions_and_deletions(line)
      number_of_changes = number_of_line_changes_in_output(line)
      total_line_length = total_line_length_for_file(line)
      total_flog_score = run_flog_and_get_total_flog_score(line)

      ChangedFile.new(
        additions: additions,
        deletions: deletions,
        number_of_changes: number_of_changes,
        total_line_length: total_line_length,
        total_flog_score: total_flog_score,
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

  def run_flog_and_get_total_flog_score(line)
    file_path = line.split("|").first.strip
    file_extension = File.extname(file_path)

    return unless file_extension == ".rb"

    flog_output = `flog #{file_path}`
    flog_lines = flog_output.split("\n").map{|flog_line| flog_line.strip}
    flog_total_line = flog_lines.select{|flog_line| flog_line.include?("flog total")}

    flog_total_line.first.split(":").first.to_f
  end
end
