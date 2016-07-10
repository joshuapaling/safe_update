module SafeUpdate
  class OutdatedGem
    attr_reader :newest, :installed, :requested

    # line is a line from bundle outdated --parseable
    # eg. react-rails (newest 1.6.0, installed 1.5.0, requested ~> 1.0)
    # or. react-rails (newest 1.6.0, installed 1.5.0)
    def initialize(line)
      @line = line
      if name.to_s.empty?
        fail "Unexpected output from `bundle outdated --parseable`: #{@line}"
      end
    end

    def attempt_update(test_command = nil)
      puts '-------------'
      puts "OUTDATED GEM: #{name}"
      puts "   Newest: #{newest}. "
      puts "Installed: #{installed}."
      puts "Running `bundle update #{name}`..."

      `bundle update #{name}`

      if test_command
        tests_passed = `#{test_command}`
      else
        # if we're not running tests, just pretend they ran
        # and passed
        tests_passed = true
      end

      if tests_passed
        puts "committing changes (message: '#{commit_message}')..."

        `git add Gemfile.lock`
        `git commit -m '#{commit_message}'`
      else
        puts "tests failed - this gem won't be updated"
        `git reset HEAD --hard`
      end
    end

    def name
      string_between(@line, '', ' (newest')
    end

    def newest
      string_between(@line, ' (newest ', ', installed')
    end

    def requested
      string_between(@line, ', requested ', ')')
    end

    def installed
      if @line.index('requested')
        string_between(@line, ', installed ', ', requested')
      else
        string_between(@line, ', installed ', ')')
      end
    end

    private

    def commit_message
      "update gem: #{name}"
    end

    # returns the section of string that resides between marker1 and marker2
    def string_between(string, marker1, marker2)
      string[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end
  end
end
