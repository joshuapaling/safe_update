module SafeUpdate
  class Updater
    def run
      output_array = bundle_outdated_parseable.split(/\n+/)
      output_array.each do |line|
        OutdatedGem.new(line).update
      end
      puts '-------------'
      puts '-------------'
      puts 'FINISHED'
    end

    def bundle_outdated_parseable
      output = %x(bundle outdated --parseable)
      if output.strip == "Unknown switches '--parseable'"
        # pre-1.12.0 version of bundler
        output = %x(bundle outdated)
        output.gsub!(/(\n|.)*Outdated gems included in the bundle:/, '')
        output.gsub!(/  \* /, '')
        output.gsub!(/ in group.*/, '')
      end

      return output.strip
    end
  end
end