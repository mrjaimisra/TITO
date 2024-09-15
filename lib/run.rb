require './lib/runner.rb'

Runner.new(path_to_project: ARGV[0], path_to_file: ARGV[1]).run
