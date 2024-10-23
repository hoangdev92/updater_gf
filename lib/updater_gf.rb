# frozen_string_literal: true

require_relative 'updater_gf/version'
require_relative 'updater_gf/handle_update'
module UpdaterGf
  class Error < StandardError; end

  # class Updater
  class Updater
    class << self
      def run(add_gem = '', add_robocop = '')
        HandleUpdate.new(add_gem == '-a', add_robocop == '-r').process
      end
    end
  end
end
