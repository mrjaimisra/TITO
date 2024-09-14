require 'spec_helper'
require './app/workers/git_pull_worker'

RSpec.describe GitPullWorker, type: :worker do
  it "enqueues the git pull job" do
    expect { GitPullWorker.perform_async }.to enqueue_sidekiq_job(GitPullWorker)
  end
end
