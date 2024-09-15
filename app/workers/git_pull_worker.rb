require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
end

class GitPullWorker
  include Sidekiq::Job

  def perform(path_to_project = "", passed_in_file_path = "")
    result = `ruby lib/run.rb #{path_to_project} #{passed_in_file_path}`
    puts result
  end
end
