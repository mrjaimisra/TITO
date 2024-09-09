class GitPullParser
  attr_reader :changed_files, :additions, :deletions

  ChangedFile = Struct.new(
    :file_path,
    :file_name,
    :additions,
    :deletions,
    :number_of_changes,
    :total_line_length,
    :total_flog_score,
    :average_flog_score_per_method,
  )

  def parse(output)
    @additions = 0
    @deletions = 0
    lines = lines_representing_changed_files(output)

    @changed_files = lines.map do |line|
      data_for_each_changed_file(line)
    end

    changed_files
  end

  def files_changed?
    @changed_files.length > 0
  end

  private

  def data_for_each_changed_file(line)
    parse_additions_and_deletions(line)
    number_of_changes = number_of_line_changes_in_output(line)
    file_path = file_path_for_changed_file(line)
    total_line_length = total_line_length_for_file(file_path)
    flog_lines = run_flog_and_parse_output(file_path)
    total_flog_score = get_total_flog_score(flog_lines)
    average_flog_score_per_method = run_flog_and_get_average_flog_score_per_method(flog_lines)

    ChangedFile.new(
      additions: additions,
      deletions: deletions,
      number_of_changes: number_of_changes,
      total_line_length: total_line_length,
      total_flog_score: total_flog_score,
      average_flog_score_per_method: average_flog_score_per_method,
      file_path: file_path,
      file_name: File.basename(file_path),
    )
  end

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

  def total_line_length_for_file(file_path)
    total_lines = File.readlines(file_path)
    total_lines.length
  end

  def get_total_flog_score(flog_lines)
    return if flog_lines.nil?

    flog_total_line = flog_lines.select{|flog_line| flog_line.include?("flog total")}

    get_flog_value_from_line(flog_total_line)
  end

  def run_flog_and_get_average_flog_score_per_method(flog_lines)
    return if flog_lines.nil?

    flog_average_line = flog_lines.select{|flog_line| flog_line.include?("flog/method average")}

    get_flog_value_from_line(flog_average_line)
  end

  def file_path_for_changed_file(line)
    line.split("|").first.strip
  end

  def run_flog_and_parse_output(file_path)
    file_extension = File.extname(file_path)

    return unless file_extension == ".rb"

    flog_output = `flog #{file_path}`

    flog_output.split("\n").map{|flog_line| flog_line.strip}
  end

  def get_flog_value_from_line(flog_line)
    flog_line.first.split(":").first.to_f
  end
end
