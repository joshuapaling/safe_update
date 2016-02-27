module SafeUpdate
  class OutdatedGem
    attr_reader :name, :newest, :installed, :requested

    # line is a line from bundle outdated --parseable
    # eg. react-rails (newest 1.6.0, installed 1.5.0, requested ~> 1.0)
    # or. react-rails (newest 1.6.0, installed 1.5.0)
    def initialize(line)
      @name = string_between(line, '', ' (newest')
      @newest = string_between(line, ' (newest ', ', installed')
      if line.index('requested')
        @installed = string_between(line, ', installed ', ',')
      else
        @installed = string_between(line, ', installed ', ')')
      end
      @requested = string_between(line, ', requested ', ')')
    end

    def update
      shell_commands.each do |cmd|
        puts %x(#{cmd})
      end
    end

    def shell_commands
      [
        "bundle update #{@name}",
        "git add -A",
        "git commit -m 'bundle update #{@name}'"
      ]
    end

    private

    # returns the section of string that resides between marker1 and marker2
    def string_between(string, marker1, marker2)
      string[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end
  end
end
