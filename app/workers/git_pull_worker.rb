require 'sidekiq'
require 'sidekiq-scheduler'
require 'dotenv/load'
require './lib/runner.rb'

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
end

class GitPullWorker
  include Sidekiq::Job
  sidekiq_options retry: false # job will be discarded if it fails

  def perform(path_to_project = ENV["PATH_TO_PROJECT"], path_to_file = nil)
    runner = Runner.new(path_to_project:, path_to_file:)
    result = runner.run

    puts result
  end
end
