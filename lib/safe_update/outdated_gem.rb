module SafeUpdate
  class OutdatedGem
    attr_reader :gem_name, :newest, :installed, :requested
    def initialize(opts = {})
      @gem_name  = opts[:gem_name]
      @newest    = opts[:newest]
      @installed = opts[:installed]
      @requested = opts[:requested]
      @git_repo  = opts[:git_repo] || GitRepo.new
    end

    def attempt_update(test_command = nil)
      puts '-------------'
      puts "OUTDATED GEM: #{@gem_name}"
      puts "   Newest: #{@newest}. "
      puts "Installed: #{@installed}."
      puts "Running `bundle update #{@gem_name}`..."

      `bundle update #{@gem_name}`

      # sometimes the gem may be outdated, but it's matching the
      # version required by the gemfile, so bundle update does nothing
      # in which case, don't waste time on tests etc.
      if false
        return
      end

      if test_command
        puts "Running tests with: #{test_command}"
        result = system(test_command)
        if result != true
          puts "tests failed - this gem won't be updated (test result: #{$?.to_i})"
          @git_repo.discard_local_changes
          return
        end
      end

      puts "committing changes (message: '#{commit_message}')..."
      @git_repo.commit_gemfile_lock(commit_message)
    end

    private

    def commit_message
      "update gem: #{@gem_name}"
    end
  end
end
