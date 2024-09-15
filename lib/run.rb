require './lib/runner.rb'
puts "ARGV[0] class: #{ARGV[0].class}"
puts "ARGV[0]: #{ARGV[0]}"
Runner.new(path_to_project: ARGV[0], path_to_file: ARGV[1]).run
