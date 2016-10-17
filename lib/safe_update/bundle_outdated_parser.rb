# This class runs `bundle outdated` and parses the output
# into a workable data structure in Ruby.
module SafeUpdate
  class BundleOutdatedParser
    def call
      @outdated_gems = []
      # Yes, I know about `bundle outdated --parseable` but old versions
      # don't support it and it's really not THAT much more parseable anyway
      # and parseable still sometimes has lines that aren't relevant
      @output = `bundle outdated`
      @output.split(/\n+/).each do |line|
        process_single_line(line)
      end
      return @outdated_gems
    end

    private

    def process_single_line(line)
      # guard clause for output that's not an outdated gem
      return if !line.include?(' (newest')
      # get rid of leading *, eg in '  * poltergeist (newest 1.9.0, installed 1.8.1)'
      line.strip!
      line.gsub!(/^\*/, '')
      line.strip!

      @outdated_gems << OutdatedGem.new(
        gem_name: gem_name(line),
        newest: newest(line),
        installed: installed(line),
        requested: requested(line)
      )
    end

    def gem_name(line)
      string_between(line, '', ' (newest')
    end

    def newest(line)
      string_between(line, ' (newest ', ', installed')
    end

    def requested(line)
      string_between(line, ', requested ', ')')
    end

    def installed(line)
      if line.index('requested')
        string_between(line, ', installed ', ', requested')
      else
        string_between(line, ', installed ', ')')
      end
    end

    # returns the section of string that resides between marker1 and marker2
    def string_between(string, marker1, marker2)
      string[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end
  end
end
