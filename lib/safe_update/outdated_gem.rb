module SafeUpdate
  class OutdatedGem
    STATUS_PENDING    = 'pending'
    STATUS_UPDATING   = 'updating'
    STATUS_TESTING    = 'testing'
    STATUS_UPDATED    = 'updated'
    STATUS_UNCHANGED  = 'unchanged'
    STATUS_TESTS_FAIL = 'tests_fail'

    attr_reader :gem_name, :newest, :installed, :requested, :current_status
    def initialize(opts = {})
      @gem_name  = opts[:gem_name]
      @newest    = opts[:newest]
      @installed = opts[:installed]
      @requested = opts[:requested]
      @git_repo  = opts[:git_repo] || GitRepo.new
      @current_status = STATUS_PENDING
    end

    def attempt_update(test_command = nil)
      @current_status = STATUS_UPDATING
      `bundle update #{@gem_name}`

      # sometimes the gem may be outdated, but it's matching the
      # version required by the gemfile, so bundle update does nothing
      # in which case, don't waste time on tests etc.
      if false
        return
      end

      if test_command
        @current_status = STATUS_TESTING
        result = system(test_command)
        if result != true
          @current_status = STATUS_TESTS_FAIL
          @git_repo.discard_local_changes
          return
        end
      end

      if @git_repo.gemfile_lock_has_changes?
        @git_repo.commit_gemfile_lock(commit_message)
        @current_status = STATUS_UPDATED
      else
        @current_status = STATUS_UNCHANGED
      end
    end

    def being_operated_on_now?
      [STATUS_UPDATING, STATUS_TESTING].include?(@current_status)
    end

    private

    def commit_message
      "update gem: #{@gem_name}"
    end
  end
end
