module SafeUpdate
  class Updater
    def run(options = {})
      options[:push] = options[:push].to_i if options[:push]
      check_for_staged_changes
      check_for_gemfile_lock_changes
      output_array = bundle_outdated_parseable.split(/\n+/)
      output_array.to_enum.with_index(1) do |line, index|
        update_gem(line)
        `git push` if options[:push] && index % options[:push] == 0
      end

      # run it once at the very end, so the final commit can be tested in CI
      `git push` if options[:push]

      puts '-------------'
      puts '-------------'
      puts 'FINISHED'
    end

    private

    def update_gem(line)
      OutdatedGem.new(line).update
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
  end
end
