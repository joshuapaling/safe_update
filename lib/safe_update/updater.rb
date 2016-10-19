module SafeUpdate
  class Updater
    def initialize(git_repo = nil)
      @git_repo = git_repo || GitRepo.new
      @git_repo.perform_safety_checks
    end
    # push:
    #   If push is eg. 3, we will run @git_repo.push every 3 commits.
    #   If push is nil, we will never run git push.
    # test_command:
    #   Command to run your tests after each gem update.
    #   If exit status is non-zero, the gem will not be updated.
    def run(push: nil, test_command: nil)
      run_git_push = (push && push.to_i > 0) ? true : false
      push_interval = push.to_i if run_git_push

      puts 'Finding outdated gems...'
      outdated_gems = get_outdated_gems

      presenter = SafeUpdate::Presenter.new
      Thread.new { presenter.call(outdated_gems) }

      outdated_gems.to_enum.with_index(1) do |outdated_gem, index|
        outdated_gem.attempt_update(test_command)
        @git_repo.push if run_git_push && index % push_interval == 0
      end

      # run it once at the very end, so the final commit can be tested in CI
      @git_repo.push if run_git_push

      presenter.stop
    end

    private

    def get_outdated_gems
      @outdated_gems ||= BundleOutdatedParser.new.call
    end
  end
end
