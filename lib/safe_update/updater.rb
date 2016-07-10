module SafeUpdate
  class Updater
    # push:
    #   If push is eg. 3, we will run `git push` every 3 commits.
    #   If push is nil, we will never run git push.
    # test_command:
    #   Command to run your tests after each gem update.
    #   If exit status is non-zero, the gem will not be updated.
    def run(push: nil, test_command: nil)
      run_git_push = (push && push.to_i > 0) ? true : false
      push_interval = push.to_i if run_git_push

      check_for_staged_changes
      check_for_gemfile_lock_changes

      outdated_gems.to_enum.with_index(1) do |outdated_gem, index|
        outdated_gem.attempt_update(test_command)
        `git push` if run_git_push && index % push_interval == 0
      end

      # run it once at the very end, so the final commit can be tested in CI
      `git push` if run_git_push

      display_finished_message
    end

    private

    def outdated_gems
      return @outdated_gems if @outdated_gems

      @outdated_gems = []
      bundle_outdated_parseable.split(/\n+/).each do |line|
        @outdated_gems << OutdatedGem.new(line)
      end
      return @outdated_gems
    end

    def bundle_outdated_parseable
      output = `bundle outdated --parseable`
      if output.strip == "Unknown switches '--parseable'"
        # pre-1.12.0 version of bundler
        output = `bundle outdated`
        output.gsub!(/(\n|.)*Outdated gems included in the bundle:/, '')
        output.gsub!(/  \* /, '')
        output.gsub!(/ in group.*/, '')
      end

      output.strip
    end

    def check_for_staged_changes
      result = `git diff --name-only --cached`
      if result.strip.length > 0
        puts 'You have staged changes in git.'
        puts 'Please commit or stash your changes before running safe_update'
        exit 1
      end
    end

    def check_for_gemfile_lock_changes
      result = `git diff --name-only`
      if result.include? 'Gemfile.lock'
        puts 'You have uncommitted changes in your Gemfile.lock.'
        puts 'Please commit or stash your changes before running safe_update'
        exit 1
      end
    end

    def display_finished_message
      puts '-------------'
      puts '-------------'
      puts 'FINISHED'
    end
  end
end
