# frozen_string_literal: true

require_relative 'updater_gf/version'
require_relative 'updater_gf/handle_update'
module UpdaterGf
  class Error < StandardError; end

  # class Updater
  class Updater
    class << self
      def run(add_gem = '', add_robocop = '')
        if check_argv_error?(add_gem, add_robocop)
          show_message_argv_error
          return
        end

        is_add_gem = add_gem?(add_gem)
        is_add_robocop = add_robocop?(add_gem, add_robocop)
        HandleUpdate.new(is_add_gem, is_add_robocop).process
      end

      def add_gem?(add_gem)
        add_gem == '-a'
      end

      def add_robocop?(add_gem, add_robocop)
        add_robocop == '-r' || add_gem == '-r'
      end

      def check_argv_error?(add_gem, add_robocop)
        return true if (add_gem != '-a' || add_gem != '-r') && add_gem != ''
        return true if add_robocop != '' && add_robocop != '-r'

        false
      end

      def show_message_argv_error
        puts 'Invalid arguments'
        puts 'Usage: updater_gf [-a] [-r]'
        puts '  -a: Add gems from list_gems_add to Gemfile'
        puts '  -r: Add .rubocop.yml to project root'
      end
    end
  end
end
