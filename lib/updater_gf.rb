# frozen_string_literal: true

require_relative 'updater_gf/version'
require_relative 'updater_gf/handle_update'
module UpdaterGf
  class Error < StandardError; end

  # class Updater
  class Updater
    class << self
      def run(add_gem = '', add_robocop = '')
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
    end
  end
end
