require 'curses'

module SafeUpdate
  class Presenter
    # outdated_gems is an array of instances of SafeUpdate::OutdatedGem

    SPINNER_STATES = ['|', '/', '-', '\\']

    def initialize
      Curses.noecho
      Curses.init_screen

      @tick = 1
      @running = true
    end

    def call(outdated_gems)
      @outdated_gems = outdated_gems
      while @running do
        @tick += 1
        update_screen
        sleep 0.3
      end
    end

    def stop
      @running = false
      print_final_output
    end

    private

    def print_final_output
      Curses.close_screen
      puts title
      puts header
      @outdated_gems.each do |outdated_gem|
        puts present_single_gem(outdated_gem)
      end
    end

    def update_screen
      Curses.setpos(0, 0)
      Curses.addstr(title)
      Curses.refresh

      Curses.setpos(1, 0)
      Curses.addstr(header)
      Curses.refresh

      @outdated_gems.each_with_index do |outdated_gem, i|
        Curses.setpos(i + 2, 0)
        line = present_single_gem(outdated_gem)
        Curses.addstr(line)
        Curses.refresh
      end
    end

    def title
      '=> Updating your gems... safely   ' + current_spinner_state
    end

    def current_spinner_state
      div, remainder = @tick.divmod(SPINNER_STATES.length)
      SPINNER_STATES[remainder]
    end

    def header
      return [
        fixed_length_string('GEM', 15),
        fixed_length_string('INSTALLED', 10),
        fixed_length_string('REQUESTED', 10),
        fixed_length_string('NEWEST', 7),
        fixed_length_string('STATUS', 10)
        ].join(' | ')
    end

    def present_single_gem(outdated_gem)
      status = outdated_gem.current_status
      status += ' ' + current_spinner_state if outdated_gem.being_operated_on_now?
      return [
        fixed_length_string(outdated_gem.gem_name, 15),
        fixed_length_string(outdated_gem.installed, 10),
        fixed_length_string(outdated_gem.requested || '    -', 10),
        fixed_length_string(outdated_gem.newest, 7),
        fixed_length_string(status, 10)
      ].join(' | ')
    end

    # inspired by http://stackoverflow.com/questions/14714936/fix-ruby-string-to-n-characters
    def fixed_length_string(str, length)
      "%-#{length}.#{length}s" % str
    end
  end
end
