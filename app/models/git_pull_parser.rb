require './app/models/changed_file'

class GitPullParser
  attr_reader :changed_files, :additions, :deletions, :output_file_path

  def parse_from_file(output_file_path)
    @output_file_path = output_file_path
    output = File.read(output_file_path)

    parse(output)
  end

  def files_changed?
    @changed_files.length > 0
  end

  def save_changed_files!
    changed_files.each do |changed_file|
      changed_file.save!
    end
  end

  private

  def parse(output)
    lines = raw_data_from_each_line(output)

    @changed_files = lines.map do |line|
      data_for_each_changed_file(line)
    end

    changed_files
  end

  def data_for_each_changed_file(line)
    additions = additions(line)
    deletions = deletions(line)
    number_of_changes = additions + deletions
    file_path = file_path_for_changed_file(line)
    total_line_length = total_line_length_for_file(file_path)
    flog_lines = run_flog_and_parse_output(file_path)
    total_flog_score = get_total_flog_score(flog_lines)
    average_flog_score_per_method = run_flog_and_get_average_flog_score_per_method(flog_lines)
    file_name = File.basename(file_path)
    created_and_updated_at = parse_timestamp_from_output_file_path

    ChangedFile.new(
      additions: additions,
      deletions: deletions,
      number_of_changes: number_of_changes,
      total_line_length: total_line_length,
      total_flog_score: total_flog_score,
      average_flog_score_per_method: average_flog_score_per_method,
      file_path: file_path,
      file_name: file_name,
      created_at: created_and_updated_at,
      updated_at: created_and_updated_at,
    )
  end

  def raw_data_from_each_line(output)
    output.split(/\n/).map { |line| line.split("\t") }
  end

  def additions(line) = line[0].to_i

  def deletions(line) = line[1].to_i

  def total_line_length_for_file(file_path)
    if File.exist?(file_path)
      total_lines = File.readlines(file_path)
      total_lines.length
    end
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

  def file_path_for_changed_file(line) = line[-1]

  def run_flog_and_parse_output(file_path)
    file_extension = File.extname(file_path)

    return unless File.exist?(file_path)
    return unless file_extension == ".rb"

    flog_output = `flog #{file_path}`

    flog_output.split("\n").map{|flog_line| flog_line.strip}
  end

  def get_flog_value_from_line(flog_line)
    flog_line.first.split(":").first.to_f
  end

  def parse_timestamp_from_output_file_path
    timestamp_integer = File.basename(output_file_path).split(".").first.split("-").last.to_i

    if timestamp_integer.zero?
      Time.now
    else
      Time.at(timestamp_integer)
    end
  end
end
