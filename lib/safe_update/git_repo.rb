# This class models a git repo that we are running safe_update on,
# and the operations we need to perform in the context
# of running safe_update. This class is not unit tested.
# It's simple code that mostly just makes system calls
# to git.
module SafeUpdate
  class GitRepo
    def perform_safety_checks
      check_for_staged_changes
      if gemfile_lock_has_changes?
        raise 'safe_update cannot run while there are uncommitted changes in Gemfile.lock'
      end
    end

    def discard_local_changes
      `git reset HEAD --hard`
    end

    def commit_gemfile_lock(message)
      `git add Gemfile.lock`
      `git commit -m '#{message}'`
    end

    def push
      `git push`
    end

    def gemfile_lock_has_changes?
      result = `git diff --name-only`
      return result.include? 'Gemfile.lock'
    end

    private

    def check_for_staged_changes
      result = `git diff --name-only --cached`
      if result.strip.length > 0
        raise 'safe_update cannot run while git repo has staged changes'
      end
    end
  end
end
