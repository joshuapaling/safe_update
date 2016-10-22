require 'curses'
require 'colorize'

module SafeUpdate
  class Presenter
    include Curses
    # outdated_gems is an array of instances of SafeUpdate::OutdatedGem

    SPINNER_STATES = ['|', '/', '-', '\\']

    def initialize
      Curses.noecho
      Curses.init_screen
      Curses.start_color
      Curses.init_pair(COLOR_BLUE, COLOR_BLUE, COLOR_BLACK)
      Curses.init_pair(COLOR_RED, COLOR_RED, COLOR_BLACK)
      Curses.init_pair(COLOR_GREEN, COLOR_GREEN, COLOR_BLACK)
      Curses.init_pair(COLOR_YELLOW, COLOR_YELLOW, COLOR_BLACK)

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
        line = present_single_gem(outdated_gem)
        color = colorize_color(outdated_gem)
        if color
          puts line.send(color)
        else
          puts line
        end
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
        color = curses_color(outdated_gem)
        if color
          Curses.attron(color_pair(color)|A_NORMAL){
            Curses.addstr(line)
          }
        else
          Curses.addstr(line)
        end
        Curses.refresh
      end
    end

    def title
      'Updating your gems... Safely'
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

    def curses_color(outdated_gem)
      case outdated_gem.current_status
      when OutdatedGem::STATUS_TESTS_FAIL
        return COLOR_RED
      when OutdatedGem::STATUS_UPDATING,
           OutdatedGem::STATUS_TESTING
        return COLOR_YELLOW
      when OutdatedGem::STATUS_UPDATED
        return COLOR_GREEN
      when OutdatedGem::STATUS_UNCHANGED
        return COLOR_BLUE
      when OutdatedGem::STATUS_PENDING
        return nil # render in default color
      else
        return nil
      end
    end

    def colorize_color(outdated_gem)
      case outdated_gem.current_status
      when OutdatedGem::STATUS_TESTS_FAIL
        return :red
      when OutdatedGem::STATUS_UPDATING,
           OutdatedGem::STATUS_TESTING
        return :yellow
      when OutdatedGem::STATUS_UPDATED
        return :green
      when OutdatedGem::STATUS_UNCHANGED
        return :blue
      when OutdatedGem::STATUS_PENDING
        return nil # render in default color
      else
        return nil
      end
    end
  end
end
